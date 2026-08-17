import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/entities/recipe.dart';
import '../../../domain/repositories/recipe_repository.dart';
import '../datasources/local/app_database.dart';
import '../datasources/remote/remote_mappers.dart';
import '../datasources/remote/remote_sync_source.dart';
import '../models/recipe_model.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final AppDatabase _db;
  RemoteSyncSource? _remote;
  RecipeRepositoryImpl(this._db);

  void bindRemote(RemoteSyncSource? remote) {
    _remote = remote;
  }

  @override
  Future<List<Recipe>> getAll() async {
    final rows = await _db.queryAll('recipes', orderBy: 'order_index ASC');
    return rows.map(RecipeMapper.fromMap).toList();
  }

  @override
  Future<List<Recipe>> getByDay(String day) async {
    final rows = await _db.queryAll(
      'recipes',
      where: 'day = ?',
      whereArgs: [day],
      orderBy: 'order_index ASC',
    );
    return rows.map(RecipeMapper.fromMap).toList();
  }

  @override
  Future<Recipe> create({
    required String day,
    required String meal,
    required String name,
    required String ingredients,
    required String preparation,
    required String origin,
  }) async {
    final maxRow = await _db.rawQuery(
      'SELECT COALESCE(MAX(order_index), -1) AS m FROM recipes',
    );
    final nextOrder = (maxRow.first['m'] as int) + 1;
    final id = await _db.insertRow('recipes', {
      'day': day,
      'meal': meal,
      'name': name,
      'ingredients': ingredients,
      'preparation': preparation,
      'origin': origin,
      'order_index': nextOrder,
    });
    var r = Recipe(
      id: id,
      day: day,
      meal: meal,
      name: name,
      ingredients: ingredients,
      preparation: preparation,
      origin: origin,
      orderIndex: nextOrder,
    );
    final remote = _remote;
    if (remote != null) {
      final remoteId = await remote.insertRecipe(r);
      await _db.setRemoteId('recipes', id, remoteId);
      r = r.copyWith(remoteId: remoteId);
    }
    return r;
  }

  @override
  Future<void> update(Recipe recipe) async {
    await _db.updateWhere(
      'recipes',
      {
        'name': recipe.name,
        'ingredients': recipe.ingredients,
        'preparation': recipe.preparation,
        'origin': recipe.origin,
      },
      'id = ?',
      [recipe.id],
    );
    final remote = _remote;
    final remoteId = recipe.remoteId;
    if (remote != null && remoteId != null) {
      await remote.updateRecipe(remoteId, recipe);
    }
  }

  @override
  Future<void> delete(int id) async {
    final row = await _db.queryAll(
      'recipes',
      columns: const ['remote_id'],
      where: 'id = ?',
      whereArgs: [id],
    );
    await _db.deleteWhere('recipes', 'id = ?', [id]);
    final remote = _remote;
    final remoteId =
        row.isNotEmpty ? row.first['remote_id'] as String? : null;
    if (remote != null && remoteId != null) {
      await remote.deleteRecipe(remoteId);
    }
  }

  Future<void> syncPull() async {
    final remote = _remote;
    if (remote == null) return;
    final items = await remote.fetchRecipes();
    final rows = items
        .map((r) => {...RecipeMapper.toRow(r), 'remote_id': r.remoteId})
        .toList();
    await _db.replaceAll('recipes', rows);
  }

  Future<void> applyRemoteChange(RemoteChange change) async {
    if (change.type != RemoteEntityType.recipe) return;
    if (change.event == PostgresChangeEvent.delete) {
      await _db.deleteByRemoteId('recipes', change.remoteId);
      return;
    }
    final row = change.newRow;
    if (row == null) return;
    final r = RemoteMappers.recipe(row);
    await _db.upsertByRemoteId(
      'recipes',
      {...RecipeMapper.toRow(r), 'remote_id': change.remoteId},
    );
  }
}

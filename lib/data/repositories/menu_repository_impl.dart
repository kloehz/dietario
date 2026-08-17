import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/entities/day_meal.dart';
import '../../../domain/repositories/menu_repository.dart';
import '../datasources/local/app_database.dart';
import '../datasources/remote/remote_mappers.dart';
import '../datasources/remote/remote_sync_source.dart';
import '../models/day_meal_model.dart';

class MenuRepositoryImpl implements MenuRepository {
  final AppDatabase _db;
  RemoteSyncSource? _remote;
  MenuRepositoryImpl(this._db);

  void bindRemote(RemoteSyncSource? remote) {
    _remote = remote;
  }

  @override
  Future<List<DayMeal>> getAll() async {
    final db = await _db.database;
    final rows = await db.query('day_meals', orderBy: 'order_index ASC');
    return rows.map(DayMealMapper.fromMap).toList();
  }

  @override
  Future<List<DayMeal>> getByDay(String day) async {
    final db = await _db.database;
    final rows = await db.query(
      'day_meals',
      where: 'day = ?',
      whereArgs: [day],
      orderBy: 'order_index ASC',
    );
    return rows.map(DayMealMapper.fromMap).toList();
  }

  @override
  Future<DayMeal> create({
    required String day,
    required MealSlot slot,
    required String text,
    String? menuCode,
    String? note,
  }) async {
    final db = await _db.database;
    final maxRow = await db.rawQuery(
      'SELECT COALESCE(MAX(order_index), -1) AS m FROM day_meals',
    );
    final nextOrder = (maxRow.first['m'] as int) + 1;
    final id = await db.insert('day_meals', {
      'day': day,
      'slot': slot.name,
      'text': text,
      'menu_code': menuCode,
      'note': note,
      'order_index': nextOrder,
    });
    var meal = DayMeal(
      id: id,
      day: day,
      slot: slot,
      text: text,
      menuCode: menuCode,
      note: note,
      orderIndex: nextOrder,
    );
    final remote = _remote;
    if (remote != null) {
      final remoteId = await remote.insertMeal(meal);
      await _db.setRemoteId('day_meals', id, remoteId);
      meal = meal.copyWith(remoteId: remoteId);
    }
    return meal;
  }

  @override
  Future<void> update(DayMeal meal) async {
    final db = await _db.database;
    await db.update(
      'day_meals',
      {
        'text': meal.text,
        'menu_code': meal.menuCode,
        'note': meal.note,
      },
      where: 'id = ?',
      whereArgs: [meal.id],
    );
    final remote = _remote;
    final remoteId = meal.remoteId;
    if (remote != null && remoteId != null) {
      await remote.updateMeal(remoteId, meal);
    }
  }

  @override
  Future<void> delete(int id) async {
    final db = await _db.database;
    final row = await db.query(
      'day_meals',
      columns: ['remote_id'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    await db.delete('day_meals', where: 'id = ?', whereArgs: [id]);
    final remote = _remote;
    final remoteId =
        row.isNotEmpty ? row.first['remote_id'] as String? : null;
    if (remote != null && remoteId != null) {
      await remote.deleteMeal(remoteId);
    }
  }

  // ---- Sync (called by SyncCoordinator) ----

  Future<void> syncPull() async {
    final remote = _remote;
    if (remote == null) return;
    final items = await remote.fetchMeals();
    final rows = items
        .map((m) => {...DayMealMapper.toRow(m), 'remote_id': m.remoteId})
        .toList();
    await _db.replaceAll('day_meals', rows);
  }

  Future<void> applyRemoteChange(RemoteChange change) async {
    if (change.type != RemoteEntityType.meal) return;
    if (change.event == PostgresChangeEvent.delete) {
      await _db.deleteByRemoteId('day_meals', change.remoteId);
      return;
    }
    final row = change.newRow;
    if (row == null) return;
    final meal = RemoteMappers.meal(row);
    await _db.upsertByRemoteId(
      'day_meals',
      {...DayMealMapper.toRow(meal), 'remote_id': change.remoteId},
    );
  }
}

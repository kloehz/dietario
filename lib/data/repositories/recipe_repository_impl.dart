import '../../../domain/entities/recipe.dart';
import '../../../domain/repositories/recipe_repository.dart';
import '../datasources/local/app_database.dart';
import '../models/recipe_model.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final AppDatabase _db;
  RecipeRepositoryImpl(this._db);

  @override
  Future<List<Recipe>> getAll() async {
    final db = await _db.database;
    final rows = await db.query('recipes', orderBy: 'order_index ASC');
    return rows.map(RecipeMapper.fromMap).toList();
  }

  @override
  Future<List<Recipe>> getByDay(String day) async {
    final db = await _db.database;
    final rows = await db.query(
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
    final db = await _db.database;
    final maxRow = await db.rawQuery(
      'SELECT COALESCE(MAX(order_index), -1) AS m FROM recipes',
    );
    final nextOrder = (maxRow.first['m'] as int) + 1;
    final id = await db.insert('recipes', {
      'day': day,
      'meal': meal,
      'name': name,
      'ingredients': ingredients,
      'preparation': preparation,
      'origin': origin,
      'order_index': nextOrder,
    });
    return Recipe(
      id: id,
      day: day,
      meal: meal,
      name: name,
      ingredients: ingredients,
      preparation: preparation,
      origin: origin,
      orderIndex: nextOrder,
    );
  }

  @override
  Future<void> update(Recipe recipe) async {
    final db = await _db.database;
    await db.update(
      'recipes',
      {
        'name': recipe.name,
        'ingredients': recipe.ingredients,
        'preparation': recipe.preparation,
        'origin': recipe.origin,
      },
      where: 'id = ?',
      whereArgs: [recipe.id],
    );
  }

  @override
  Future<void> delete(int id) async {
    final db = await _db.database;
    await db.delete('recipes', where: 'id = ?', whereArgs: [id]);
  }
}

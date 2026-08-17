import '../../../domain/entities/day_meal.dart';
import '../../../domain/repositories/menu_repository.dart';
import '../datasources/local/app_database.dart';
import '../models/day_meal_model.dart';

class MenuRepositoryImpl implements MenuRepository {
  final AppDatabase _db;
  MenuRepositoryImpl(this._db);

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
    return DayMeal(
      id: id,
      day: day,
      slot: slot,
      text: text,
      menuCode: menuCode,
      note: note,
      orderIndex: nextOrder,
    );
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
  }

  @override
  Future<void> delete(int id) async {
    final db = await _db.database;
    await db.delete('day_meals', where: 'id = ?', whereArgs: [id]);
  }
}

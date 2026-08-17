import '../entities/day_meal.dart';

abstract class MenuRepository {
  Future<List<DayMeal>> getAll();
  Future<List<DayMeal>> getByDay(String day);
  Future<DayMeal> create({
    required String day,
    required MealSlot slot,
    required String text,
    String? menuCode,
    String? note,
  });
  Future<void> update(DayMeal meal);
  Future<void> delete(int id);
}

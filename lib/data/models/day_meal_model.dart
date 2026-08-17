import '../../domain/entities/day_meal.dart';

class DayMealMapper {
  static DayMeal fromMap(Map<String, Object?> m) => DayMeal(
        id: m['id'] as int,
        day: m['day'] as String,
        slot: MealSlotX.fromKey(m['slot'] as String),
        text: m['text'] as String,
        menuCode: m['menu_code'] as String?,
        note: m['note'] as String?,
        orderIndex: m['order_index'] as int,
      );
}

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
        remoteId: m['remote_id'] as String?,
      );

  static Map<String, Object?> toRow(DayMeal m) => {
        'day': m.day,
        'slot': m.slot.name,
        'text': m.text,
        'menu_code': m.menuCode,
        'note': m.note,
        'order_index': m.orderIndex,
        'remote_id': m.remoteId,
      };
}

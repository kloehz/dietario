enum MealSlot { desayuno, almuerzo, merienda, cena }

extension MealSlotX on MealSlot {
  String get label {
    switch (this) {
      case MealSlot.desayuno:
        return 'Desayuno';
      case MealSlot.almuerzo:
        return 'Almuerzo';
      case MealSlot.merienda:
        return 'Merienda';
      case MealSlot.cena:
        return 'Cena';
    }
  }

  static MealSlot fromKey(String key) =>
      MealSlot.values.firstWhere((m) => m.name == key);
}

class DayMeal {
  final int id;
  final String day;        // Lunes, Martes, ...
  final MealSlot slot;
  final String text;
  final String? menuCode;  // MENÚ 1, MENÚ 2, ...
  final String? note;
  final int orderIndex;
  final String? remoteId;  // UUID assigned when synced to Supabase.

  const DayMeal({
    required this.id,
    required this.day,
    required this.slot,
    required this.text,
    this.menuCode,
    this.note,
    required this.orderIndex,
    this.remoteId,
  });

  DayMeal copyWith({
    String? text,
    String? menuCode,
    String? note,
    String? remoteId,
  }) =>
      DayMeal(
        id: id,
        day: day,
        slot: slot,
        text: text ?? this.text,
        menuCode: menuCode ?? this.menuCode,
        note: note ?? this.note,
        orderIndex: orderIndex,
        remoteId: remoteId ?? this.remoteId,
      );
}

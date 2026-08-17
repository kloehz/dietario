class Recipe {
  final int id;
  final String day;          // Lunes..Domingo o "Base"
  final String meal;         // Almuerzo, Cena, Desayuno/Merienda
  final String name;
  final String ingredients;
  final String preparation;
  final String origin;
  final int orderIndex;

  const Recipe({
    required this.id,
    required this.day,
    required this.meal,
    required this.name,
    required this.ingredients,
    required this.preparation,
    required this.origin,
    required this.orderIndex,
  });

  Recipe copyWith({
    String? name,
    String? ingredients,
    String? preparation,
    String? origin,
  }) =>
      Recipe(
        id: id,
        day: day,
        meal: meal,
        name: name ?? this.name,
        ingredients: ingredients ?? this.ingredients,
        preparation: preparation ?? this.preparation,
        origin: origin ?? this.origin,
        orderIndex: orderIndex,
      );
}

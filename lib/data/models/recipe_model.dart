import '../../domain/entities/recipe.dart';

class RecipeMapper {
  static Recipe fromMap(Map<String, Object?> m) => Recipe(
        id: m['id'] as int,
        day: m['day'] as String,
        meal: m['meal'] as String,
        name: m['name'] as String,
        ingredients: m['ingredients'] as String,
        preparation: m['preparation'] as String,
        origin: m['origin'] as String,
        orderIndex: m['order_index'] as int,
      );
}

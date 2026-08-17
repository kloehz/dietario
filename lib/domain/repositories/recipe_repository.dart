import '../entities/recipe.dart';

abstract class RecipeRepository {
  Future<List<Recipe>> getAll();
  Future<List<Recipe>> getByDay(String day);
  Future<Recipe> create({
    required String day,
    required String meal,
    required String name,
    required String ingredients,
    required String preparation,
    required String origin,
  });
  Future<void> update(Recipe recipe);
  Future<void> delete(int id);
}

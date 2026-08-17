import 'package:flutter/foundation.dart';

import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';

class RecipeController extends ChangeNotifier {
  final RecipeRepository _repo;
  RecipeController(this._repo);

  List<Recipe> _recipes = const [];
  bool _loading = false;
  String? _filter;

  List<Recipe> get recipes => _recipes;
  bool get loading => _loading;
  String? get filter => _filter;

  Map<String, List<Recipe>> get byDay {
    final map = <String, List<Recipe>>{};
    for (final r in _recipes) {
      map.putIfAbsent(r.day, () => []).add(r);
    }
    return map;
  }

  List<String> get days {
    const order = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo', 'Base'];
    final keys = byDay.keys.toList();
    keys.sort((a, b) {
      final ia = order.indexOf(a);
      final ib = order.indexOf(b);
      if (ia == -1 && ib == -1) return a.compareTo(b);
      if (ia == -1) return 1;
      if (ib == -1) return -1;
      return ia.compareTo(ib);
    });
    return keys;
  }

  void setFilter(String? day) {
    _filter = day;
    notifyListeners();
  }

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _recipes = List.of(await _repo.getAll());
    _loading = false;
    notifyListeners();
  }

  Future<void> add({
    required String day,
    required String meal,
    required String name,
    required String ingredients,
    required String preparation,
    required String origin,
  }) async {
    final created = await _repo.create(
      day: day,
      meal: meal,
      name: name,
      ingredients: ingredients,
      preparation: preparation,
      origin: origin,
    );
    _recipes = [..._recipes, created];
    if (_filter != null && _filter != day) {
      _filter = null;
    }
    notifyListeners();
  }

  Future<void> update(Recipe recipe) async {
    await _repo.update(recipe);
    _recipes = [
      for (final r in _recipes) r.id == recipe.id ? recipe : r,
    ];
    notifyListeners();
  }

  Future<void> remove(int id) async {
    await _repo.delete(id);
    _recipes = _recipes.where((r) => r.id != id).toList();
    notifyListeners();
  }
}

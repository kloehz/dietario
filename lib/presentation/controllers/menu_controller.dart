import 'package:flutter/foundation.dart';

import '../../domain/entities/day_meal.dart';
import '../../domain/repositories/menu_repository.dart';

class MenuController extends ChangeNotifier {
  final MenuRepository _repo;
  MenuController(this._repo);

  List<DayMeal> _meals = const [];
  bool _loading = false;

  List<DayMeal> get meals => _meals;
  bool get loading => _loading;

  Map<String, List<DayMeal>> get byDay {
    final map = <String, List<DayMeal>>{};
    for (final m in _meals) {
      map.putIfAbsent(m.day, () => []).add(m);
    }
    return map;
  }

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _meals = List.of(await _repo.getAll());
    _loading = false;
    notifyListeners();
  }

  Future<void> add({
    required String day,
    required MealSlot slot,
    required String text,
    String? menuCode,
    String? note,
  }) async {
    final created = await _repo.create(
      day: day,
      slot: slot,
      text: text,
      menuCode: menuCode,
      note: note,
    );
    _meals = [..._meals, created];
    notifyListeners();
  }

  Future<void> update(DayMeal meal) async {
    await _repo.update(meal);
    _meals = [
      for (final m in _meals) m.id == meal.id ? meal : m,
    ];
    notifyListeners();
  }

  Future<void> remove(int id) async {
    await _repo.delete(id);
    _meals = _meals.where((m) => m.id != id).toList();
    notifyListeners();
  }
}

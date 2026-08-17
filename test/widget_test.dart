import 'package:dietario/domain/entities/day_meal.dart';
import 'package:dietario/domain/entities/prep_task.dart';
import 'package:dietario/domain/entities/recipe.dart';
import 'package:dietario/domain/entities/shopping_item.dart';
import 'package:dietario/domain/repositories/menu_repository.dart';
import 'package:dietario/domain/repositories/prep_repository.dart';
import 'package:dietario/domain/repositories/recipe_repository.dart';
import 'package:dietario/domain/repositories/shopping_repository.dart';
import 'package:dietario/presentation/controllers/menu_controller.dart';
import 'package:dietario/presentation/controllers/prep_controller.dart';
import 'package:dietario/presentation/controllers/recipe_controller.dart';
import 'package:dietario/presentation/controllers/shopping_controller.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeMenuRepo implements MenuRepository {
  final List<DayMeal> meals;
  _FakeMenuRepo(this.meals);
  @override
  Future<List<DayMeal>> getAll() async => meals;
  @override
  Future<List<DayMeal>> getByDay(String day) async =>
      meals.where((m) => m.day == day).toList();
  @override
  Future<DayMeal> create({
    required String day,
    required MealSlot slot,
    required String text,
    String? menuCode,
    String? note,
  }) async {
    final id = meals.isEmpty ? 1 : meals.map((m) => m.id).reduce((a, b) => a > b ? a : b) + 1;
    final m = DayMeal(
      id: id,
      day: day,
      slot: slot,
      text: text,
      menuCode: menuCode,
      note: note,
      orderIndex: id,
    );
    meals.add(m);
    return m;
  }

  @override
  Future<void> update(DayMeal meal) async {}
  @override
  Future<void> delete(int id) async {
    meals.removeWhere((m) => m.id == id);
  }
}

class _FakeShoppingRepo implements ShoppingRepository {
  final List<ShoppingItem> items;
  _FakeShoppingRepo(this.items);
  @override
  Future<List<ShoppingItem>> getAll() async => items;
  @override
  Future<ShoppingItem> create({
    required String category,
    required String product,
    required double quantity,
    required String unit,
    required String notes,
  }) async {
    final id = items.isEmpty ? 1 : items.map((i) => i.id).reduce((a, b) => a > b ? a : b) + 1;
    final i = ShoppingItem(
      id: id,
      category: category,
      product: product,
      quantity: quantity,
      unit: unit,
      notes: notes,
      status: ShoppingStatus.pendiente,
      orderIndex: id,
    );
    items.add(i);
    return i;
  }

  @override
  Future<void> updateStatus(int id, ShoppingStatus status) async {}
  @override
  Future<void> update(ShoppingItem item) async {}
  @override
  Future<void> delete(int id) async {
    items.removeWhere((i) => i.id == id);
  }

  @override
  Future<int> count() async => items.length;
  @override
  Future<int> countPurchased() async =>
      items.where((i) => i.status == ShoppingStatus.comprado).length;
}

class _FakeRecipeRepo implements RecipeRepository {
  final List<Recipe> recipes;
  _FakeRecipeRepo(this.recipes);
  @override
  Future<List<Recipe>> getAll() async => recipes;
  @override
  Future<List<Recipe>> getByDay(String day) async =>
      recipes.where((r) => r.day == day).toList();
  @override
  Future<Recipe> create({
    required String day,
    required String meal,
    required String name,
    required String ingredients,
    required String preparation,
    required String origin,
  }) async {
    final id = recipes.isEmpty ? 1 : recipes.map((r) => r.id).reduce((a, b) => a > b ? a : b) + 1;
    final r = Recipe(
      id: id,
      day: day,
      meal: meal,
      name: name,
      ingredients: ingredients,
      preparation: preparation,
      origin: origin,
      orderIndex: id,
    );
    recipes.add(r);
    return r;
  }

  @override
  Future<void> update(Recipe recipe) async {}
  @override
  Future<void> delete(int id) async {
    recipes.removeWhere((r) => r.id == id);
  }
}

class _FakePrepRepo implements PrepRepository {
  final List<PrepTask> tasks;
  _FakePrepRepo(this.tasks);
  @override
  Future<List<PrepTask>> getAll() async => tasks;
  @override
  Future<PrepTask> create({
    required int order,
    required String task,
    required String quantity,
    required String purpose,
    required String storage,
  }) async {
    final id = tasks.isEmpty ? 1 : tasks.map((t) => t.id).reduce((a, b) => a > b ? a : b) + 1;
    final t = PrepTask(
      id: id,
      order: order == 0 ? (tasks.length + 1) : order,
      task: task,
      quantity: quantity,
      purpose: purpose,
      storage: storage,
      status: PrepStatus.pendiente,
    );
    tasks.add(t);
    return t;
  }

  @override
  Future<void> updateStatus(int id, PrepStatus status) async {}
  @override
  Future<void> delete(int id) async {
    tasks.removeWhere((t) => t.id == id);
  }
}

DayMeal _meal(int id, String day, MealSlot slot) => DayMeal(
      id: id,
      day: day,
      slot: slot,
      text: 'text-$id',
      menuCode: 'MENU',
      note: null,
      orderIndex: id,
    );

ShoppingItem _item(int id, String cat, ShoppingStatus s) => ShoppingItem(
      id: id,
      category: cat,
      product: 'product-$id',
      quantity: 1,
      unit: 'kg',
      notes: '',
      status: s,
      orderIndex: id,
    );

Recipe _recipe(int id, String day) => Recipe(
      id: id,
      day: day,
      meal: 'Almuerzo',
      name: 'rec-$id',
      ingredients: '',
      preparation: '',
      origin: '',
      orderIndex: id,
    );

PrepTask _task(int id, PrepStatus s) => PrepTask(
      id: id,
      order: id,
      task: 't-$id',
      quantity: '',
      purpose: '',
      storage: '',
      status: s,
    );

void main() {
  group('MenuController', () {
    test('groups meals by day', () async {
      final repo = _FakeMenuRepo([
        _meal(1, 'Lunes', MealSlot.desayuno),
        _meal(2, 'Lunes', MealSlot.almuerzo),
        _meal(3, 'Martes', MealSlot.desayuno),
      ]);
      final c = MenuController(repo);
      await c.load();
      expect(c.byDay['Lunes']?.length, 2);
      expect(c.byDay['Martes']?.length, 1);
    });

    test('add appends a meal and remove drops it', () async {
      final repo = _FakeMenuRepo([_meal(1, 'Lunes', MealSlot.desayuno)]);
      final c = MenuController(repo);
      await c.load();
      await c.add(
        day: 'Lunes',
        slot: MealSlot.cena,
        text: 'Tostada con queso',
      );
      expect(c.meals.length, 2);
      await c.remove(1);
      expect(c.meals.length, 1);
      expect(c.meals.first.slot, MealSlot.cena);
    });
  });

  group('ShoppingController', () {
    test('computes progress and groups by category', () async {
      final repo = _FakeShoppingRepo([
        _item(1, 'Verdulería', ShoppingStatus.comprado),
        _item(2, 'Verdulería', ShoppingStatus.pendiente),
        _item(3, 'Frutas', ShoppingStatus.comprado),
      ]);
      final c = ShoppingController(repo);
      await c.load();
      expect(c.total, 3);
      expect(c.purchased, 2);
      expect(c.progress, closeTo(2 / 3, 0.001));
      expect(c.byCategory['Verdulería']?.length, 2);
      expect(c.categories, ['Frutas', 'Verdulería']);
    });

    test('toggleStatus flips state and add appends', () async {
      final repo = _FakeShoppingRepo([_item(1, 'Verdulería', ShoppingStatus.pendiente)]);
      final c = ShoppingController(repo);
      await c.load();
      await c.toggleStatus(c.items.first);
      expect(c.items.first.status, ShoppingStatus.comprado);
      await c.add(
        category: 'Frutas',
        product: 'Manzana',
        quantity: 4,
        unit: 'unidades',
        notes: '',
      );
      expect(c.total, 2);
    });
  });

  group('RecipeController', () {
    test('orders days starting on Lunes', () async {
      final repo = _FakeRecipeRepo([
        _recipe(1, 'Domingo'),
        _recipe(2, 'Lunes'),
        _recipe(3, 'Miércoles'),
        _recipe(4, 'Base'),
      ]);
      final c = RecipeController(repo);
      await c.load();
      expect(c.days, ['Lunes', 'Miércoles', 'Domingo', 'Base']);
    });

    test('add appends and resets filter when new day appears', () async {
      final repo = _FakeRecipeRepo([_recipe(1, 'Lunes')]);
      final c = RecipeController(repo);
      await c.load();
      c.setFilter('Lunes');
      await c.add(
        day: 'Martes',
        meal: 'Almuerzo',
        name: 'Wok de pollo',
        ingredients: '',
        preparation: '',
        origin: '',
      );
      expect(c.recipes.length, 2);
      expect(c.filter, isNull); // cleared because new day != filter
    });
  });

  group('PrepController', () {
    test('counts done tasks', () async {
      final repo = _FakePrepRepo([
        _task(1, PrepStatus.hecho),
        _task(2, PrepStatus.pendiente),
        _task(3, PrepStatus.hecho),
      ]);
      final c = PrepController(repo);
      await c.load();
      expect(c.total, 3);
      expect(c.done, 2);
      expect(c.progress, closeTo(2 / 3, 0.001));
    });

    test('toggle flips state and add appends', () async {
      final repo = _FakePrepRepo([_task(1, PrepStatus.pendiente)]);
      final c = PrepController(repo);
      await c.load();
      await c.toggleStatus(c.tasks.first);
      expect(c.tasks.first.status, PrepStatus.hecho);
      await c.add(
        order: 0,
        task: 'Lavar frutas',
        quantity: '7 días',
        purpose: '',
        storage: '',
      );
      expect(c.total, 2);
    });
  });
}

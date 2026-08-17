import 'package:flutter/foundation.dart';

import '../../domain/entities/shopping_item.dart';
import '../../domain/repositories/shopping_repository.dart';

class ShoppingController extends ChangeNotifier {
  final ShoppingRepository _repo;
  ShoppingController(this._repo);

  List<ShoppingItem> _items = const [];
  bool _loading = false;

  List<ShoppingItem> get items => _items;
  bool get loading => _loading;

  int get total => _items.length;
  int get purchased =>
      _items.where((i) => i.status == ShoppingStatus.comprado).length;
  double get progress => total == 0 ? 0 : purchased / total;

  Map<String, List<ShoppingItem>> get byCategory {
    final map = <String, List<ShoppingItem>>{};
    for (final i in _items) {
      map.putIfAbsent(i.category, () => []).add(i);
    }
    return map;
  }

  List<String> get categories {
    final list = byCategory.keys.toList();
    list.sort();
    return list;
  }

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _items = List.of(await _repo.getAll());
    _loading = false;
    notifyListeners();
  }

  Future<void> add({
    required String category,
    required String product,
    required double quantity,
    required String unit,
    required String notes,
  }) async {
    final created = await _repo.create(
      category: category,
      product: product,
      quantity: quantity,
      unit: unit,
      notes: notes,
    );
    _items = [..._items, created];
    notifyListeners();
  }

  Future<void> toggleStatus(ShoppingItem item) async {
    final next = item.status == ShoppingStatus.pendiente
        ? ShoppingStatus.comprado
        : ShoppingStatus.pendiente;
    await _repo.updateStatus(item.id, next);
    _items = [
      for (final i in _items)
        i.id == item.id ? i.copyWith(status: next) : i,
    ];
    notifyListeners();
  }

  Future<void> update(ShoppingItem item) async {
    await _repo.update(item);
    _items = [
      for (final i in _items) i.id == item.id ? item : i,
    ];
    notifyListeners();
  }

  Future<void> remove(int id) async {
    await _repo.delete(id);
    _items = _items.where((i) => i.id != id).toList();
    notifyListeners();
  }
}

import '../entities/shopping_item.dart';

abstract class ShoppingRepository {
  Future<List<ShoppingItem>> getAll();
  Future<ShoppingItem> create({
    required String category,
    required String product,
    required double quantity,
    required String unit,
    required String notes,
  });
  Future<void> updateStatus(int id, ShoppingStatus status);
  Future<void> update(ShoppingItem item);
  Future<void> delete(int id);
  Future<int> count();
  Future<int> countPurchased();
}

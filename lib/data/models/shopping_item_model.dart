import '../../domain/entities/shopping_item.dart';

class ShoppingItemMapper {
  static ShoppingItem fromMap(Map<String, Object?> m) => ShoppingItem(
        id: m['id'] as int,
        category: m['category'] as String,
        product: m['product'] as String,
        quantity: (m['quantity'] as num).toDouble(),
        unit: m['unit'] as String,
        notes: m['notes'] as String,
        status: ShoppingStatusX.fromKey(m['status'] as String),
        orderIndex: m['order_index'] as int,
      );
}

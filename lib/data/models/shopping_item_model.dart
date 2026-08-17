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
        remoteId: m['remote_id'] as String?,
      );

  static Map<String, Object?> toRow(ShoppingItem i) => {
        'category': i.category,
        'product': i.product,
        'quantity': i.quantity,
        'unit': i.unit,
        'notes': i.notes,
        'status': i.status.name,
        'order_index': i.orderIndex,
        'remote_id': i.remoteId,
      };
}

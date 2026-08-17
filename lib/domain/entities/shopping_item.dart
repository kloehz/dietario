enum ShoppingStatus { pendiente, comprado }

extension ShoppingStatusX on ShoppingStatus {
  String get label {
    switch (this) {
      case ShoppingStatus.pendiente:
        return 'Pendiente';
      case ShoppingStatus.comprado:
        return 'Comprado';
    }
  }

  static ShoppingStatus fromKey(String key) =>
      ShoppingStatus.values.firstWhere((s) => s.name == key);
}

class ShoppingItem {
  final int id;
  final String category;
  final String product;
  final double quantity;
  final String unit;
  final String notes;
  final ShoppingStatus status;
  final int orderIndex;
  final String? remoteId;

  const ShoppingItem({
    required this.id,
    required this.category,
    required this.product,
    required this.quantity,
    required this.unit,
    required this.notes,
    required this.status,
    required this.orderIndex,
    this.remoteId,
  });

  ShoppingItem copyWith({
    String? category,
    String? product,
    double? quantity,
    String? unit,
    String? notes,
    ShoppingStatus? status,
    String? remoteId,
  }) =>
      ShoppingItem(
        id: id,
        category: category ?? this.category,
        product: product ?? this.product,
        quantity: quantity ?? this.quantity,
        unit: unit ?? this.unit,
        notes: notes ?? this.notes,
        status: status ?? this.status,
        orderIndex: orderIndex,
        remoteId: remoteId ?? this.remoteId,
      );
}

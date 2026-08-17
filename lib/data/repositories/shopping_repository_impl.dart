import '../../../domain/entities/shopping_item.dart';
import '../../../domain/repositories/shopping_repository.dart';
import '../datasources/local/app_database.dart';
import '../models/shopping_item_model.dart';

class ShoppingRepositoryImpl implements ShoppingRepository {
  final AppDatabase _db;
  ShoppingRepositoryImpl(this._db);

  @override
  Future<List<ShoppingItem>> getAll() async {
    final db = await _db.database;
    final rows = await db.query(
      'shopping_items',
      orderBy: 'order_index ASC',
    );
    return rows.map(ShoppingItemMapper.fromMap).toList();
  }

  @override
  Future<ShoppingItem> create({
    required String category,
    required String product,
    required double quantity,
    required String unit,
    required String notes,
  }) async {
    final db = await _db.database;
    final maxRow = await db.rawQuery(
      'SELECT COALESCE(MAX(order_index), -1) AS m FROM shopping_items',
    );
    final nextOrder = (maxRow.first['m'] as int) + 1;
    final id = await db.insert('shopping_items', {
      'category': category,
      'product': product,
      'quantity': quantity,
      'unit': unit,
      'notes': notes,
      'status': ShoppingStatus.pendiente.name,
      'order_index': nextOrder,
    });
    return ShoppingItem(
      id: id,
      category: category,
      product: product,
      quantity: quantity,
      unit: unit,
      notes: notes,
      status: ShoppingStatus.pendiente,
      orderIndex: nextOrder,
    );
  }

  @override
  Future<void> updateStatus(int id, ShoppingStatus status) async {
    final db = await _db.database;
    await db.update(
      'shopping_items',
      {'status': status.name},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> update(ShoppingItem item) async {
    final db = await _db.database;
    await db.update(
      'shopping_items',
      {
        'category': item.category,
        'product': item.product,
        'quantity': item.quantity,
        'unit': item.unit,
        'notes': item.notes,
        'status': item.status.name,
      },
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  @override
  Future<void> delete(int id) async {
    final db = await _db.database;
    await db.delete('shopping_items', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<int> count() async {
    final db = await _db.database;
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM shopping_items',
    );
    return (rows.first['c'] as int?) ?? 0;
  }

  @override
  Future<int> countPurchased() async {
    final db = await _db.database;
    final rows = await db.rawQuery(
      "SELECT COUNT(*) AS c FROM shopping_items WHERE status = 'comprado'",
    );
    return (rows.first['c'] as int?) ?? 0;
  }
}

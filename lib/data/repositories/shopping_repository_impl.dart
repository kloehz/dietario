import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/entities/shopping_item.dart';
import '../../../domain/repositories/shopping_repository.dart';
import '../datasources/local/app_database.dart';
import '../datasources/remote/remote_mappers.dart';
import '../datasources/remote/remote_sync_source.dart';
import '../models/shopping_item_model.dart';

class ShoppingRepositoryImpl implements ShoppingRepository {
  final AppDatabase _db;
  RemoteSyncSource? _remote;
  ShoppingRepositoryImpl(this._db);

  void bindRemote(RemoteSyncSource? remote) {
    _remote = remote;
  }

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
    var item = ShoppingItem(
      id: id,
      category: category,
      product: product,
      quantity: quantity,
      unit: unit,
      notes: notes,
      status: ShoppingStatus.pendiente,
      orderIndex: nextOrder,
    );
    final remote = _remote;
    if (remote != null) {
      final remoteId = await remote.insertShopping(item);
      await _db.setRemoteId('shopping_items', id, remoteId);
      item = item.copyWith(remoteId: remoteId);
    }
    return item;
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
    final row = await db.query(
      'shopping_items',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (row.isNotEmpty) {
      final remote = _remote;
      final remoteId = row.first['remote_id'] as String?;
      if (remote != null && remoteId != null) {
        final updated = ShoppingItemMapper.fromMap(row.first);
        await remote.updateShopping(remoteId, updated);
      }
    }
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
    final remote = _remote;
    final remoteId = item.remoteId;
    if (remote != null && remoteId != null) {
      await remote.updateShopping(remoteId, item);
    }
  }

  @override
  Future<void> delete(int id) async {
    final db = await _db.database;
    final row = await db.query(
      'shopping_items',
      columns: ['remote_id'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    await db.delete('shopping_items', where: 'id = ?', whereArgs: [id]);
    final remote = _remote;
    final remoteId =
        row.isNotEmpty ? row.first['remote_id'] as String? : null;
    if (remote != null && remoteId != null) {
      await remote.deleteShopping(remoteId);
    }
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

  // ---- Sync ----

  Future<void> syncPull() async {
    final remote = _remote;
    if (remote == null) return;
    final items = await remote.fetchShopping();
    final rows = items
        .map((i) => {...ShoppingItemMapper.toRow(i), 'remote_id': i.remoteId})
        .toList();
    await _db.replaceAll('shopping_items', rows);
  }

  Future<void> applyRemoteChange(RemoteChange change) async {
    if (change.type != RemoteEntityType.shopping) return;
    if (change.event == PostgresChangeEvent.delete) {
      await _db.deleteByRemoteId('shopping_items', change.remoteId);
      return;
    }
    final row = change.newRow;
    if (row == null) return;
    final item = RemoteMappers.shopping(row);
    await _db.upsertByRemoteId(
      'shopping_items',
      {...ShoppingItemMapper.toRow(item), 'remote_id': change.remoteId},
    );
  }
}

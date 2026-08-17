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
    final rows =
        await _db.queryAll('shopping_items', orderBy: 'order_index ASC');
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
    final maxRow = await _db.rawQuery(
      'SELECT COALESCE(MAX(order_index), -1) AS m FROM shopping_items',
    );
    final nextOrder = (maxRow.first['m'] as int) + 1;
    final id = await _db.insertRow('shopping_items', {
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
    await _db.updateWhere(
      'shopping_items',
      {'status': status.name},
      'id = ?',
      [id],
    );
    final row = await _db.queryAll(
      'shopping_items',
      columns: const ['remote_id'],
      where: 'id = ?',
      whereArgs: [id],
    );
    if (row.isNotEmpty) {
      final remote = _remote;
      final remoteId = row.first['remote_id'] as String?;
      if (remote != null && remoteId != null) {
        // Re-fetch the full row to send to remote.
        final fullRow = await _db.queryAll(
          'shopping_items',
          where: 'id = ?',
          whereArgs: [id],
        );
        if (fullRow.isNotEmpty) {
          final updated = ShoppingItemMapper.fromMap(fullRow.first);
          await remote.updateShopping(remoteId, updated);
        }
      }
    }
  }

  @override
  Future<void> update(ShoppingItem item) async {
    await _db.updateWhere(
      'shopping_items',
      {
        'category': item.category,
        'product': item.product,
        'quantity': item.quantity,
        'unit': item.unit,
        'notes': item.notes,
        'status': item.status.name,
      },
      'id = ?',
      [item.id],
    );
    final remote = _remote;
    final remoteId = item.remoteId;
    if (remote != null && remoteId != null) {
      await remote.updateShopping(remoteId, item);
    }
  }

  @override
  Future<void> delete(int id) async {
    final row = await _db.queryAll(
      'shopping_items',
      columns: const ['remote_id'],
      where: 'id = ?',
      whereArgs: [id],
    );
    await _db.deleteWhere('shopping_items', 'id = ?', [id]);
    final remote = _remote;
    final remoteId =
        row.isNotEmpty ? row.first['remote_id'] as String? : null;
    if (remote != null && remoteId != null) {
      await remote.deleteShopping(remoteId);
    }
  }

  @override
  Future<int> count() async {
    final rows = await _db.rawQuery(
      'SELECT COUNT(*) AS c FROM shopping_items',
    );
    return (rows.first['c'] as int?) ?? 0;
  }

  @override
  Future<int> countPurchased() async {
    final rows = await _db.rawQuery(
      "SELECT COUNT(*) AS c FROM shopping_items WHERE status = 'comprado'",
    );
    return (rows.first['c'] as int?) ?? 0;
  }

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

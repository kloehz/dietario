import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/entities/prep_task.dart';
import '../../../domain/repositories/prep_repository.dart';
import '../datasources/local/app_database.dart';
import '../datasources/remote/remote_mappers.dart';
import '../datasources/remote/remote_sync_source.dart';
import '../models/prep_task_model.dart';

class PrepRepositoryImpl implements PrepRepository {
  final AppDatabase _db;
  RemoteSyncSource? _remote;
  PrepRepositoryImpl(this._db);

  void bindRemote(RemoteSyncSource? remote) {
    _remote = remote;
  }

  @override
  Future<List<PrepTask>> getAll() async {
    final rows = await _db.queryAll('prep_tasks', orderBy: 'order_index ASC');
    return rows.map(PrepTaskMapper.fromMap).toList();
  }

  @override
  Future<PrepTask> create({
    required int order,
    required String task,
    required String quantity,
    required String purpose,
    required String storage,
  }) async {
    final maxRow = await _db.rawQuery(
      'SELECT COALESCE(MAX(order_index), 0) AS m FROM prep_tasks',
    );
    var nextOrder = order;
    final storedMax = (maxRow.first['m'] as int);
    if (nextOrder <= storedMax) nextOrder = storedMax + 1;
    final id = await _db.insertRow('prep_tasks', {
      'order_index': nextOrder,
      'task': task,
      'quantity': quantity,
      'purpose': purpose,
      'storage': storage,
      'status': PrepStatus.pendiente.name,
    });
    var t = PrepTask(
      id: id,
      order: nextOrder,
      task: task,
      quantity: quantity,
      purpose: purpose,
      storage: storage,
      status: PrepStatus.pendiente,
    );
    final remote = _remote;
    if (remote != null) {
      final remoteId = await remote.insertPrep(t);
      await _db.setRemoteId('prep_tasks', id, remoteId);
      t = t.copyWith(remoteId: remoteId);
    }
    return t;
  }

  @override
  Future<void> updateStatus(int id, PrepStatus status) async {
    await _db.updateWhere(
      'prep_tasks',
      {'status': status.name},
      'id = ?',
      [id],
    );
    final row = await _db.queryAll(
      'prep_tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (row.isNotEmpty) {
      final remote = _remote;
      final remoteId = row.first['remote_id'] as String?;
      if (remote != null && remoteId != null) {
        final updated = PrepTaskMapper.fromMap(row.first);
        await remote.updatePrep(remoteId, updated);
      }
    }
  }

  @override
  Future<void> delete(int id) async {
    final row = await _db.queryAll(
      'prep_tasks',
      columns: const ['remote_id'],
      where: 'id = ?',
      whereArgs: [id],
    );
    await _db.deleteWhere('prep_tasks', 'id = ?', [id]);
    final remote = _remote;
    final remoteId =
        row.isNotEmpty ? row.first['remote_id'] as String? : null;
    if (remote != null && remoteId != null) {
      await remote.deletePrep(remoteId);
    }
  }

  Future<void> syncPull() async {
    final remote = _remote;
    if (remote == null) return;
    final items = await remote.fetchPrep();
    final rows = items
        .map((t) => {...PrepTaskMapper.toRow(t), 'remote_id': t.remoteId})
        .toList();
    await _db.replaceAll('prep_tasks', rows);
  }

  Future<void> applyRemoteChange(RemoteChange change) async {
    if (change.type != RemoteEntityType.prep) return;
    if (change.event == PostgresChangeEvent.delete) {
      await _db.deleteByRemoteId('prep_tasks', change.remoteId);
      return;
    }
    final row = change.newRow;
    if (row == null) return;
    final t = RemoteMappers.prep(row);
    await _db.upsertByRemoteId(
      'prep_tasks',
      {...PrepTaskMapper.toRow(t), 'remote_id': change.remoteId},
    );
  }
}

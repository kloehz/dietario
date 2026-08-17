import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/entities/plan_note.dart';
import '../../../domain/repositories/notes_repository.dart';
import '../datasources/local/app_database.dart';
import '../datasources/remote/remote_mappers.dart';
import '../datasources/remote/remote_sync_source.dart';
import '../models/plan_note_model.dart';

class NotesRepositoryImpl implements NotesRepository {
  final AppDatabase _db;
  RemoteSyncSource? _remote;
  NotesRepositoryImpl(this._db);

  void bindRemote(RemoteSyncSource? remote) {
    _remote = remote;
  }

  @override
  Future<List<PlanNote>> getAll() async {
    final rows = await _db.queryAll('plan_notes', orderBy: 'order_index ASC');
    return rows.map(PlanNoteMapper.fromMap).toList();
  }

  @override
  Future<PlanNote> create({
    required String topic,
    required String respected,
    required String applied,
    required String source,
  }) async {
    final maxRow = await _db.rawQuery(
      'SELECT COALESCE(MAX(order_index), -1) AS m FROM plan_notes',
    );
    final nextOrder = (maxRow.first['m'] as int) + 1;
    final id = await _db.insertRow('plan_notes', {
      'topic': topic,
      'respected': respected,
      'applied': applied,
      'source': source,
      'order_index': nextOrder,
    });
    var n = PlanNote(
      id: id,
      topic: topic,
      respected: respected,
      applied: applied,
      source: source,
      orderIndex: nextOrder,
    );
    final remote = _remote;
    if (remote != null) {
      final remoteId = await remote.insertNote(n);
      await _db.setRemoteId('plan_notes', id, remoteId);
      n = n.copyWith(remoteId: remoteId);
    }
    return n;
  }

  @override
  Future<void> delete(int id) async {
    final row = await _db.queryAll(
      'plan_notes',
      columns: const ['remote_id'],
      where: 'id = ?',
      whereArgs: [id],
    );
    await _db.deleteWhere('plan_notes', 'id = ?', [id]);
    final remote = _remote;
    final remoteId =
        row.isNotEmpty ? row.first['remote_id'] as String? : null;
    if (remote != null && remoteId != null) {
      await remote.deleteNote(remoteId);
    }
  }

  Future<void> syncPull() async {
    final remote = _remote;
    if (remote == null) return;
    final items = await remote.fetchNotes();
    final rows = items
        .map((n) => {...PlanNoteMapper.toRow(n), 'remote_id': n.remoteId})
        .toList();
    await _db.replaceAll('plan_notes', rows);
  }

  Future<void> applyRemoteChange(RemoteChange change) async {
    if (change.type != RemoteEntityType.note) return;
    if (change.event == PostgresChangeEvent.delete) {
      await _db.deleteByRemoteId('plan_notes', change.remoteId);
      return;
    }
    final row = change.newRow;
    if (row == null) return;
    final n = RemoteMappers.note(row);
    await _db.upsertByRemoteId(
      'plan_notes',
      {...PlanNoteMapper.toRow(n), 'remote_id': change.remoteId},
    );
  }
}

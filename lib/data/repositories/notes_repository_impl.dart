import '../../../domain/entities/plan_note.dart';
import '../../../domain/repositories/notes_repository.dart';
import '../datasources/local/app_database.dart';
import '../models/plan_note_model.dart';

class NotesRepositoryImpl implements NotesRepository {
  final AppDatabase _db;
  NotesRepositoryImpl(this._db);

  @override
  Future<List<PlanNote>> getAll() async {
    final db = await _db.database;
    final rows = await db.query('plan_notes', orderBy: 'order_index ASC');
    return rows.map(PlanNoteMapper.fromMap).toList();
  }

  @override
  Future<PlanNote> create({
    required String topic,
    required String respected,
    required String applied,
    required String source,
  }) async {
    final db = await _db.database;
    final maxRow = await db.rawQuery(
      'SELECT COALESCE(MAX(order_index), -1) AS m FROM plan_notes',
    );
    final nextOrder = (maxRow.first['m'] as int) + 1;
    final id = await db.insert('plan_notes', {
      'topic': topic,
      'respected': respected,
      'applied': applied,
      'source': source,
      'order_index': nextOrder,
    });
    return PlanNote(
      id: id,
      topic: topic,
      respected: respected,
      applied: applied,
      source: source,
      orderIndex: nextOrder,
    );
  }

  @override
  Future<void> delete(int id) async {
    final db = await _db.database;
    await db.delete('plan_notes', where: 'id = ?', whereArgs: [id]);
  }
}

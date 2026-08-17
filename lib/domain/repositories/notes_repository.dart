import '../entities/plan_note.dart';

abstract class NotesRepository {
  Future<List<PlanNote>> getAll();
  Future<PlanNote> create({
    required String topic,
    required String respected,
    required String applied,
    required String source,
  });
  Future<void> delete(int id);
}

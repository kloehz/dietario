import '../../domain/entities/plan_note.dart';

class PlanNoteMapper {
  static PlanNote fromMap(Map<String, Object?> m) => PlanNote(
        id: m['id'] as int,
        topic: m['topic'] as String,
        respected: m['respected'] as String,
        applied: m['applied'] as String,
        source: m['source'] as String,
        orderIndex: m['order_index'] as int,
      );
}

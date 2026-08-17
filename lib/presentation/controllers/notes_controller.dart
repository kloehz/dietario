import 'package:flutter/foundation.dart';

import '../../domain/entities/plan_note.dart';
import '../../domain/repositories/notes_repository.dart';

class NotesController extends ChangeNotifier {
  final NotesRepository _repo;
  NotesController(this._repo);

  List<PlanNote> _notes = const [];
  bool _loading = false;

  List<PlanNote> get notes => _notes;
  bool get loading => _loading;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _notes = List.of(await _repo.getAll());
    _loading = false;
    notifyListeners();
  }

  Future<void> add({
    required String topic,
    required String respected,
    required String applied,
    required String source,
  }) async {
    final created = await _repo.create(
      topic: topic,
      respected: respected,
      applied: applied,
      source: source,
    );
    _notes = [..._notes, created];
    notifyListeners();
  }

  Future<void> remove(int id) async {
    await _repo.delete(id);
    _notes = _notes.where((n) => n.id != id).toList();
    notifyListeners();
  }
}

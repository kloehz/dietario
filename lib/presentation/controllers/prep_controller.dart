import 'package:flutter/foundation.dart';

import '../../domain/entities/prep_task.dart';
import '../../domain/repositories/prep_repository.dart';

class PrepController extends ChangeNotifier {
  final PrepRepository _repo;
  PrepController(this._repo);

  List<PrepTask> _tasks = const [];
  bool _loading = false;

  List<PrepTask> get tasks => _tasks;
  bool get loading => _loading;

  int get total => _tasks.length;
  int get done =>
      _tasks.where((t) => t.status == PrepStatus.hecho).length;
  double get progress => total == 0 ? 0 : done / total;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _tasks = List.of(await _repo.getAll());
    _loading = false;
    notifyListeners();
  }

  Future<void> add({
    required int order,
    required String task,
    required String quantity,
    required String purpose,
    required String storage,
  }) async {
    final created = await _repo.create(
      order: order,
      task: task,
      quantity: quantity,
      purpose: purpose,
      storage: storage,
    );
    _tasks = [..._tasks, created];
    _tasks.sort((a, b) => a.order.compareTo(b.order));
    notifyListeners();
  }

  Future<void> toggleStatus(PrepTask task) async {
    final next = task.status == PrepStatus.pendiente
        ? PrepStatus.hecho
        : PrepStatus.pendiente;
    await _repo.updateStatus(task.id, next);
    _tasks = [
      for (final t in _tasks) t.id == task.id ? t.copyWith(status: next) : t,
    ];
    notifyListeners();
  }

  Future<void> remove(int id) async {
    await _repo.delete(id);
    _tasks = _tasks.where((t) => t.id != id).toList();
    notifyListeners();
  }
}

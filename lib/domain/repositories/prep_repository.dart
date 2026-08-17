import '../entities/prep_task.dart';

abstract class PrepRepository {
  Future<List<PrepTask>> getAll();
  Future<PrepTask> create({
    required int order,
    required String task,
    required String quantity,
    required String purpose,
    required String storage,
  });
  Future<void> updateStatus(int id, PrepStatus status);
  Future<void> delete(int id);
}

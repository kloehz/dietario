import '../../../domain/entities/prep_task.dart';
import '../../../domain/repositories/prep_repository.dart';
import '../datasources/local/app_database.dart';
import '../models/prep_task_model.dart';

class PrepRepositoryImpl implements PrepRepository {
  final AppDatabase _db;
  PrepRepositoryImpl(this._db);

  @override
  Future<List<PrepTask>> getAll() async {
    final db = await _db.database;
    final rows = await db.query('prep_tasks', orderBy: 'order_index ASC');
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
    final db = await _db.database;
    final maxRow = await db.rawQuery(
      'SELECT COALESCE(MAX(order_index), 0) AS m FROM prep_tasks',
    );
    var nextOrder = order;
    final storedMax = (maxRow.first['m'] as int);
    if (nextOrder <= storedMax) nextOrder = storedMax + 1;
    final id = await db.insert('prep_tasks', {
      'order_index': nextOrder,
      'task': task,
      'quantity': quantity,
      'purpose': purpose,
      'storage': storage,
      'status': PrepStatus.pendiente.name,
    });
    return PrepTask(
      id: id,
      order: nextOrder,
      task: task,
      quantity: quantity,
      purpose: purpose,
      storage: storage,
      status: PrepStatus.pendiente,
    );
  }

  @override
  Future<void> updateStatus(int id, PrepStatus status) async {
    final db = await _db.database;
    await db.update(
      'prep_tasks',
      {'status': status.name},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> delete(int id) async {
    final db = await _db.database;
    await db.delete('prep_tasks', where: 'id = ?', whereArgs: [id]);
  }
}

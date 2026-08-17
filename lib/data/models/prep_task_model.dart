import '../../domain/entities/prep_task.dart';

class PrepTaskMapper {
  static PrepTask fromMap(Map<String, Object?> m) => PrepTask(
        id: m['id'] as int,
        order: m['order_index'] as int,
        task: m['task'] as String,
        quantity: m['quantity'] as String,
        purpose: m['purpose'] as String,
        storage: m['storage'] as String,
        status: PrepStatusX.fromKey(m['status'] as String),
      );
}

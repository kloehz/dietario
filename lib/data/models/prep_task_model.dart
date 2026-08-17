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
        remoteId: m['remote_id'] as String?,
      );

  static Map<String, Object?> toRow(PrepTask t) => {
        'order_index': t.order,
        'task': t.task,
        'quantity': t.quantity,
        'purpose': t.purpose,
        'storage': t.storage,
        'status': t.status.name,
        'remote_id': t.remoteId,
      };
}

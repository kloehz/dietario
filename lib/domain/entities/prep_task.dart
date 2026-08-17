enum PrepStatus { pendiente, hecho }

extension PrepStatusX on PrepStatus {
  String get label {
    switch (this) {
      case PrepStatus.pendiente:
        return 'Pendiente';
      case PrepStatus.hecho:
        return 'Hecho';
    }
  }

  static PrepStatus fromKey(String key) =>
      PrepStatus.values.firstWhere((s) => s.name == key);
}

class PrepTask {
  final int id;
  final int order;
  final String task;
  final String quantity;
  final String purpose;
  final String storage;
  final PrepStatus status;
  final String? remoteId;

  const PrepTask({
    required this.id,
    required this.order,
    required this.task,
    required this.quantity,
    required this.purpose,
    required this.storage,
    required this.status,
    this.remoteId,
  });

  PrepTask copyWith({PrepStatus? status, String? remoteId}) => PrepTask(
        id: id,
        order: order,
        task: task,
        quantity: quantity,
        purpose: purpose,
        storage: storage,
        status: status ?? this.status,
        remoteId: remoteId ?? this.remoteId,
      );
}

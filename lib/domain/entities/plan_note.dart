class PlanNote {
  final int id;
  final String topic;
  final String respected;
  final String applied;
  final String source;
  final int orderIndex;
  final String? remoteId;

  const PlanNote({
    required this.id,
    required this.topic,
    required this.respected,
    required this.applied,
    required this.source,
    required this.orderIndex,
    this.remoteId,
  });

  PlanNote copyWith({String? remoteId}) => PlanNote(
        id: id,
        topic: topic,
        respected: respected,
        applied: applied,
        source: source,
        orderIndex: orderIndex,
        remoteId: remoteId ?? this.remoteId,
      );
}

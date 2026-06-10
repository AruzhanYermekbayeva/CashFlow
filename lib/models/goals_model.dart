class GoalModel {
  final int? id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime createdAt;

  GoalModel({
    this.id,
    required this.title,
    required this.targetAmount,
    this.currentAmount = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory GoalModel.fromMap(Map<String, dynamic> map) {
    return GoalModel(
      id: map['id'],
      title: map['title'],
      targetAmount: map['targetAmount'],
      currentAmount: map['currentAmount'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
class BudgetModel {
  final int? id;
  final String name;
  final double amount;

  BudgetModel({
    this.id,
    required this.name,
    required this.amount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
    };
  }

  static BudgetModel fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'],
      name: map['name'],
      amount: map['amount'],
    );
  }
}

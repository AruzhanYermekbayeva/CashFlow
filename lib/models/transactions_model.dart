class TransactionModel {
  final int? id;
  final String title;
  final double amount;
  final DateTime date;
  final double? lat;
  final double? lng;

  TransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    this.lat,
    this.lng,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'lat': lat,
      'lng': lng,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      lat: map['lat'],
      lng: map['lng'],
    );
  }

  TransactionModel copyWith({
    int? id,
    String? title,
    double? amount,
    DateTime? date,
    double? lat,
    double? lng,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }
}
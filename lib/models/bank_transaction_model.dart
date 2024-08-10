class BankTransaction {
  int? id;
  int userId;
  String type;
  double amount;

  BankTransaction({this.id, required this.userId, required this.type, required this.amount});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'amount': amount,
    };
  }

  factory BankTransaction.fromMap(Map<String, dynamic> map) {
    return BankTransaction(
      id: map['id'],
      userId: map['userId'],
      type: map['type'],
      amount: map['amount'],
    );
  }
}

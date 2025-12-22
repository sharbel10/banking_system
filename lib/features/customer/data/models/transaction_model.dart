class TransactionModel {
  final String id;
  final String type;
  final String description;
  final double amount;
  final String date;
  final String status;
  TransactionModel({
    required this.id,
    required this.type,
    required this.description,
    required this.amount,
    required this.date,
    required this.status,
  });
}

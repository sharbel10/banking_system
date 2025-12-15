enum TransactionType { deposit, withdraw, transfer }
enum TransactionStatus { approved, pending, rejected }

class TransactionEntity {
  final String id;
  final TransactionType type;

  final String accountId;
  final String? toAccountId;

  final double amount;
  final TransactionStatus status;
  final DateTime createdAt;
  final String? note;

  const TransactionEntity({
    required this.id,
    required this.type,
    required this.accountId,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.toAccountId,
    this.note,
  });

  TransactionEntity copyWith({
    TransactionStatus? status,
    String? note,
  }) {
    return TransactionEntity(
      id: id,
      type: type,
      accountId: accountId,
      toAccountId: toAccountId,
      amount: amount,
      status: status ?? this.status,
      createdAt: createdAt,
      note: note ?? this.note,
    );
  }
}

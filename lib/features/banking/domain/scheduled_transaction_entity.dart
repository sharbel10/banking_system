import 'entities/transaction_entity.dart';
enum ScheduleFrequency { once, daily, weekly, monthly }

class ScheduledTransactionEntity {
  final String id;
  final String fromAccountId;
  final String? toAccountId;
  final TransactionType type;
  final double amount;

  final DateTime nextRunAt;
  final ScheduleFrequency frequency;

  final bool isActive;

  const ScheduledTransactionEntity({
    required this.id,
    required this.fromAccountId,
    required this.toAccountId,
    required this.type,
    required this.amount,
    required this.nextRunAt,
    required this.frequency,
    required this.isActive,
  });

  ScheduledTransactionEntity copyWith({
    DateTime? nextRunAt,
    bool? isActive,
  }) {
    return ScheduledTransactionEntity(
      id: id,
      fromAccountId: fromAccountId,
      toAccountId: toAccountId,
      type: type,
      amount: amount,
      nextRunAt: nextRunAt ?? this.nextRunAt,
      frequency: frequency,
      isActive: isActive ?? this.isActive,
    );
  }
}

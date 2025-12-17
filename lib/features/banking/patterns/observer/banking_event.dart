import '../../domain/entities/transaction_entity.dart';

sealed class BankingEvent {
  const BankingEvent();
}

class TransactionSubmitted extends BankingEvent {
  final TransactionEntity transaction;
  const TransactionSubmitted(this.transaction);
}

class TransactionApproved extends BankingEvent {
  final TransactionEntity transaction;
  const TransactionApproved(this.transaction);
}

class TransactionPending extends BankingEvent {
  final TransactionEntity transaction;
  const TransactionPending(this.transaction);
}

class TransactionRejected extends BankingEvent {
  final TransactionEntity transaction;
  const TransactionRejected(this.transaction);
}

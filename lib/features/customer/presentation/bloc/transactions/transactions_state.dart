import 'package:banking_system/features/customer/data/models/transaction_model.dart';
import 'package:meta/meta.dart';

@immutable
abstract class TransactionsState {}

class TransactionsInitial extends TransactionsState {}

class TransactionsLoading extends TransactionsState {}

class TransactionsLoaded extends TransactionsState {
  final List<TransactionModel> transactions;
  TransactionsLoaded(this.transactions);
}

class TransactionsProcessing extends TransactionsState {
  final String txnId;
  TransactionsProcessing(this.txnId);
}

class TransactionsError extends TransactionsState {
  final String message;
  TransactionsError(this.message);
}

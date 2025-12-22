import 'package:meta/meta.dart';

@immutable
abstract class TransactionsEvent {}

class LoadTransactions extends TransactionsEvent {
  final String customerId;
  final String? accountId;
  LoadTransactions(this.customerId, {this.accountId});
}

class RerunChain extends TransactionsEvent {
  final String txnId;
  RerunChain(this.txnId);
}

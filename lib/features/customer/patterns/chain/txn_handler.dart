import 'dart:async';
import '../../data/models/transaction_model.dart';
import 'txn_result.dart';

abstract class TxnHandler {
  TxnHandler? next;
  Future<TxnResult> handle(TransactionModel txn);
}

class ValidateHandler extends TxnHandler {
  @override
  Future<TxnResult> handle(TransactionModel txn) async {
    if (txn.amount <= 0) return TxnResult(TxnStatus.rejected, 'Invalid amount');
    if (txn.description.trim().isEmpty)
      return TxnResult(TxnStatus.rejected, 'Empty description');
    if (next != null) return next!.handle(txn);
    return TxnResult(TxnStatus.approved, 'Validated');
  }
}

class RiskHandler extends TxnHandler {
  @override
  Future<TxnResult> handle(TransactionModel txn) async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (txn.amount > 200.0) {
      return TxnResult(TxnStatus.pending, 'Requires approval (amount > 200)');
    }
    if (next != null) return next!.handle(txn);
    return TxnResult(TxnStatus.approved, 'Risk check passed');
  }
}

class PersistHandler extends TxnHandler {
  @override
  Future<TxnResult> handle(TransactionModel txn) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (next != null) return next!.handle(txn);
    return TxnResult(TxnStatus.approved, 'Persisted');
  }
}

class NotifyHandler extends TxnHandler {
  final Future<void> Function(String title, String body)? notifier;
  NotifyHandler({this.notifier});

  @override
  Future<TxnResult> handle(TransactionModel txn) async {
    if (notifier != null) {
      unawaited(notifier!('Transaction ${txn.id}', 'Status: ${txn.status}'));
    }
    return TxnResult(TxnStatus.approved, 'Notified');
  }
}

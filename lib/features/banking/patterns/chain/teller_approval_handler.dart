import '../../domain/entities/transaction_entity.dart';
import 'approval_handler.dart';

class TellerApprovalHandler extends ApprovalHandler {
  final double maxAutoApprove;

  TellerApprovalHandler({this.maxAutoApprove = 1000});

  @override
  TransactionEntity handle(TransactionEntity tx) {
    if (tx.amount <= maxAutoApprove) {
      return tx.copyWith(
        status: TransactionStatus.approved,
        note: '${tx.note ?? ''}\nApproved by Teller (<= $maxAutoApprove)',
      );
    }

    if (next != null) return next!.handle(tx);

    return tx.copyWith(
      status: TransactionStatus.pending,
      note: '${tx.note ?? ''}\nPending approval (no next handler)',
    );
  }
}

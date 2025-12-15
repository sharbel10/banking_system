import '../../domain/entities/transaction_entity.dart';
import 'approval_handler.dart';

class ManagerApprovalHandler extends ApprovalHandler {
  final double maxManagerApprove;

  ManagerApprovalHandler({this.maxManagerApprove = 10000});

  @override
  TransactionEntity handle(TransactionEntity tx) {
    if (tx.amount <= maxManagerApprove) {
      return tx.copyWith(
        status: TransactionStatus.pending,
        note: '${tx.note ?? ''}\nRequires Manager review (<= $maxManagerApprove)',
      );
    }

    return tx.copyWith(
      status: TransactionStatus.rejected,
      note: '${tx.note ?? ''}\nRejected: exceeds manager limit (> $maxManagerApprove)',
    );
  }
}

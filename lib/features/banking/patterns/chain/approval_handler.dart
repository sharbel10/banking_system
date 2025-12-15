import '../../domain/entities/transaction_entity.dart';

abstract class ApprovalHandler {
  ApprovalHandler? next;

  ApprovalHandler setNext(ApprovalHandler handler) {
    next = handler;
    return handler;
  }

  TransactionEntity handle(TransactionEntity tx);
}

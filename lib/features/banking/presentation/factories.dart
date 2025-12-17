import '../domain/entities/transaction_entity.dart';
import '../patterns/chain/approval_handler.dart';
import '../patterns/strategy/transaction_strategy.dart';

abstract class ApprovalChainFactory {
  ApprovalHandler create();
}

abstract class TransactionStrategyFactory {
  TransactionStrategy create(TransactionType type);
}

import '../../../../core/utils/result.dart';
import '../../domain/entities/transaction_entity.dart';

abstract class TransactionStrategy {
  Result<TransactionEntity> execute(TransactionEntity tx);
}

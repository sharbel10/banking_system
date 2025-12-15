import '../../../../core/utils/result.dart';
import '../../data/datasources/banking_local_datasources.dart';
import '../../domain/entities/transaction_entity.dart';
import 'transaction_strategy.dart';

class DepositStrategy implements TransactionStrategy {
  final BankingLocalDataSource ds;
  DepositStrategy(this.ds);

  @override
  Result<TransactionEntity> execute(TransactionEntity tx) {
    final acc = ds.getAccount(tx.accountId);
    if (acc == null) return const Failure('Account not found');

    final newBalance = acc.balance + tx.amount;
    ds.updateBalance(tx.accountId, newBalance);

    return Success(tx.copyWith(note: 'Deposit applied. New balance: $newBalance'));
  }
}

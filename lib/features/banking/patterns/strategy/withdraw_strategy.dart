import '../../../../core/utils/result.dart';
import '../../data/datasources/banking_local_datasources.dart';
import '../../domain/entities/transaction_entity.dart';
import 'transaction_strategy.dart';

class WithdrawStrategy implements TransactionStrategy {
  final BankingLocalDataSource ds;
  WithdrawStrategy(this.ds);

  @override
  Result<TransactionEntity> execute(TransactionEntity tx) {
    final acc = ds.getAccount(tx.accountId);
    if (acc == null) return const Failure('Account not found');

    if (tx.amount > acc.balance) {
      return Failure('Insufficient funds. Balance: ${acc.balance}');
    }

    final newBalance = acc.balance - tx.amount;
    ds.updateBalance(tx.accountId, newBalance);

    return Success(tx.copyWith(note: 'Withdraw applied. New balance: $newBalance'));
  }
}

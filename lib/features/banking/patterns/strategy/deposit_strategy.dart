import '../../../../core/utils/result.dart';
import '../../data/datasources/banking_local_datasources.dart';
import '../../domain/entities/transaction_entity.dart';
import '../state/account_context.dart';
import 'transaction_strategy.dart';

class DepositStrategy implements TransactionStrategy {
  final BankingLocalDataSource ds;
  DepositStrategy(this.ds);

  @override
  Result<TransactionEntity> execute(TransactionEntity tx) {
    final acc = ds.getAccount(tx.accountId);
    if (acc == null) return const Failure('Account not found');

    final ctx = AccountContext(AccountContext.fromDataState(acc.state));
    final applied = ctx.deposit(acc, tx.amount);

    return applied.when(
      success: (updated) {
        ds.updateBalance(updated.id, updated.balance);
        return Success(
          tx.copyWith(note: 'Deposit applied. New balance: ${updated.balance}'),
        );
      },
      failure: (m) => Failure(m),
    );
  }
}

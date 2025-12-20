import '../../../../core/utils/result.dart';
import '../../data/datasources/banking_local_datasources.dart';
import '../../domain/entities/transaction_entity.dart';
import '../state/account_context.dart';
import 'transaction_strategy.dart';

class WithdrawStrategy implements TransactionStrategy {
  final BankingLocalDataSource ds;
  WithdrawStrategy(this.ds);

  @override
  Result<TransactionEntity> execute(TransactionEntity tx) {
    final acc = ds.getAccount(tx.accountId);
    if (acc == null) return const Failure('Account not found');

    final ctx = AccountContext(AccountContext.fromDataState(acc.state));
    final res = ctx.withdraw(acc, tx.amount);

    return res.when(
      success: (updatedAcc) {
        ds.updateBalance(updatedAcc.id, updatedAcc.balance);
        return Success(tx.copyWith(note: 'Withdraw applied'));
      },
      failure: (m) => Failure(m),
    );
  }
}

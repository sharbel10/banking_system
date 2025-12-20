import '../../../../core/utils/result.dart';
import '../../data/datasources/banking_local_datasources.dart';
import '../../domain/entities/transaction_entity.dart';
import '../state/account_context.dart';
import 'transaction_strategy.dart';

class TransferStrategy implements TransactionStrategy {
  final BankingLocalDataSource ds;
  TransferStrategy(this.ds);

  @override
  Result<TransactionEntity> execute(TransactionEntity tx) {
    final from = ds.getAccount(tx.accountId);
    if (from == null) return const Failure('From account not found');

    final toId = tx.toAccountId;
    if (toId == null || toId.isEmpty) return const Failure('Select destination account');
    if (toId == tx.accountId) return const Failure('Cannot transfer to the same account');

    final to = ds.getAccount(toId);
    if (to == null) return const Failure('To account not found');

    // ✅ Apply state rules using State Pattern
    final fromCtx = AccountContext(AccountContext.fromDataState(from.state));
    final toCtx = AccountContext(AccountContext.fromDataState(to.state));

    // 1) Withdraw from "from"
    final w = fromCtx.withdraw(from, tx.amount);
    return w.when(
      success: (updatedFrom) {
        // 2) Deposit into "to"
        final d = toCtx.deposit(to, tx.amount);
        return d.when(
          success: (updatedTo) {
            ds.updateBalance(updatedFrom.id, updatedFrom.balance);
            ds.updateBalance(updatedTo.id, updatedTo.balance);

            return Success(
              tx.copyWith(
                note: 'Transfer applied. From: ${updatedFrom.balance} • To: ${updatedTo.balance}',
              ),
            );
          },
          failure: (m) => Failure('Transfer failed (destination): $m'),
        );
      },
      failure: (m) => Failure('Transfer failed (source): $m'),
    );
  }
}

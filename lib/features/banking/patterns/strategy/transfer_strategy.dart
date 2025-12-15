import '../../../../core/utils/result.dart';
import '../../data/datasources/banking_local_datasources.dart';
import '../../domain/entities/transaction_entity.dart';
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

    if (tx.amount > from.balance) {
      return Failure('Insufficient funds. Balance: ${from.balance}');
    }

    final newFromBalance = from.balance - tx.amount;
    final newToBalance = to.balance + tx.amount;

    ds.updateBalance(from.id, newFromBalance);
    ds.updateBalance(to.id, newToBalance);

    return Success(
      tx.copyWith(
        note:
        'Transfer applied. From: $newFromBalance • To: $newToBalance',
      ),
    );
  }
}

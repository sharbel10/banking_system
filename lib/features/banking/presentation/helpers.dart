import '../../../../core/utils/result.dart';
import '../data/datasources/banking_local_datasources.dart';
import '../domain/entities/transaction_entity.dart';

class TransactionValidationHelper {
  const TransactionValidationHelper();

  Result<void> validate({
    required BankingLocalDataSource ds,
    required String fromAccountId,
    required String? toAccountId,
    required TransactionType type,
    required double amount,
  }) {
    if (amount <= 0) return const Failure('Amount must be greater than 0');

    final fromAcc = ds.getAccount(fromAccountId);
    if (fromAcc == null) return const Failure('From account not found');

    if (type == TransactionType.withdraw) {
      if (amount > fromAcc.balance) {
        return Failure('Insufficient funds. Balance: ${fromAcc.balance}');
      }
    }

    if (type == TransactionType.transfer) {
      if (toAccountId == null || toAccountId.isEmpty) {
        return const Failure('Select destination account');
      }

      if (toAccountId == fromAccountId) {
        return const Failure('Cannot transfer to the same account');
      }

      final toAcc = ds.getAccount(toAccountId);
      if (toAcc == null) return const Failure('Destination account not found');

      if (amount > fromAcc.balance) {
        return Failure('Insufficient funds. Balance: ${fromAcc.balance}');
      }
    }

    return const Success(null);
  }
}

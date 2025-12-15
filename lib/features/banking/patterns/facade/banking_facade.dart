import '../../../../core/utils/result.dart';

import '../../data/datasources/banking_local_datasources.dart';
import '../../domain/entities/account_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../chain/manager_approval_handler.dart';
import '../chain/teller_approval_handler.dart';
import '../observer/banking_event.dart';
import '../observer/event_bus.dart';
import '../strategy/deposit_strategy.dart';
import '../strategy/transaction_strategy.dart';
import '../strategy/transfer_strategy.dart';
import '../strategy/withdraw_strategy.dart';

class BankingFacade {
  final EventBus eventBus;
  final BankingLocalDataSource ds;

  BankingFacade(this.eventBus, this.ds);

  List<AccountEntity> getAccounts() => ds.getAccounts();
  double getBalance(String accountId) => ds.getBalance(accountId);

  Result<TransactionEntity> submitTransaction({
    required String accountId,
    String? toAccountId,
    required TransactionType type,
    required double amount,
  }) {
    if (amount <= 0) return const Failure('Amount must be greater than 0');

    final tx = TransactionEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      accountId: accountId,
      toAccountId: toAccountId,
      amount: amount,
      status: TransactionStatus.pending,
      createdAt: DateTime.now(),
    );

    eventBus.emit(TransactionSubmitted(tx));

    final TransactionStrategy strategy = switch (type) {
      TransactionType.deposit => DepositStrategy(ds),
      TransactionType.withdraw => WithdrawStrategy(ds),
      TransactionType.transfer => TransferStrategy(ds),
    };

    final execRes = strategy.execute(tx);

    return execRes.when(
      success: (executed) {
        final teller = TellerApprovalHandler(maxAutoApprove: 1000);
        final manager = ManagerApprovalHandler(maxManagerApprove: 10000);
        teller.setNext(manager);

        final finalTx = teller.handle(executed);

        if (finalTx.status == TransactionStatus.approved) {
          eventBus.emit(TransactionApproved(finalTx));
        } else if (finalTx.status == TransactionStatus.pending) {
          eventBus.emit(TransactionPending(finalTx));
        }

        return Success(finalTx);
      },
      failure: (msg) => Failure(msg),
    );
  }
}

import '../../data/datasources/banking_local_datasources.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../presentation/factories.dart';
import '../strategy/deposit_strategy.dart';
import '../strategy/transfer_strategy.dart';
import '../strategy/transaction_strategy.dart';
import '../strategy/withdraw_strategy.dart';
import 'banking_facade.dart';

class DefaultTransactionStrategyFactory implements TransactionStrategyFactory {
  final BankingLocalDataSource ds;
  DefaultTransactionStrategyFactory(this.ds);

  @override
  TransactionStrategy create(TransactionType type) {
    return switch (type) {
      TransactionType.deposit => DepositStrategy(ds),
      TransactionType.withdraw => WithdrawStrategy(ds),
      TransactionType.transfer => TransferStrategy(ds),
    };
  }
}

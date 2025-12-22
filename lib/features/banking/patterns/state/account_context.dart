import '../../../../core/utils/result.dart';
import '../../domain/entities/account_entity.dart';
import 'account_state.dart' as data;
import 'account_state_behavior.dart';

class AccountContext {
  AccountStateBehavior _state;

  AccountContext(this._state);

  void changeState(AccountStateBehavior s) => _state = s;

  Result<AccountEntity> deposit(AccountEntity account, double amount) =>
      _state.deposit(account, amount);

  Result<AccountEntity> withdraw(AccountEntity account, double amount) =>
      _state.withdraw(account, amount);

  static AccountStateBehavior fromDataState(data.AccountState s) {
    return switch (s) {
      data.AccountState.active => ActiveState(),
      data.AccountState.frozen => FrozenState(),
      data.AccountState.suspended => SuspendedState(),
      data.AccountState.closed => ClosedState(),
    };
  }
}

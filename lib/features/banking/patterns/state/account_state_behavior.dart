import '../../../../core/utils/result.dart';
import '../../domain/entities/account_entity.dart';

abstract class AccountStateBehavior {
  String get name;

  Result<AccountEntity> deposit(AccountEntity account, double amount);
  Result<AccountEntity> withdraw(AccountEntity account, double amount);
}

final class ActiveState implements AccountStateBehavior {
  @override
  String get name => 'Active';

  @override
  Result<AccountEntity> deposit(AccountEntity account, double amount) {
    if (amount <= 0) return const Failure('Deposit must be > 0');
    return Success(account.copyWith(balance: account.balance + amount));
  }

  @override
  Result<AccountEntity> withdraw(AccountEntity account, double amount) {
    if (amount <= 0) return const Failure('Withdraw must be > 0');
    if (account.balance < amount) return const Failure('Insufficient funds');
    return Success(account.copyWith(balance: account.balance - amount));
  }
}

final class FrozenState implements AccountStateBehavior {
  @override
  String get name => 'Frozen';

  @override
  Result<AccountEntity> deposit(AccountEntity account, double amount) {
    // عادةً بتسمح إيداع، بس امنع سحب
    if (amount <= 0) return const Failure('Deposit must be > 0');
    return Success(account.copyWith(balance: account.balance + amount));
  }

  @override
  Result<AccountEntity> withdraw(AccountEntity account, double amount) {
    return const Failure('Account is frozen. Withdraw not allowed.');
  }
}

final class SuspendedState implements AccountStateBehavior {
  @override
  String get name => 'Suspended';

  @override
  Result<AccountEntity> deposit(AccountEntity account, double amount) {
    return const Failure('Account is suspended. Operations not allowed.');
  }

  @override
  Result<AccountEntity> withdraw(AccountEntity account, double amount) {
    return const Failure('Account is suspended. Operations not allowed.');
  }
}

final class ClosedState implements AccountStateBehavior {
  @override
  String get name => 'Closed';

  @override
  Result<AccountEntity> deposit(AccountEntity account, double amount) {
    return const Failure('Account is closed. Operations not allowed.');
  }

  @override
  Result<AccountEntity> withdraw(AccountEntity account, double amount) {
    return const Failure('Account is closed. Operations not allowed.');
  }
}

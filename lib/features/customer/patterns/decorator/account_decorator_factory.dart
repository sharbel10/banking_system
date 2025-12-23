import 'package:banking_system/features/banking/domain/entities/account_entity.dart';
import 'package:banking_system/features/banking/patterns/state/account_state.dart';

import 'account_decorator.dart';
import 'overdraft_decorator.dart';
import 'premium_decorator.dart';

class AccountDecoratorFactory {
  static AccountEntity? applyOverdraft(
    AccountEntity account, {
    double minBalanceForOverdraft = 500.0,
    double overdraftLimit = 1000.0,
  }) {
    if (account.state != AccountState.active) return null;

    if (account.type == AccountType.checking ||
        account.type == AccountType.business) {
      if (account.balance >= minBalanceForOverdraft) {
        return OverdraftDecorator(account, overdraftLimit: overdraftLimit);
      }
    }
    return null;
  }

  static AccountEntity? applyPremium(
    AccountEntity account, {
    double minBalanceForPremium = 5000.0,
    String tierName = 'Gold',
  }) {
    if (account.state != AccountState.active) return null;

    if (account.balance >= minBalanceForPremium) {
      List<String> benefits = [];

      switch (tierName) {
        case 'Platinum':
          benefits = ['Priority Support', 'Higher Interest', 'Free Transfers'];
          break;
        case 'Gold':
          benefits = ['Higher Interest', 'Free Transfers'];
          break;
        case 'Silver':
          benefits = ['Higher Interest'];
          break;
      }

      return PremiumDecorator(account, tierName: tierName, benefits: benefits);
    }
    return null;
  }

  static AccountEntity applyAllDecorators(AccountEntity account) {
    AccountEntity decoratedAccount = account;

    final premium = applyPremium(decoratedAccount);
    if (premium != null) {
      decoratedAccount = premium;
    }

    final overdraft = applyOverdraft(decoratedAccount);
    if (overdraft != null) {
      decoratedAccount = overdraft;
    }

    return decoratedAccount;
  }

  static bool hasDecorator<T>(AccountEntity account) {
    if (account is T) return true;

    AccountEntity current = account;
    while (current is AccountDecorator) {
      if (current is T) return true;
      current = (current as AccountDecorator).inner;
    }

    return false;
  }

  static T? extractDecorator<T extends AccountDecorator>(
    AccountEntity account,
  ) {
    if (account is T) return account;

    AccountEntity current = account;
    while (current is AccountDecorator) {
      if (current is T) return current as T;
      current = (current as AccountDecorator).inner;
    }

    return null;
  }
}

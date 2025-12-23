import 'package:banking_system/features/banking/domain/entities/account_entity.dart';

import 'account_decorator.dart';

class PremiumDecorator extends AccountDecorator {
  final String tierName;
  final List<String> benefits;

  PremiumDecorator(
    AccountEntity account, {
    this.tierName = 'Gold',
    this.benefits = const [],
  }) : super(account);

  String get premiumTier => tierName;

  double get interestRate => _calculateInterestRate();

  double calculateMonthlyInterest() {
    return balance * (interestRate / 12);
  }

  double _calculateInterestRate() {
    switch (tierName.toLowerCase()) {
      case 'platinum':
        return 0.05;
      case 'gold':
        return 0.03;
      case 'silver':
        return 0.02;
      default:
        return 0.01;
    }
  }

  String get benefitsInfo => benefits.join(', ');
}

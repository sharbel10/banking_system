import 'package:banking_system/features/banking/domain/entities/account_entity.dart';

import 'account_decorator.dart';

class OverdraftDecorator extends AccountDecorator {
  final double overdraftLimit;

  OverdraftDecorator(AccountEntity account, {required this.overdraftLimit})
    : super(account);

  double get availableBalance => balance + overdraftLimit;

  bool get hasOverdraft => overdraftLimit > 0;

  bool canWithdraw(double amount) => amount <= availableBalance;

  String get overdraftInfo => 'Overdraft Limit: \$$overdraftLimit';
}

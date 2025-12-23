import 'package:banking_system/features/banking/domain/entities/account_entity.dart';
import 'package:banking_system/features/banking/patterns/state/account_state.dart';

abstract class AccountDecorator implements AccountEntity {
  final AccountEntity _account;

  AccountDecorator(this._account);

  @override
  String get id => _account.id;

  @override
  String get ownerName => _account.ownerName;

  @override
  double get balance => _account.balance;

  @override
  AccountType get type => _account.type;

  @override
  AccountState get state => _account.state;

  @override
  AccountEntity copyWith({
    String? id,
    String? ownerName,
    double? balance,
    AccountType? type,
    AccountState? state,
  }) {
    return _account.copyWith(
      id: id,
      ownerName: ownerName,
      balance: balance,
      type: type,
      state: state,
    );
  }

  AccountEntity get inner => _account;

  bool hasDecorator(Type decoratorType) {
    if (runtimeType == decoratorType) return true;

    AccountEntity current = _account;
    while (current is AccountDecorator) {
      if (current.runtimeType == decoratorType) return true;
      current = (current as AccountDecorator).inner;
    }
    return false;
  }
}

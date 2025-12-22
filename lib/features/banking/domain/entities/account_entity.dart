import '../../patterns/state/account_state.dart';

enum AccountType { checking, savings, business }

class AccountEntity {
  final String id;
  final String ownerName;
  final double balance;
  final AccountType type;
  final AccountState state;

  const AccountEntity({
    required this.id,
    required this.ownerName,
    required this.balance,
    required this.type,
    this.state = AccountState.active,
  });

  AccountEntity copyWith({
    String? id,
    String? ownerName,
    double? balance,
    AccountType? type,
    AccountState? state,
  }) {
    return AccountEntity(
      id: id ?? this.id,
      ownerName: ownerName ?? this.ownerName,
      balance: balance ?? this.balance,
      type: type ?? this.type,
      state: state ?? this.state,
    );
  }
}

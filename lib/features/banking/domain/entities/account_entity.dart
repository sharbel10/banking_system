enum AccountType { checking, savings, business }

class AccountEntity {
  final String id;
  final String ownerName;
  final double balance;
  final AccountType type;

  const AccountEntity({
    required this.id,
    required this.ownerName,
    required this.balance,
    required this.type,
  });

  AccountEntity copyWith({
    String? id,
    String? ownerName,
    double? balance,
    AccountType? type,
  }) {
    return AccountEntity(
      id: id ?? this.id,
      ownerName: ownerName ?? this.ownerName,
      balance: balance ?? this.balance,
      type: type ?? this.type,
    );
  }
}

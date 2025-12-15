class AccountEntity {
  final String id;
  final String ownerName;
  final double balance;

  const AccountEntity({
    required this.id,
    required this.ownerName,
    required this.balance,
  });

  AccountEntity copyWith({double? balance}) {
    return AccountEntity(
      id: id,
      ownerName: ownerName,
      balance: balance ?? this.balance,
    );
  }
}

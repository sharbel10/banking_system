enum AccountNodeType { main, leaf }

class AccountNodeEntity {
  final String id;
  final String name;
  final double balance;
  final String? parentId;
  final String ownerMainAccountId;
  final AccountNodeType nodeType;

  const AccountNodeEntity({
    required this.id,
    required this.name,
    required this.balance,
    required this.parentId,
    required this.ownerMainAccountId,
    required this.nodeType,
  });

  AccountNodeEntity copyWith({
    String? id,
    String? name,
    double? balance,
    String? parentId,
    String? ownerMainAccountId,
    AccountNodeType? nodeType,
  }) {
    return AccountNodeEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      parentId: parentId ?? this.parentId,
      ownerMainAccountId: ownerMainAccountId ?? this.ownerMainAccountId,
      nodeType: nodeType ?? this.nodeType,
    );
  }
}

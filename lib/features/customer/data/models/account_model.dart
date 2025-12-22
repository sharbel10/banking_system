class AccountModel {
  final String id;
  final String type;
  final String? parentId;
  final String name;

  final double balance;
  AccountModel({
    required this.id,
    required this.name,
    this.parentId,
    required this.type,
    required this.balance,
  });
}

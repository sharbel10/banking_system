import 'package:banking_system/features/banking/domain/entities/account_entity.dart';

import 'account_component.dart';

class AccountLeaf implements AccountComponent {
  final AccountEntity entity;

  @override
  final String id;
  @override
  final String name;
  @override
  final double balance;
  @override
  final String? parentId;

  AccountLeaf({
    required this.id,
    required this.name,
    required this.balance,
    this.parentId,
    required this.entity,
  });

  @override
  double getTotalBalance() => balance;

  @override
  bool get isComposite => false;

  @override
  void addChild(AccountComponent child) =>
      throw UnsupportedError('Leaf cannot have children');

  @override
  void removeChild(String childId) =>
      throw UnsupportedError('Leaf cannot remove children');
}

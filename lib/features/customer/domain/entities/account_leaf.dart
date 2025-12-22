import 'account_component.dart';

class AccountLeaf implements AccountComponent {
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
  });

  @override
  double getTotalBalance() => balance;

  @override
  bool get isComposite => false;

  @override
  void addChild(AccountComponent child) {
    // TODO: implement addChild
  }

  @override
  void removeChild(String childId) {
    // TODO: implement removeChild
  }
}

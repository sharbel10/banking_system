import 'account_component.dart';

class AccountComposite implements AccountComponent {
  @override
  final String id;
  @override
  final String name;
  @override
  final double balance;
  @override
  final String? parentId;

  final List<AccountComponent> _children = [];

  AccountComposite({
    required this.id,
    required this.name,
    this.balance = 0.0,
    this.parentId,
  });

  @override
  void addChild(AccountComponent child) => _children.add(child);

  @override
  void removeChild(String childId) =>
      _children.removeWhere((c) => c.id == childId);

  @override
  double getTotalBalance() {
    double total = balance;
    for (final c in _children) total += c.getTotalBalance();
    return total;
  }

  List<AccountComponent> get children => List.unmodifiable(_children);

  @override
  bool get isComposite => true;
}

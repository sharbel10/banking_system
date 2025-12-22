abstract class AccountComponent {
  String get id;
  String get name;
  double get balance;
  String? get parentId;
  double getTotalBalance();
  void addChild(AccountComponent child) => throw UnimplementedError();
  void removeChild(String childId) => throw UnimplementedError();
  bool get isComposite;
}

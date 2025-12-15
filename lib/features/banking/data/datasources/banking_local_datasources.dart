import '../../domain/entities/account_entity.dart';

class BankingLocalDataSource {
  final Map<String, AccountEntity> _accounts = {};

  BankingLocalDataSource() {
    // Seed runtime users/accounts
    _seed();
  }

  void _seed() {
    final list = <AccountEntity>[
      const AccountEntity(id: 'ACC-001', ownerName: 'Ahmad Ali', balance: 1200),
      const AccountEntity(id: 'ACC-002', ownerName: 'Sara Mohammed', balance: 5000),
      const AccountEntity(id: 'ACC-003', ownerName: 'Omar Hassan', balance: 300),
    ];
    for (final a in list) {
      _accounts[a.id] = a;
    }
  }

  List<AccountEntity> getAccounts() => _accounts.values.toList();

  AccountEntity? getAccount(String id) => _accounts[id];

  double getBalance(String id) => _accounts[id]?.balance ?? 0;

  void updateBalance(String id, double newBalance) {
    final acc = _accounts[id];
    if (acc == null) return;
    _accounts[id] = acc.copyWith(balance: newBalance);
  }
}

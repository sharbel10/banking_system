import '../../domain/entities/account_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/scheduled_transaction_entity.dart';

class BankingLocalDataSource {
  final Map<String, AccountEntity> _accounts = {};

  // ✅ History (all requests: approved/pending/rejected)
  final List<TransactionEntity> _transactions = [];

  // ✅ Pending approvals list (manager inbox)
  final Map<String, TransactionEntity> _pending = {};

  // ✅ Scheduled/Recurring
  final Map<String, ScheduledTransactionEntity> _scheduled = {};

  BankingLocalDataSource() {
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

  // ----------------------------
  // Accounts
  // ----------------------------
  List<AccountEntity> getAccounts() => _accounts.values.toList();

  AccountEntity? getAccount(String id) => _accounts[id];

  double getBalance(String id) => _accounts[id]?.balance ?? 0;

  void updateBalance(String id, double newBalance) {
    final acc = _accounts[id];
    if (acc == null) return;
    _accounts[id] = acc.copyWith(balance: newBalance);
  }

  // ----------------------------
  // Transactions History
  // ----------------------------
  void upsertTransaction(TransactionEntity tx) {
    final idx = _transactions.indexWhere((t) => t.id == tx.id);
    if (idx >= 0) {
      _transactions[idx] = tx;
    } else {
      _transactions.insert(0, tx); // newest first
    }
  }

  List<TransactionEntity> getTransactions({String? accountId}) {
    if (accountId == null) return List.unmodifiable(_transactions);

    return List.unmodifiable(
      _transactions.where(
            (t) => t.accountId == accountId || t.toAccountId == accountId,
      ),
    );
  }

  // ----------------------------
  // Pending approvals (Manager)
  // ----------------------------
  void addPending(TransactionEntity tx) {
    _pending[tx.id] = tx;
  }

  void removePending(String txId) {
    _pending.remove(txId);
  }

  TransactionEntity? getPendingById(String txId) => _pending[txId];

  List<TransactionEntity> getPendingApprovals() =>
      List.unmodifiable(_pending.values.toList());

  // ----------------------------
  // Scheduled / Recurring
  // ----------------------------
  List<ScheduledTransactionEntity> getScheduled() =>
      List.unmodifiable(_scheduled.values.toList());

  void upsertScheduled(ScheduledTransactionEntity s) {
    _scheduled[s.id] = s;
  }

  void removeScheduled(String id) {
    _scheduled.remove(id);
  }

  List<ScheduledTransactionEntity> getDueScheduled(DateTime now) {
    return List.unmodifiable(
      _scheduled.values.where((s) => s.isActive && !s.nextRunAt.isAfter(now)),
    );
  }
}

import '../../domain/entities/account_entity.dart';
import '../../domain/entities/account_node_entity.dart';
import '../../domain/entities/audit_log_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/scheduled_transaction_entity.dart';
import '../../patterns/state/account_state.dart';

class BankingLocalDataSource {
  final Map<String, AccountEntity> _accounts = {};

  final List<TransactionEntity> _transactions = [];

  final Map<String, TransactionEntity> _pending = {};

  final Map<String, ScheduledTransactionEntity> _scheduled = {};

  BankingLocalDataSource() {
    _seed();
  }

  void _seed() {
    final list = <AccountEntity>[
      const AccountEntity(
        id: 'ACC-001',
        ownerName: 'Ahmad Ali',
        balance: 600,
        type: AccountType.checking,
        state: AccountState.active,
      ),

      const AccountEntity(
        id: 'ACC-002',
        ownerName: 'Sara Mohammed',
        balance: 5000,
        type: AccountType.savings,
        state: AccountState.active,
      ),
      const AccountEntity(
        id: 'ACC-003',
        ownerName: 'Omar Hassan',
        balance: 300,
        type: AccountType.checking,
        state: AccountState.active,
      ),
    ];
    for (final a in list) {
      _accounts[a.id] = a;

      // main node
      _nodes[a.id] = AccountNodeEntity(
        id: a.id,
        name: a.ownerName,
        balance: a.balance,
        parentId: null,
        ownerMainAccountId: a.id,
        nodeType: AccountNodeType.main,
      );
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

    final node = _nodes[id];
    if (node != null && node.parentId == null) {
      _nodes[id] = node.copyWith(balance: newBalance);
    }
  }

  //  Manager-only
  void updateAccountState(String id, AccountState newState) {
    final acc = _accounts[id];
    if (acc == null) return;
    _accounts[id] = acc.copyWith(state: newState);
  }

  void addAccount(AccountEntity account) {
    _accounts[account.id] = account;

    //  add main node
    _nodes[account.id] = AccountNodeEntity(
      id: account.id,
      name: account.ownerName,
      balance: account.balance,
      parentId: null,
      ownerMainAccountId: account.id,
      nodeType: AccountNodeType.main,
    );
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
  // Pending approvals (Manager) – Transactions only
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

  final List<AuditLogEntity> _auditLogs = [];

  List<AuditLogEntity> getAuditLogs() => List.unmodifiable(_auditLogs);

  void addAudit(AuditLogEntity e) {
    _auditLogs.insert(0, e);
  }

  final Map<String, AccountNodeEntity> _nodes = {};
  List<AccountNodeEntity> getAccountNodes(String ownerMainAccountId) => _nodes
      .values
      .where((n) => n.ownerMainAccountId == ownerMainAccountId)
      .toList();

  void upsertNode(AccountNodeEntity n) {
    _nodes[n.id] = n;
  }
}

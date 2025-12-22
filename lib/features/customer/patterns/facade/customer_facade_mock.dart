import 'dart:async';
import 'package:banking_system/features/customer/data/models/account_model.dart';
import 'package:banking_system/features/customer/data/models/support_ticket_model.dart';
import 'package:banking_system/features/customer/data/models/transaction_model.dart';
import 'package:banking_system/features/customer/data/models/notification_model.dart';
import '../../domain/entities/account_leaf.dart';
import '../../domain/entities/account_composite.dart';
import '../../domain/entities/account_component.dart';
import '../chain/txn_handler.dart';
import '../chain/txn_result.dart';

class CustomerFacadeMock {
  // --- mock transactions / tickets / accounts (existing) ---
  final List<TransactionModel> _transactions = [
    TransactionModel(
      id: 't1',
      type: 'transfer',
      description: 'Transfer to John',
      amount: 50.0,
      date: '2025-12-10',
      status: 'Approved',
    ),
    TransactionModel(
      id: 't2',
      type: 'bill',
      description: 'Electricity bill',
      amount: 350.0,
      date: '2025-12-05',
      status: 'Pending',
    ),
    TransactionModel(
      id: 't3',
      type: 'topup',
      description: 'Mobile top-up',
      amount: 15.0,
      date: '2025-12-08',
      status: 'Approved',
    ),
  ];

  final List<NotificationModel> _pastNotifications = [];
  final StreamController<NotificationModel> _notifController =
      StreamController<NotificationModel>.broadcast();

  Stream<NotificationModel> notificationsStream(String customerId) =>
      _notifController.stream;

  void _pushNotification(NotificationModel n) {
    _pastNotifications.insert(0, n);
    _notifController.add(n);
  }

  Future<List<NotificationModel>> fetchPastNotifications(
    String customerId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 30));
    return List<NotificationModel>.from(_pastNotifications);
  }

  void sendTestNotification({required String title, required String body}) {
    _pushNotification(
      NotificationModel(
        id: 'test_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        body: body,
      ),
    );
  }

  Future<List<TransactionModel>> fetchTransactions(
    String customerId, {
    String? accountId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List<TransactionModel>.from(_transactions);
  }

  Future<TransactionModel> processTransaction(String txnId) async {
    final txnIndex = _transactions.indexWhere((t) => t.id == txnId);
    if (txnIndex < 0) throw Exception('Transaction not found');

    var txn = _transactions[txnIndex];

    final validate = ValidateHandler();
    final risk = RiskHandler();
    final persist = PersistHandler();
    final notify = NotifyHandler(
      notifier: (title, body) async {
        _pushNotification(
          NotificationModel(
            id: 'n_${DateTime.now().millisecondsSinceEpoch}',
            title: title,
            body: body,
          ),
        );
        return;
      },
    );

    validate.next = risk;
    risk.next = persist;
    persist.next = notify;

    final result = await validate.handle(txn);

    String newStatus;
    if (result.status == TxnStatus.approved)
      newStatus = 'Approved';
    else if (result.status == TxnStatus.pending)
      newStatus = 'Pending';
    else
      newStatus = 'Rejected';

    final updated = TransactionModel(
      id: txn.id,
      type: txn.type,
      description: txn.description,
      amount: txn.amount,
      date: txn.date,
      status: newStatus,
    );

    _transactions[txnIndex] = updated;

    _pushNotification(
      NotificationModel(
        id: 'n_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Transaction ${txn.description}',
        body: 'Status changed to $newStatus',
      ),
    );

    return updated;
  }

  // --- support tickets ---
  final List<SupportTicketModel> _tickets = [];

  Future<List<SupportTicketModel>> fetchSupportTickets(
    String customerId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _tickets
        .where((t) => t.customerId == customerId)
        .toList()
        .reversed
        .toList();
  }

  Future<SupportTicketModel> createSupportTicket({
    required String customerId,
    required String subject,
    required String message,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final ticket = SupportTicketModel(
      id: 'tk_${DateTime.now().millisecondsSinceEpoch}',
      customerId: customerId,
      subject: subject,
      message: message,
      status: 'Open',
      createdAt: DateTime.now().toUtc().toIso8601String(),
    );
    _tickets.add(ticket);

    _pushNotification(
      NotificationModel(
        id: 'n_${DateTime.now().millisecondsSinceEpoch}',
        title: 'New support ticket',
        body: 'Ticket ${ticket.id}: ${ticket.subject}',
      ),
    );

    return ticket;
  }

  Future<SupportTicketModel> updateTicketStatus(
    String ticketId,
    String newStatus,
  ) async {
    final idx = _tickets.indexWhere((t) => t.id == ticketId);
    if (idx < 0) throw Exception('Ticket not found');
    final updated = _tickets[idx].copyWith(status: newStatus);
    _tickets[idx] = updated;
    return updated;
  }

  // --- accounts (flat + hierarchy) ---
  Future<List<AccountModel>> fetchAccountsFlat(String customerId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      AccountModel(
        id: 'acc_root',
        parentId: null,
        name: 'Main Account',
        type: 'main',
        balance: 0.0,
      ),
      AccountModel(
        id: 'acc_fam',
        parentId: 'acc_root',
        name: 'Family Sub',
        type: 'family',
        balance: 500.0,
      ),
      AccountModel(
        id: 'acc_fam_kid1',
        parentId: 'acc_fam',
        name: 'Kid1',
        type: 'savings',
        balance: 120.0,
      ),
      AccountModel(
        id: 'acc_fam_kid2',
        parentId: 'acc_fam',
        name: 'Kid2',
        type: 'savings',
        balance: 80.0,
      ),
      AccountModel(
        id: 'acc_bus',
        parentId: 'acc_root',
        name: 'Business Sub',
        type: 'business',
        balance: 1000.0,
      ),
      AccountModel(
        id: 'acc_other',
        parentId: null,
        name: 'Savings Extra',
        type: 'savings',
        balance: 250.0,
      ),
    ];
  }

  Future<AccountComponent> fetchAccountsHierarchy(String customerId) async {
    final flat = await fetchAccountsFlat(customerId);

    final Map<String, AccountComponent> map = {};
    for (final m in flat) {
      map[m.id] = AccountLeaf(
        id: m.id,
        name: m.name,
        balance: m.balance,
        parentId: m.parentId,
      );
    }

    final root = AccountComposite(
      id: 'root_all',
      name: 'All Accounts',
      balance: 0.0,
      parentId: null,
    );

    for (final m in flat) {
      final comp = map[m.id]!;
      if (m.parentId == null) {
        root.addChild(comp);
      } else {
        final parent = map[m.parentId];
        if (parent == null) {
          final composite = AccountComposite(
            id: m.parentId!,
            name: 'Unknown',
            balance: 0.0,
            parentId: null,
          );
          map[m.parentId!] = composite;
          composite.addChild(comp);
        } else if (parent.isComposite) {
          (parent as AccountComposite).addChild(comp);
        } else {
          final old = parent;
          final composite = AccountComposite(
            id: old.id,
            name: old.name,
            balance: old.balance,
            parentId: old.parentId,
          );
          map[old.id] = composite;
          composite.addChild(comp);
        }
      }
    }

    return root;
  }

  void dispose() {
    _notifController.close();
  }
}

import 'dart:async';

import 'package:banking_system/features/banking/domain/entities/account_entity.dart';
import 'package:banking_system/features/banking/domain/entities/transaction_entity.dart';
import 'package:banking_system/features/banking/patterns/facade/banking_facade.dart';

import 'package:banking_system/features/customer/data/models/account_model.dart';
import 'package:banking_system/features/customer/data/models/notification_model.dart';
import 'package:banking_system/features/customer/data/models/support_ticket_model.dart';
import 'package:banking_system/features/customer/data/models/transaction_model.dart';
import 'package:banking_system/features/customer/patterns/decorator/account_decorator.dart';
import 'package:banking_system/features/customer/patterns/decorator/account_decorator_factory.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../banking/patterns/observer/banking_event.dart';
import '../../../banking/patterns/observer/event_bus.dart';

import '../../domain/entities/account_component.dart';
import '../../domain/entities/account_composite.dart';
import '../../domain/entities/account_leaf.dart';

import '../chain/txn_handler.dart';
import '../chain/txn_result.dart';

class CustomerFacadeMock {
  final BankingFacade banking;

  CustomerFacadeMock({required this.banking}) {
    //  subscribe once (singleton in GetIt)
    final bus = sl<EventBus>();
    _busSub = bus.stream.listen(_onBankEvent);
  }

  StreamSubscription? _busSub;

  // =========================
  // NOTIFICATIONS (mock)
  // =========================
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

  //  Convert Banking events -> Customer notifications (Observer)
  void _onBankEvent(BankingEvent e) {
    final selectedAccountId = sl<SessionCubit>().state.customerAccountId;

    bool related(TransactionEntity tx) {
      if (selectedAccountId == null) return true;
      return tx.accountId == selectedAccountId ||
          tx.toAccountId == selectedAccountId;
    }

    if (e is TransactionSubmitted) {
      final tx = e.transaction;
      if (!related(tx)) return;

      _pushNotification(
        NotificationModel(
          id: 'n_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Transaction submitted',
          body:
              '${tx.type.name.toUpperCase()} \$${tx.amount.toStringAsFixed(2)}',
        ),
      );
    }

    if (e is TransactionPending) {
      final tx = e.transaction;
      if (!related(tx)) return;

      _pushNotification(
        NotificationModel(
          id: 'n_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Transaction pending',
          body: 'Needs manager approval',
        ),
      );
    }

    if (e is TransactionApproved) {
      final tx = e.transaction;
      if (!related(tx)) return;

      _pushNotification(
        NotificationModel(
          id: 'n_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Transaction approved',
          body:
              '${tx.type.name.toUpperCase()} \$${tx.amount.toStringAsFixed(2)}',
        ),
      );
    }

    if (e is TransactionRejected) {
      final tx = e.transaction;
      if (!related(tx)) return;

      _pushNotification(
        NotificationModel(
          id: 'n_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Transaction rejected',
          body:
              '${tx.type.name.toUpperCase()} \$${tx.amount.toStringAsFixed(2)}',
        ),
      );
    }
  }

  // =========================
  // TRANSACTIONS (from BankingFacade) + chain simulate for UI
  // =========================
  Future<List<TransactionModel>> fetchTransactions(
    String customerId, {
    String? accountId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final txs = banking.getTransactions(accountId: accountId);
    return txs.map(_mapTx).toList();
  }

  // simulate chain (UI only)
  Future<TransactionModel> processTransaction(String txnId) async {
    final tx = banking.getTransactions().firstWhere(
      (t) => t.id == txnId,
      orElse: () => throw Exception('Transaction not found'),
    );

    final current = _mapTx(tx);

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
      },
    );

    validate.next = risk;
    risk.next = persist;
    persist.next = notify;

    final result = await validate.handle(current);

    final newStatus = result.status == TxnStatus.approved
        ? 'Approved'
        : result.status == TxnStatus.pending
        ? 'Pending'
        : 'Rejected';

    final updated = TransactionModel(
      id: current.id,
      type: current.type,
      description: current.description,
      amount: current.amount,
      date: current.date,
      status: newStatus,
    );

    _pushNotification(
      NotificationModel(
        id: 'n_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Transaction ${updated.description}',
        body: 'Status changed to $newStatus',
      ),
    );

    return updated;
  }

  // =========================
  // ACCOUNTS (from BankingFacade) + hierarchy builder (Composite)
  // =========================
  Future<List<AccountModel>> fetchAccountsFlat(
    String customerId, {
    String? accountId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 120));
    final accs = banking.getAccounts().map(_mapAcc).toList();

    if (accountId == null) return accs;
    return accs.where((a) => a.id == accountId).toList();
  }

  // Future<AccountComponent> fetchAccountsHierarchy(
  //   String customerId, {
  //   String? accountId, // ownerMainAccountId
  // }) async {
  //   final ownerId = accountId;

  //   if (ownerId == null) {
  //     // fallback: كل main accounts as root_all
  //     final mains = banking.getAccounts().map(_mapAcc).toList();
  //     final root = AccountComposite(
  //       id: 'root_all',
  //       name: 'All Accounts',
  //       balance: 0,
  //       parentId: null,
  //     );
  //     for (final m in mains) {
  //       root.addChild(
  //         AccountLeaf(
  //           id: m.id,
  //           name: m.name,
  //           balance: m.balance,
  //           parentId: null,
  //         ),
  //       );
  //     }
  //     return root;
  //   }

  //   final nodes = banking.getAccountNodes(ownerId);

  //   // map nodes → components
  //   final Map<String, AccountComponent> map = {};
  //   for (final n in nodes) {
  //     map[n.id] = n.parentId == null
  //         ? AccountComposite(
  //             id: n.id,
  //             name: n.name,
  //             balance: n.balance,
  //             parentId: null,
  //           )
  //         : AccountLeaf(
  //             id: n.id,
  //             name: n.name,
  //             balance: n.balance,
  //             parentId: n.parentId,
  //           );
  //   }

  //   // root = main account
  //   final root = map[ownerId];
  //   if (root == null) {
  //     return AccountComposite(
  //       id: 'empty',
  //       name: 'No Accounts',
  //       balance: 0,
  //       parentId: null,
  //     );
  //   }

  //   // attach leafs under main
  //   for (final n in nodes) {
  //     if (n.parentId != null) {
  //       final parent = map[n.parentId];
  //       final child = map[n.id]!;
  //       if (parent is AccountComposite) parent.addChild(child);
  //     }
  //   }

  //   return root;
  // }
  Future<AccountComponent> fetchAccountsHierarchy(
    String customerId, {
    String? accountId, // ownerMainAccountId
  }) async {
    final ownerId = accountId;

    final allAccounts = banking.getAccounts();

    if (ownerId == null) {
      final mains = allAccounts.map(_mapAcc).toList();
      final root = AccountComposite(
        id: 'root_all',
        name: 'All Accounts',
        balance: 0,
        parentId: null,
      );
      for (final m in mains) {
        final origEntity = allAccounts.firstWhere((a) => a.id == m.id);
        final decoratedEntity = AccountDecoratorFactory.applyAllDecorators(
          origEntity,
        );
        debugPrintDecoratorChain(decoratedEntity);

        // debug (اختياري)
        print('Decorated ${origEntity.id} -> ${decoratedEntity.runtimeType}');

        root.addChild(
          AccountLeaf(
            id: m.id,
            name: m.name,
            balance: decoratedEntity.balance,
            parentId: null,
            entity: decoratedEntity,
          ),
        );
      }
      return root;
    }

    final nodes = banking.getAccountNodes(ownerId);

    final Map<String, AccountComponent> map = {};
    for (final n in nodes) {
      final origEntity = allAccounts.firstWhere((a) => a.id == n.id);
      final decoratedEntity = AccountDecoratorFactory.applyAllDecorators(
        origEntity,
      );

      map[n.id] = n.parentId == null
          ? AccountComposite(
              id: n.id,
              name: n.name,
              balance: decoratedEntity.balance,
              parentId: null,
            )
          : AccountLeaf(
              id: n.id,
              name: n.name,
              balance: decoratedEntity.balance,
              parentId: n.parentId,
              entity: decoratedEntity,
            );
      print('Decorated ${origEntity.id} -> ${decoratedEntity.runtimeType}');
    }

    // root = main account
    final root = map[ownerId];
    if (root == null) {
      return AccountComposite(
        id: 'empty',
        name: 'No Accounts',
        balance: 0,
        parentId: null,
      );
    }

    // attach leafs under main
    for (final n in nodes) {
      if (n.parentId != null) {
        final parent = map[n.parentId];
        final child = map[n.id]!;
        if (parent is AccountComposite) parent.addChild(child);
      }
    }

    return root;
  }

  debugPrintDecoratorChain(AccountEntity e) {
    AccountEntity current = e;
    final chain = <String>[];
    while (true) {
      chain.add(current.runtimeType.toString());
      if (current is AccountDecorator) {
        current = (current as AccountDecorator).inner;
      } else {
        break;
      }
    }
    print('Decorator chain for ${e.id}: ${chain.join(" -> ")}');
  }

  // =========================
  // SUPPORT TICKETS (mock)
  // =========================
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

  AccountEntity _decorateAccount(AccountEntity bankingAccount) {
    // تحويل إلى AccountEntity الخاص بنا
    final account = AccountEntity(
      id: bankingAccount.id,
      ownerName: bankingAccount.ownerName,
      balance: bankingAccount.balance,
      type: bankingAccount.type, // نأخذ نفس الـ AccountType
      state: bankingAccount.state,
    );

    // تطبيق الديكوريتورات
    return AccountDecoratorFactory.applyAllDecorators(account);
  }

  void dispose() {
    _busSub?.cancel();
    _notifController.close();
  }

  // =========================
  // MAPPERS
  // =========================
  AccountModel _mapAcc(AccountEntity a) => AccountModel(
    id: a.id,
    parentId: null,
    name: a.ownerName,
    type: a.type.name,
    balance: a.balance,
  );

  TransactionModel _mapTx(TransactionEntity t) => TransactionModel(
    id: t.id,
    type: t.type.name,
    description: _desc(t),
    amount: t.amount,
    date: _fmtDate(t.createdAt),
    status: _status(t.status),
  );

  String _status(TransactionStatus s) {
    if (s == TransactionStatus.approved) return 'Approved';
    if (s == TransactionStatus.pending) return 'Pending';
    return 'Rejected';
  }

  String _desc(TransactionEntity t) {
    switch (t.type) {
      case TransactionType.deposit:
        return 'Deposit to ${t.accountId}';
      case TransactionType.withdraw:
        return 'Withdraw from ${t.accountId}';
      case TransactionType.transfer:
        return 'Transfer ${t.accountId} → ${t.toAccountId ?? '-'}';
    }
  }

  String _fmtDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

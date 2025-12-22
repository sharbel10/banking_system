import '../../../../core/auth/current_session.dart';
import '../../../../core/auth/permission_guard.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/utils/result.dart';

import '../../data/datasources/banking_local_datasources.dart';
import '../../data/services/manager_review_services.dart';
import '../../data/services/scheduled_transaction_service.dart';

import '../../domain/entities/account_entity.dart';
import '../../domain/entities/account_node_entity.dart';
import '../state/account_state.dart';
import '../../domain/entities/audit_log_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/scheduled_transaction_entity.dart';

import '../../presentation/factories.dart';
import '../../presentation/helpers.dart';

import '../chain/approval_handler.dart';
import '../factories/account_factory.dart';
import '../observer/banking_event.dart';
import '../observer/event_bus.dart';
import '../strategy/transaction_strategy.dart';

class BankingFacade {
  final BankingLocalDataSource _ds;
  final EventBus _bus;

  final ApprovalChainFactory _approvalChainFactory;
  final TransactionStrategyFactory _strategyFactory;

  final TransactionValidationHelper _validator;
  final PermissionGuard _guard;

  late final ManagerReviewService _managerReview;
  late final ScheduledTransactionService _scheduled;

  BankingFacade(
      this._ds,
      this._bus, {
        required ApprovalChainFactory approvalChainFactory,
        required TransactionStrategyFactory strategyFactory,
        required CurrentSession session,
        TransactionValidationHelper validator = const TransactionValidationHelper(),
      })  : _approvalChainFactory = approvalChainFactory,
        _strategyFactory = strategyFactory,
        _validator = validator,
        _guard = PermissionGuard(session) {
    _managerReview = ManagerReviewService(
      _ds,
      _bus,
      strategyFactory: _strategyFactory,
    );

    _scheduled = ScheduledTransactionService(
      _ds,
      _guard,
      submitDelegate: submitTransaction,
    );
  }

  // ----------------------------
  // Read APIs (Customer/Staff)
  // ----------------------------
  List<AccountEntity> getAccounts() => _ds.getAccounts();

  double getBalance(String accountId) => _ds.getBalance(accountId);

  List<TransactionEntity> getTransactions({String? accountId}) =>
      _ds.getTransactions(accountId: accountId);

  List<TransactionEntity> getPendingApprovals() => _ds.getPendingApprovals();

  List<ScheduledTransactionEntity> getScheduled() => _ds.getScheduled();

  List<AuditLogEntity> getAuditLogs() => _ds.getAuditLogs();

  // ----------------------------
  // Submit Transaction Request (Teller)
  // ----------------------------
  Result<TransactionEntity> submitTransaction({
    required String fromAccountId,
    String? toAccountId,
    required TransactionType type,
    required double amount,
  }) =>
      _withPermission(Permission.submitTransaction, () {
        print('SESSION STATE: ${sl<SessionCubit>().state.role} / ${sl<SessionCubit>().state.staffMode}');

        final request = _buildRequest(
          fromAccountId: fromAccountId,
          toAccountId: toAccountId,
          type: type,
          amount: amount,
        );

        _bus.emit(TransactionSubmitted(request));
        _audit(
          actor: 'teller',
          action: AuditAction.txSubmitted,
          message:
          'Submitted ${request.type.name} \$${request.amount} from ${request.accountId}'
              '${request.toAccountId == null ? '' : ' to ${request.toAccountId}'} (tx:${request.id})',
        );

        final validation = _validator.validate(
          ds: _ds,
          fromAccountId: fromAccountId,
          toAccountId: toAccountId,
          type: type,
          amount: amount,
        );

        return validation.when(
          success: (_) => _processValidatedRequest(request),
          failure: (msg) => _rejectRequest(request, msg),
        );
      });

  Result<TransactionEntity> _processValidatedRequest(TransactionEntity request) {
    final chain = _approvalChainFactory.create();
    final decided = chain.handle(request);

    _ds.upsertTransaction(decided);

    if (decided.status == TransactionStatus.pending) {
      _ds.addPending(decided);
      _bus.emit(TransactionPending(decided));
      return Success(decided);
    }

    if (decided.status == TransactionStatus.rejected) {
      _bus.emit(TransactionRejected(decided));
      return Success(decided);
    }

    final strategy = _strategyFactory.create(decided.type);
    final exec = strategy.execute(decided);

    return exec.when(
      success: (applied) {
        final finalTx = applied.copyWith(
          status: TransactionStatus.approved,
          note: '${applied.note ?? ''}\nApproved & applied',
        );
        _ds.upsertTransaction(finalTx);
        _bus.emit(TransactionApproved(finalTx));
        return Success(finalTx);
      },
      failure: (msg) {
        final failed = decided.copyWith(
          status: TransactionStatus.rejected,
          note: '${decided.note ?? ''}\nExecution failed: $msg',
        );
        _ds.upsertTransaction(failed);
        _bus.emit(TransactionRejected(failed));
        return Failure(msg);
      },
    );
  }

  Result<TransactionEntity> _rejectRequest(TransactionEntity request, String msg) {
    final rejected = request.copyWith(
      status: TransactionStatus.rejected,
      note: '${request.note ?? ''}\nRejected: $msg',
    );
    _ds.upsertTransaction(rejected);
    _bus.emit(TransactionRejected(rejected));
    return Failure(msg);
  }

  TransactionEntity _buildRequest({
    required String fromAccountId,
    String? toAccountId,
    required TransactionType type,
    required double amount,
  }) {
    return TransactionEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      accountId: fromAccountId,
      toAccountId: toAccountId,
      amount: amount,
      status: TransactionStatus.pending,
      createdAt: DateTime.now(),
      note: 'Request created',
    );
  }

  // ----------------------------
  // Manager Review (Approve/Reject)
  // ----------------------------
  Result<TransactionEntity> managerApprove(String txId) =>
      _withPermission(Permission.approveTransaction, () {
        final res = _managerReview.approve(txId);
        res.when(
          success: (tx) => _audit(
            actor: 'manager',
            action: AuditAction.txApproved,
            message: 'Approved tx:${tx.id} (${tx.type.name}) \$${tx.amount}',
          ),
          failure: (_) {},
        );
        return res;
      });

  Result<TransactionEntity> managerReject(String txId, {String? reason}) =>
      _withPermission(Permission.rejectTransaction, () {
        final res = _managerReview.reject(txId, reason: reason);
        res.when(
          success: (tx) => _audit(
            actor: 'manager',
            action: AuditAction.txRejected,
            message: 'Rejected tx:${tx.id} (${tx.type.name}) \$${tx.amount}'
                '${(reason == null || reason.isEmpty) ? '' : ' — Reason: $reason'}',
          ),
          failure: (_) {},
        );
        return res;
      });

  // ----------------------------
  // Manager: Change Account State
  // ----------------------------
  Result<void> managerChangeAccountState({
    required String accountId,
    required AccountState newState,
  }) =>
      _withPermission(Permission.manageAccountState, () {
        final acc = _ds.getAccount(accountId);
        if (acc == null) return const Failure('Account not found.');
        if (acc.state == newState) return const Failure('Account is already in this state.');

        _ds.updateAccountState(accountId, newState);
        _audit(
          actor: 'manager',
          action: AuditAction.accountStateChanged,
          message: 'Changed account:$accountId state → ${newState.label}',
        );

        return const Success(null);
      });

  // ----------------------------
  // Scheduled / Recurring
  // ----------------------------
  Result<ScheduledTransactionEntity> createScheduled(ScheduledTransactionEntity s) =>
      _scheduled.create(s);

  Result<void> cancelScheduled(String id) => _scheduled.cancel(id);

  Result<int> runScheduledDueNow() => _scheduled.runDueNow();

  // ----------------------------
  // Create Account (Staff)
  // ----------------------------
  Result<AccountEntity> createAccount({
    required AccountFactory factory,
    required String ownerName,
    required double initialBalance,
  }) =>
      _withPermission(Permission.manageAccounts, () {
        final name = ownerName.trim();
        if (name.isEmpty) return const Failure('Owner name is required');
        if (initialBalance < 0) return const Failure('Initial balance cannot be negative');

        final acc = factory.create(
          ownerName: name,
          initialBalance: initialBalance,
        );

        _ds.addAccount(acc);
        _audit(
          actor: 'teller',
          action: AuditAction.accountCreated,
          message:
          'Created account:${acc.id} (${acc.type.name}) for ${acc.ownerName} with \$${acc.balance}',
        );

        return Success(acc);
      });

  // ----------------------------
  // Private Helpers
  // ----------------------------
  Result<T> _withPermission<T>(Permission p, Result<T> Function() run) {
    final auth = _guard.require(p);
    return auth.when(
      success: (_) => run(),
      failure: (m) => Failure(m),
    );
  }

  void _audit({
    required String actor,
    required AuditAction action,
    required String message,
  }) {
    _ds.addAudit(
      AuditLogEntity(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        at: DateTime.now(),
        actor: actor,
        action: action,
        message: message,
      ),
    );
  }


  Result<AccountNodeEntity> createSubAccount({
    required String ownerMainAccountId, // مثلاً ACC-001
    required String name,
    required double initialBalance,
  }) =>
      _withPermission(Permission.manageAccounts, () {
        final main = _ds.getAccount(ownerMainAccountId);
        if (main == null) return const Failure('Main account not found');

        if (initialBalance < 0) return const Failure('Invalid balance');

        //  خصم من main (إذا بدك sub-account balance ينعكس من نفس الرصيد)
        if (main.balance < initialBalance) return const Failure('Insufficient funds in main account');
        _ds.updateBalance(ownerMainAccountId, main.balance - initialBalance);

        //  حدّث main node balance كمان
        _ds.upsertNode(
          AccountNodeEntity(
            id: ownerMainAccountId,
            name: main.ownerName,
            balance: _ds.getBalance(ownerMainAccountId),
            parentId: null,
            ownerMainAccountId: ownerMainAccountId,
            nodeType: AccountNodeType.main,
          ),
        );

        final id = 'LEAF-${DateTime.now().millisecondsSinceEpoch}';
        final node = AccountNodeEntity(
          id: id,
          name: name.trim().isEmpty ? 'Leaf Account' : name.trim(),
          balance: initialBalance,
          parentId: ownerMainAccountId,
          ownerMainAccountId: ownerMainAccountId,
          nodeType: AccountNodeType.leaf,
        );

        _ds.upsertNode(node);

        _audit(
          actor: 'teller',
          action: AuditAction.accountCreated,
          message: 'Created leaf:$id under $ownerMainAccountId with \$${initialBalance.toStringAsFixed(2)}',
        );

        return Success(node);
      });
  List<AccountNodeEntity> getAccountNodes(String ownerMainAccountId) =>
      _ds.getAccountNodes(ownerMainAccountId);

}

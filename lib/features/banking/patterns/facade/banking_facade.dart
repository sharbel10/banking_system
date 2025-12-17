import '../../../../core/auth/current_session.dart';
import '../../../../core/auth/permission_guard.dart';
import '../../../../core/utils/result.dart';

import '../../data/datasources/banking_local_datasources.dart';
import '../../data/services/manager_review_services.dart';
import '../../data/services/scheduled_transaction_service.dart';
import '../../domain/entities/account_entity.dart';
import '../../domain/entities/transaction_entity.dart';

import '../../domain/scheduled_transaction_entity.dart';
import '../../presentation/factories.dart';
import '../../presentation/helpers.dart';
import '../chain/approval_handler.dart';
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

  // ----------------------------
  // Submit Transaction Request (Teller)
  // ----------------------------
  Result<TransactionEntity> submitTransaction({
    required String fromAccountId,
    String? toAccountId,
    required TransactionType type,
    required double amount,
  }) {
    final auth = _guard.require(Permission.submitTransaction);
    return auth.when(
      success: (_) {
        final request = TransactionEntity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: type,
          accountId: fromAccountId,
          toAccountId: toAccountId,
          amount: amount,
          status: TransactionStatus.pending,
          createdAt: DateTime.now(),
          note: 'Request created',
        );

        _bus.emit(TransactionSubmitted(request));

        final v = _validator.validate(
          ds: _ds,
          fromAccountId: fromAccountId,
          toAccountId: toAccountId,
          type: type,
          amount: amount,
        );

        return v.when(
          success: (_) {
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

            final strategy = _strategyFactory.create(type);
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
          },
          failure: (msg) {
            final rejected = request.copyWith(
              status: TransactionStatus.rejected,
              note: '${request.note ?? ''}\nRejected: $msg',
            );
            _ds.upsertTransaction(rejected);
            _bus.emit(TransactionRejected(rejected));
            return Failure(msg);
          },
        );
      },
      failure: (m) => Failure(m),
    );
  }

  // ----------------------------
  // Manager Review (Approve/Reject)
  // ----------------------------
  Result<TransactionEntity> managerApprove(String txId) {
    final auth = _guard.require(Permission.approveTransaction);
    return auth.when(
      success: (_) => _managerReview.approve(txId),
      failure: (m) => Failure(m),
    );
  }

  Result<TransactionEntity> managerReject(String txId, {String? reason}) {
    final auth = _guard.require(Permission.rejectTransaction);
    return auth.when(
      success: (_) => _managerReview.reject(txId, reason: reason),
      failure: (m) => Failure(m),
    );
  }

  // ----------------------------
  // Scheduled / Recurring
  // ----------------------------
  Result<ScheduledTransactionEntity> createScheduled(ScheduledTransactionEntity s) =>
      _scheduled.create(s);

  Result<void> cancelScheduled(String id) => _scheduled.cancel(id);

  Result<int> runScheduledDueNow() => _scheduled.runDueNow();
}

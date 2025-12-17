import '../../../../core/utils/result.dart';
import '../../data/datasources/banking_local_datasources.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../patterns/facade/banking_facade.dart';
import '../../patterns/observer/banking_event.dart';
import '../../patterns/observer/event_bus.dart';
import '../../patterns/strategy/transaction_strategy.dart';
import '../../presentation/factories.dart';

class ManagerReviewService {
  final BankingLocalDataSource _ds;
  final EventBus _bus;
  final TransactionStrategyFactory _strategyFactory;

  ManagerReviewService(
      this._ds,
      this._bus, {
        required TransactionStrategyFactory strategyFactory,
      }) : _strategyFactory = strategyFactory;

  Result<TransactionEntity> approve(String txId) {
    final pending = _ds.getPendingById(txId);
    if (pending == null) return const Failure('Pending transaction not found');

    final TransactionStrategy strategy = _strategyFactory.create(pending.type);

    final exec = strategy.execute(
      pending.copyWith(
        status: TransactionStatus.approved,
        note: '${pending.note ?? ''}\nApproved by Manager',
      ),
    );

    return exec.when(
      success: (applied) {
        final finalTx = applied.copyWith(
          status: TransactionStatus.approved,
          note: '${applied.note ?? ''}\nApplied after manager approval',
        );

        _ds.removePending(txId);
        _ds.upsertTransaction(finalTx);

        _bus.emit(TransactionApproved(finalTx));
        return Success(finalTx);
      },
      failure: (msg) {
        final failed = pending.copyWith(
          status: TransactionStatus.rejected,
          note:
          '${pending.note ?? ''}\nManager approved but execution failed: $msg',
        );

        _ds.removePending(txId);
        _ds.upsertTransaction(failed);

        _bus.emit(TransactionRejected(failed));
        return Failure(msg);
      },
    );
  }

  Result<TransactionEntity> reject(String txId, {String? reason}) {
    final pending = _ds.getPendingById(txId);
    if (pending == null) return const Failure('Pending transaction not found');

    final rejected = pending.copyWith(
      status: TransactionStatus.rejected,
      note: '${pending.note ?? ''}\nRejected by Manager'
          '${reason == null ? '' : ': $reason'}',
    );

    _ds.removePending(txId);
    _ds.upsertTransaction(rejected);

    _bus.emit(TransactionRejected(rejected));
    return Success(rejected);
  }
}

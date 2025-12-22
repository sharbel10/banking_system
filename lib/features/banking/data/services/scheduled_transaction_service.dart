import '../../../../core/auth/permission_guard.dart';
import '../../../../core/utils/result.dart';
import '../../data/datasources/banking_local_datasources.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/scheduled_transaction_entity.dart';

class ScheduledTransactionService {
  final BankingLocalDataSource _ds;
  final PermissionGuard _guard;

  final Result<TransactionEntity> Function({
  required String fromAccountId,
  String? toAccountId,
  required TransactionType type,
  required double amount,
  }) _submit;

  ScheduledTransactionService(
      this._ds,
      this._guard, {
        required Result<TransactionEntity> Function({
        required String fromAccountId,
        String? toAccountId,
        required TransactionType type,
        required double amount,
        })
        submitDelegate,
      }) : _submit = submitDelegate;

  Result<ScheduledTransactionEntity> create(ScheduledTransactionEntity s) {
    final auth = _guard.require(Permission.manageScheduled);
    return auth.when(
      success: (_) {
        _ds.upsertScheduled(s);
        return Success(s);
      },
      failure: (m) => Failure(m),
    );
  }

  Result<void> cancel(String id) {
    final auth = _guard.require(Permission.manageScheduled);
    return auth.when(
      success: (_) {
        _ds.removeScheduled(id);
        return const Success(null);
      },
      failure: (m) => Failure(m),
    );
  }

  Result<int> runDueNow({DateTime? now}) {
    final auth = _guard.require(Permission.manageScheduled);
    return auth.when(
      success: (_) {
        final due = _ds.getDueScheduled(now ?? DateTime.now());
        var executed = 0;

        for (final s in due) {
          if (!s.isActive) continue;

          final res = _submit(
            fromAccountId: s.fromAccountId,
            toAccountId: s.toAccountId,
            type: s.type,
            amount: s.amount,
          );

          res.when(
            success: (_) {
              executed++;

              if (s.frequency == ScheduleFrequency.once) {
                _ds.removeScheduled(s.id);
                return;
              }

              final next = _nextRun(s);
              final updated = s.copyWith(nextRunAt: next);
              _ds.upsertScheduled(updated);
            },
            failure: (_) {
            },
          );

        }

        return Success(executed);
      },
      failure: (m) => Failure(m),
    );
  }

  DateTime _nextRun(ScheduledTransactionEntity s) {
    final t = s.nextRunAt;

    return switch (s.frequency) {
      ScheduleFrequency.once => t,
      ScheduleFrequency.daily => t.add(const Duration(days: 1)),
      ScheduleFrequency.weekly => t.add(const Duration(days: 7)),
      ScheduleFrequency.monthly => DateTime(t.year, t.month + 1, t.day, t.hour, t.minute),
    };
  }
}

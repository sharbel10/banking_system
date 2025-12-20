import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/di/injection.dart';
import '../../../../banking/domain/entities/account_entity.dart';
import '../../../../banking/domain/entities/account_state.dart';
import '../../../../banking/domain/entities/transaction_entity.dart';
import '../../../../banking/patterns/facade/banking_facade.dart';


class ManagerReportsPage extends StatefulWidget {
  const ManagerReportsPage({super.key});

  @override
  State<ManagerReportsPage> createState() => _ManagerReportsPageState();
}

class _ManagerReportsPageState extends State<ManagerReportsPage> {
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final facade = sl<BankingFacade>();

    final allTx = facade.getTransactions();
    final allAccounts = facade.getAccounts();

    final dailyTx = _filterByDay(allTx, _selectedDay);

    final dailyTotalAmount = dailyTx.fold<double>(0, (sum, t) => sum + t.amount);
    final dailyApproved = dailyTx.where((t) => t.status == TransactionStatus.approved).length;
    final dailyPending = dailyTx.where((t) => t.status == TransactionStatus.pending).length;
    final dailyRejected = dailyTx.where((t) => t.status == TransactionStatus.rejected).length;

    final totalBalance = allAccounts.fold<double>(0, (sum, a) => sum + a.balance);

    final byType = <AccountType, int>{};
    for (final a in allAccounts) {
      byType[a.type] = (byType[a.type] ?? 0) + 1;
    }

    final byState = <AccountState, int>{};
    for (final a in allAccounts) {
      byState[a.state] = (byState[a.state] ?? 0) + 1;
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reports'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.go('/staff/manager'),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.receipt_long_rounded), text: 'Daily'),
              Tab(icon: Icon(Icons.pie_chart_rounded), text: 'Summary'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // ----------------------------
            // Daily Transactions
            // ----------------------------
            ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _SectionTitle(
                  title: 'Daily Transactions',
                  subtitle: 'Filter transactions by day and view totals.',
                  icon: Icons.calendar_month_rounded,
                ),
                const SizedBox(height: 12),

                _DatePickerCard(
                  selected: _selectedDay,
                  onPick: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDay,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setState(() => _selectedDay = picked);
                  },
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        title: 'Transactions',
                        value: '${dailyTx.length}',
                        icon: Icons.swap_vert_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MetricCard(
                        title: 'Total Amount',
                        value: '\$${dailyTotalAmount.toStringAsFixed(2)}',
                        icon: Icons.attach_money_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _MiniMetric(
                        label: 'Approved',
                        value: '$dailyApproved',
                        icon: Icons.verified_rounded,
                        accent: cs.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MiniMetric(
                        label: 'Pending',
                        value: '$dailyPending',
                        icon: Icons.hourglass_top_rounded,
                        accent: cs.secondary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MiniMetric(
                        label: 'Rejected',
                        value: '$dailyRejected',
                        icon: Icons.close_rounded,
                        accent: cs.error,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                if (dailyTx.isEmpty)
                  Text(
                    'No transactions found for this day.',
                    style: TextStyle(color: cs.onSurface.withOpacity(0.65)),
                  )
                else ...[
                  _Subheader('Transactions List'),
                  const SizedBox(height: 10),
                  ...dailyTx.map((t) => _TxCard(tx: t)),
                ],
              ],
            ),

            // ----------------------------
            // Account Summary
            // ----------------------------
            ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _SectionTitle(
                  title: 'Account Summary',
                  subtitle: 'Overview of accounts by type, state, and balances.',
                  icon: Icons.assessment_rounded,
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        title: 'Accounts',
                        value: '${allAccounts.length}',
                        icon: Icons.account_balance_wallet_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MetricCard(
                        title: 'Total Balance',
                        value: '\$${totalBalance.toStringAsFixed(2)}',
                        icon: Icons.savings_rounded,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                _Subheader('By Account Type'),
                const SizedBox(height: 10),
                ...byType.entries.map(
                      (e) => _KeyValueRow(
                    label: e.key.name,
                    value: '${e.value}',
                  ),
                ),

                const SizedBox(height: 16),

                _Subheader('By Account State'),
                const SizedBox(height: 10),
                ...byState.entries.map(
                      (e) => _KeyValueRow(
                    label: e.key.label,
                    value: '${e.value}',
                  ),
                ),

                const SizedBox(height: 16),

                _Subheader('Accounts List'),
                const SizedBox(height: 10),
                ...allAccounts.map((a) => _AccountCard(a: a)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<TransactionEntity> _filterByDay(List<TransactionEntity> list, DateTime day) {
    bool sameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;

    return list.where((t) => sameDay(t.createdAt, day)).toList();
  }
}

// ----------------------------
// UI helpers
// ----------------------------

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.primary.withOpacity(0.10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: cs.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(color: cs.onSurface.withOpacity(0.65), height: 1.25),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DatePickerCard extends StatelessWidget {
  final DateTime selected;
  final VoidCallback onPick;

  const _DatePickerCard({required this.selected, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final label = '${selected.year}-${selected.month.toString().padLeft(2, '0')}-${selected.day.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.onSurface.withOpacity(0.10)),
      ),
      child: Row(
        children: [
          const Icon(Icons.event_rounded),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Selected day: $label',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          OutlinedButton.icon(
            onPressed: onPick,
            icon: const Icon(Icons.edit_calendar_rounded, size: 18),
            label: const Text('Change'),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.onSurface.withOpacity(0.10)),
      ),
      child: Row(
        children: [
          Icon(icon, color: cs.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: cs.onSurface.withOpacity(0.65))),
                const SizedBox(height: 6),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  const _MiniMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.onSurface.withOpacity(0.10)),
      ),
      child: Row(
        children: [
          Icon(icon, color: accent),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: cs.onSurface.withOpacity(0.65), fontSize: 12)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Subheader extends StatelessWidget {
  final String text;
  const _Subheader(this.text);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w900,
        color: cs.onSurface.withOpacity(0.88),
      ),
    );
  }
}

class _TxCard extends StatelessWidget {
  final TransactionEntity tx;
  const _TxCard({required this.tx});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final status = tx.status.name.toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.onSurface.withOpacity(0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${tx.type.name.toUpperCase()} • \$${tx.amount.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            'From: ${tx.accountId}${tx.toAccountId == null ? '' : ' → ${tx.toAccountId}'}',
            style: TextStyle(color: cs.onSurface.withOpacity(0.72)),
          ),
          const SizedBox(height: 6),
          Text(
            'Status: $status',
            style: TextStyle(color: cs.onSurface.withOpacity(0.65)),
          ),
          const SizedBox(height: 6),
          Text(
            'Time: ${tx.createdAt}',
            style: TextStyle(color: cs.onSurface.withOpacity(0.55), fontSize: 12),
          ),
          if ((tx.note ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              tx.note!,
              style: TextStyle(color: cs.onSurface.withOpacity(0.65), fontSize: 12, height: 1.25),
            ),
          ],
        ],
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  final AccountEntity a;
  const _AccountCard({required this.a});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.onSurface.withOpacity(0.10)),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_balance_wallet_rounded),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.ownerName, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(
                  '${a.id} • ${a.type.name}',
                  style: TextStyle(color: cs.onSurface.withOpacity(0.70)),
                ),
                const SizedBox(height: 6),
                _StateChip(a.state),
              ],
            ),
          ),
          Text(
            '\$${a.balance.toStringAsFixed(2)}',
            style: TextStyle(fontWeight: FontWeight.w900, color: cs.primary),
          ),
        ],
      ),
    );
  }
}

class _StateChip extends StatelessWidget {
  final AccountState state;
  const _StateChip(this.state);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.onSurface.withOpacity(0.08)),
      ),
      child: Text(
        state.label,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: cs.onSurface.withOpacity(0.85),
          fontSize: 12,
        ),
      ),
    );
  }
}

class _KeyValueRow extends StatelessWidget {
  final String label;
  final String value;

  const _KeyValueRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.onSurface.withOpacity(0.10)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
          Text(value, style: TextStyle(fontWeight: FontWeight.w900, color: cs.primary)),
        ],
      ),
    );
  }
}

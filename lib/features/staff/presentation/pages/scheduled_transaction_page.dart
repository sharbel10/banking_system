import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../banking/domain/entities/transaction_entity.dart';
import '../../../banking/domain/entities/scheduled_transaction_entity.dart';
import '../../../banking/patterns/facade/banking_facade.dart';

class ScheduledTransactionsPage extends StatefulWidget {
  const ScheduledTransactionsPage({super.key});

  @override
  State<ScheduledTransactionsPage> createState() => _ScheduledTransactionsPageState();
}

class _ScheduledTransactionsPageState extends State<ScheduledTransactionsPage> {
  String? _fromId;
  String? _toId;
  TransactionType _type = TransactionType.transfer;
  ScheduleFrequency _freq = ScheduleFrequency.monthly;

  final _amountCtrl = TextEditingController();
  DateTime _nextRun = DateTime.now().add(const Duration(minutes: 1));

  String? _message;

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final facade = sl<BankingFacade>();

    final accounts = facade.getAccounts();
    final scheduled = facade.getScheduled();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scheduled Payments'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/staff/teller'),
        ),
        actions: [
          IconButton(
            tooltip: 'Run due now',
            icon: const Icon(Icons.play_circle_rounded),
            onPressed: () {
              final res = facade.runScheduledDueNow();
              res.when(
                success: (count) => setState(() => _message = 'Executed: $count'),
                failure: (m) => setState(() => _message = m),
              );
            },
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SectionTitle('Create scheduled transaction'),
          const SizedBox(height: 10),

          _Card(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<TransactionType>(
                value: _type,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: TransactionType.deposit, child: Text('Deposit')),
                  DropdownMenuItem(value: TransactionType.withdraw, child: Text('Withdraw')),
                  DropdownMenuItem(value: TransactionType.transfer, child: Text('Transfer')),
                ],
                onChanged: (v) => v == null ? null : setState(() => _type = v),
              ),
            ),
          ),
          const SizedBox(height: 12),

          _Card(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _fromId,
                isExpanded: true,
                hint: const Text('From account'),
                items: accounts
                    .map((a) => DropdownMenuItem(
                  value: a.id,
                  child: Text('${a.ownerName} • ${a.id}'),
                ))
                    .toList(),
                onChanged: (v) => setState(() => _fromId = v),
              ),
            ),
          ),

          if (_type == TransactionType.transfer) ...[
            const SizedBox(height: 12),
            _Card(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _toId,
                  isExpanded: true,
                  hint: const Text('To account'),
                  items: accounts
                      .where((a) => a.id != _fromId)
                      .map((a) => DropdownMenuItem(
                    value: a.id,
                    child: Text('${a.ownerName} • ${a.id}'),
                  ))
                      .toList(),
                  onChanged: (v) => setState(() => _toId = v),
                ),
              ),
            ),
          ],

          const SizedBox(height: 12),
          TextField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Amount',
              filled: true,
              fillColor: cs.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),

          const SizedBox(height: 12),
          _Card(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<ScheduleFrequency>(
                value: _freq,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: ScheduleFrequency.once, child: Text('Once')),
                  DropdownMenuItem(value: ScheduleFrequency.daily, child: Text('Daily')),
                  DropdownMenuItem(value: ScheduleFrequency.weekly, child: Text('Weekly')),
                  DropdownMenuItem(value: ScheduleFrequency.monthly, child: Text('Monthly')),
                ],
                onChanged: (v) {
                  if (v == null) return;
                  setState(() {
                    _freq = v;
                    _nextRun = _calcNextRunFromNow(v);
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 12),
          _Card(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_available_rounded),
              title: const Text('Next run'),
              subtitle: Text(_nextRun.toString()),
            ),
          ),

          const SizedBox(height: 12),
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add_circle_rounded),
              label: const Text('Create'),
              onPressed: () {
                final from = _fromId;
                final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;

                if (from == null) {
                  setState(() => _message = 'Select from account');
                  return;
                }

                final s = ScheduledTransactionEntity(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  fromAccountId: from,
                  toAccountId: _type == TransactionType.transfer ? _toId : null,
                  type: _type,
                  amount: amount,
                  nextRunAt: _nextRun,
                  frequency: _freq,
                  isActive: true,
                );

                final res = facade.createScheduled(s);
                res.when(
                  success: (_) => setState(() => _message = 'Scheduled created'),
                  failure: (m) => setState(() => _message = m),
                );
              },
            ),
          ),

          if (_message != null) ...[
            const SizedBox(height: 12),
            _Msg(_message!),
          ],

          const SizedBox(height: 22),
          _SectionTitle('Scheduled list'),
          const SizedBox(height: 10),

          if (scheduled.isEmpty)
            Text('No scheduled transactions yet.',
                style: TextStyle(color: cs.onSurface.withOpacity(0.65)))
          else
            ...scheduled.map(
                  (s) => _ScheduledCard(
                s: s,
                onCancel: () {
                  final r = facade.cancelScheduled(s.id);
                  r.when(
                    success: (_) => setState(() => _message = 'Cancelled'),
                    failure: (m) => setState(() => _message = m),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _ScheduledCard extends StatelessWidget {
  final ScheduledTransactionEntity s;
  final VoidCallback onCancel;

  const _ScheduledCard({required this.s, required this.onCancel});

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
          const Icon(Icons.schedule_rounded),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${s.type.name.toUpperCase()} • \$${s.amount}',
                    style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(
                  'From: ${s.fromAccountId}${s.toAccountId == null ? '' : ' → ${s.toAccountId}'}',
                  style: TextStyle(color: cs.onSurface.withOpacity(0.7)),
                ),
                const SizedBox(height: 4),
                Text(
                  'Next: ${s.nextRunAt} • ${s.frequency.name}',
                  style: TextStyle(color: cs.onSurface.withOpacity(0.7)),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Cancel',
            onPressed: onCancel,
            icon: Icon(Icons.cancel_rounded, color: cs.error),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15));
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.onSurface.withOpacity(0.10)),
      ),
      child: child,
    );
  }
}

class _Msg extends StatelessWidget {
  final String m;
  const _Msg(this.m);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.onSurface.withOpacity(0.08)),
      ),
      child: Text(m, style: TextStyle(color: cs.onSurface.withOpacity(0.8))),
    );
  }
}
DateTime _calcNextRunFromNow(ScheduleFrequency f) {
  final now = DateTime.now();
  switch (f) {
    case ScheduleFrequency.once:
      return now;
    case ScheduleFrequency.daily:
      return now.add(const Duration(days: 1));
    case ScheduleFrequency.weekly:
      return now.add(const Duration(days: 7));
    case ScheduleFrequency.monthly:
      return DateTime(now.year, now.month + 1, now.day, now.hour, now.minute);
  }
}


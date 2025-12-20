import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/di/injection.dart';
import '../../../../banking/domain/entities/transaction_entity.dart';
import '../../../../banking/patterns/facade/banking_facade.dart';

class ManagerInboxPage extends StatefulWidget {
  const ManagerInboxPage({super.key});

  @override
  State<ManagerInboxPage> createState() => _ManagerInboxPageState();
}

class _ManagerInboxPageState extends State<ManagerInboxPage> {
  String? _message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final facade = sl<BankingFacade>();

    final pending = facade.getPendingApprovals();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manager Inbox'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/staff/manager'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.onSurface.withOpacity(0.08)),
            ),
            child: Text(
              'Pending approvals: ${pending.length}',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          if (_message != null) ...[
            const SizedBox(height: 12),
            _Msg(_message!),
          ],
          const SizedBox(height: 16),

          if (pending.isEmpty)
            Text(
              'No pending transactions.',
              style: TextStyle(color: cs.onSurface.withOpacity(0.65)),
            )
          else
            ...pending.map(
                  (tx) => _PendingCard(
                tx: tx,
                onApprove: () {
                  final res = facade.managerApprove(tx.id);
                  res.when(
                    success: (_) => setState(() => _message = 'Approved: ${tx.id}'),
                    failure: (m) => setState(() => _message = m),
                  );
                  setState(() {});
                },
                onReject: () async {
                  final reason = await _askReason(context);
                  if (reason == null) return;

                  final res = facade.managerReject(tx.id, reason: reason);
                  res.when(
                    success: (_) => setState(() => _message = 'Rejected: ${tx.id}'),
                    failure: (m) => setState(() => _message = m),
                  );
                  setState(() {});
                },
              ),
            ),
        ],
      ),
    );
  }

  Future<String?> _askReason(BuildContext context) async {
    final ctrl = TextEditingController();
    final res = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reject reason'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'Optional reason...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    return res;
  }
}

class _PendingCard extends StatelessWidget {
  final TransactionEntity tx;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _PendingCard({
    required this.tx,
    required this.onApprove,
    required this.onReject,
  });

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${tx.type.name.toUpperCase()} • \$${tx.amount}',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            'From: ${tx.accountId}${tx.toAccountId == null ? '' : ' → ${tx.toAccountId}'}',
            style: TextStyle(color: cs.onSurface.withOpacity(0.72)),
          ),
          const SizedBox(height: 6),
          Text(
            'ID: ${tx.id}',
            style: TextStyle(color: cs.onSurface.withOpacity(0.65)),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('Reject'),
                  onPressed: onReject,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.verified_rounded),
                  label: const Text('Approve'),
                  onPressed: onApprove,
                ),
              ),
            ],
          ),
        ],
      ),
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

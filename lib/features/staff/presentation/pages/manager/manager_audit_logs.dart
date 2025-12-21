import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/di/injection.dart';
import '../../../../banking/domain/entities/audit_log_entity.dart';
import '../../../../banking/patterns/facade/banking_facade.dart';

class ManagerAuditLogsPage extends StatelessWidget {
  const ManagerAuditLogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final facade = sl<BankingFacade>();
    final logs = facade.getAuditLogs();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Logs'),
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
              'Total logs: ${logs.length}',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(height: 16),
          if (logs.isEmpty)
            Text(
              'No audit logs yet.',
              style: TextStyle(color: cs.onSurface.withOpacity(0.65)),
            )
          else
            ...logs.map((e) => _LogCard(e)),
        ],
      ),
    );
  }
}

class _LogCard extends StatelessWidget {
  final AuditLogEntity e;
  const _LogCard(this.e);

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
            '${e.action.name.toUpperCase()} • ${e.actor}',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            e.message,
            style: TextStyle(color: cs.onSurface.withOpacity(0.75), height: 1.25),
          ),
          const SizedBox(height: 8),
          Text(
            e.at.toString(),
            style: TextStyle(color: cs.onSurface.withOpacity(0.55), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

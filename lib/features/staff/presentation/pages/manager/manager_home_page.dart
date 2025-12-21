import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ManagerHomePage extends StatelessWidget {
  const ManagerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manager'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/staff/dashboard'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _ActionCard(
              title: 'Manager Inbox',
              subtitle: 'Approve / Reject pending transactions',
              icon: Icons.inbox_rounded,
              onTap: () => context.go('/staff/manager/inbox'),
            ),
            const SizedBox(height: 12),
            _ActionCard(
              title: 'Manage Accounts',
              subtitle: 'Freeze / Activate / Suspend / Close accounts',
              icon: Icons.manage_accounts_rounded,
              onTap: () => context.go('/staff/manager/accounts'),
            ),
            const SizedBox(height: 12),
            _ActionCard(
              title: 'Reports',
              subtitle: 'Daily transactions & account summary',
              icon: Icons.receipt_long_rounded,
              onTap: () => context.go('/staff/manager/reports'),
            ),
            const SizedBox(height: 12),
            _ActionCard(
              title: 'Audit Logs',
              subtitle: 'Track actions: approvals, state changes, scheduling...',
              icon: Icons.list_alt_rounded,
              onTap: () => context.go('/staff/manager/audit'),
            ),


          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cs.onSurface.withOpacity(0.10)),
        ),
        child: Row(
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
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: cs.onSurface.withOpacity(0.65)),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: cs.onSurface.withOpacity(0.55)),
          ],
        ),
      ),
    );
  }
}

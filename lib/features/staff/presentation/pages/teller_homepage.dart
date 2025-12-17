import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TellerHomePage extends StatelessWidget {
  const TellerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teller'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/staff/dashboard'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _HeaderCard(
              title: 'Teller Operations',
              subtitle: 'Create transactions and manage customer accounts (demo).',
              icon: Icons.badge_rounded,
              tint: cs.primary.withOpacity(0.10),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ListView(
                children: [
                  _ActionTile(
                    title: 'New Transaction',
                    subtitle: 'Deposit / Withdraw / Transfer + Approval chain',
                    icon: Icons.swap_horiz_rounded,
                    accent: cs.primary,
                    onTap: () => context.go('/staff/teller/new-transaction'),
                    enabled: true,
                  ),
                  const SizedBox(height: 12),
                  _ActionTile(
                    title: 'Scheduled Payments',
                    subtitle: 'Create recurring transactions + Run due now (demo)',
                    icon: Icons.schedule_rounded,
                    accent: cs.tertiary,
                    onTap: () => context.go('/staff/teller/scheduled'),
                    enabled: true,
                  ),
                  const SizedBox(height: 12),
                  _ActionTile(
                    title: 'Open Account',
                    subtitle: 'Factory Method (UI only for now)',
                    icon: Icons.add_card_rounded,
                    accent: cs.secondary,
                    onTap: () {},
                    enabled: false,
                  ),
                  const SizedBox(height: 12),
                  _ActionTile(
                    title: 'Search Customer',
                    subtitle: 'Find customer by name / account (UI only)',
                    icon: Icons.search_rounded,
                    accent: cs.primary,
                    onTap: () {},
                    enabled: false,
                  ),
                  const SizedBox(height: 12),
                  _ActionTile(
                    title: 'Customer Accounts',
                    subtitle: 'View accounts + balances (UI only)',
                    icon: Icons.account_balance_wallet_rounded,
                    accent: cs.primary,
                    onTap: () {},
                    enabled: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color tint;

  const _HeaderCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tint,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.onSurface.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surface.withOpacity(0.8),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cs.onSurface.withOpacity(0.08)),
            ),
            child: Icon(icon, color: cs.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text(subtitle, style: TextStyle(color: cs.onSurface.withOpacity(0.72))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;
  final bool enabled;

  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: cs.onSurface.withOpacity(0.08)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 6),
                      Text(subtitle, style: TextStyle(color: cs.onSurface.withOpacity(0.70))),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  enabled ? Icons.arrow_forward_rounded : Icons.lock_rounded,
                  color: cs.onSurface.withOpacity(0.45),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:banking_system/features/customer/data/models/transaction_model.dart';
import 'package:banking_system/features/customer/patterns/facade/customer_facade_mock.dart';
import 'package:banking_system/features/customer/presentation/bloc/home/customer_home_bloc.dart';
import 'package:banking_system/features/customer/presentation/bloc/home/customer_home_event.dart';
import 'package:banking_system/features/customer/presentation/bloc/home/customer_home_state.dart';
import 'package:banking_system/features/customer/presentation/pages/contact_support_page.dart';
import 'package:banking_system/features/customer/presentation/pages/notifications_page.dart';
import 'package:banking_system/features/customer/presentation/pages/view_accounts_page.dart';
import 'package:banking_system/features/customer/presentation/pages/view_transactions_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/session/session_cubit.dart';

class CustomerHomePage extends StatelessWidget {
  const CustomerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionState = context.read<SessionCubit>().state;
    String customerId = 'demo-customer';

    return BlocProvider(
      create: (_) =>
          CustomerHomeBloc(facade: CustomerFacadeMock())
            ..add(LoadCustomerHome(customerId)),
      child: const _CustomerHomeView(),
    );
  }
}

class _CustomerHomeView extends StatelessWidget {
  const _CustomerHomeView();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () {
            context.read<SessionCubit>().reset();
            context.go('/role');
          },
          icon: Icon(Icons.logout_rounded, color: cs.onSurface),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => NotificationsPage()),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _HeaderCard(
              title: 'Welcome back',
              subtitle: 'Overview of your accounts and recent activity.',
              icon: Icons.account_balance_wallet_rounded,
              tint: cs.primary.withOpacity(0.10),
            ),
            const SizedBox(height: 16),

            BlocBuilder<CustomerHomeBloc, CustomerHomeState>(
              builder: (context, state) {
                if (state is CustomerHomeLoading) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (state is CustomerHomeLoaded) {
                  final total = state.accounts.fold<double>(
                    0,
                    (p, a) => p + a.balance,
                  );
                  return _SummaryCard(totalBalance: total);
                } else if (state is CustomerHomeError) {
                  return Text(
                    'Error: ${state.message}',
                    style: TextStyle(color: cs.error),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),

            const SizedBox(height: 16),

            Expanded(
              child: ListView(
                children: [
                  _ActionTile(
                    title: 'View Accounts',
                    subtitle: 'See balances & details',
                    icon: Icons.account_balance_rounded,
                    accent: cs.primary,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ViewAccountsPage(),
                      ),
                    ),
                    enabled: true,
                  ),
                  const SizedBox(height: 12),
                  _ActionTile(
                    title: 'View Transactions',
                    subtitle: 'Recent activity & statuses',
                    icon: Icons.swap_vert_rounded,
                    accent: cs.secondary,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ViewTransactionsPage(),
                      ),
                    ),
                    enabled: true,
                  ),
                  const SizedBox(height: 12),

                  _ActionTile(
                    title: 'Contact Support',
                    subtitle: 'Create / view support tickets',
                    icon: Icons.headset_mic_rounded,
                    accent: cs.primary,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ContactSupportPage(),
                      ),
                    ),
                    enabled: true,
                  ),
                  const SizedBox(height: 22),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Recent activity',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                  BlocBuilder<CustomerHomeBloc, CustomerHomeState>(
                    builder: (context, state) {
                      if (state is CustomerHomeLoaded) {
                        final recent = state.recentTransactions;
                        if (recent.isEmpty) {
                          return Text(
                            'No recent transactions',
                            style: TextStyle(
                              color: cs.onSurface.withOpacity(0.6),
                            ),
                          );
                        }
                        return Column(
                          children: recent
                              .map((t) => _TransactionTile(txn: t))
                              .toList(),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  const SizedBox(height: 40),
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
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(color: cs.onSurface.withOpacity(0.72)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final double totalBalance;
  const _SummaryCard({required this.totalBalance});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.onSurface.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total balance',
                style: TextStyle(color: cs.onSurface.withOpacity(0.7)),
              ),
              const SizedBox(height: 8),
              Text(
                '\$${totalBalance.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: TextStyle(color: cs.onSurface.withOpacity(0.70)),
                      ),
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

class _TransactionTile extends StatelessWidget {
  final TransactionModel txn;
  const _TransactionTile({required this.txn});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final statusColor = txn.status == 'Approved'
        ? Colors.green
        : (txn.status == 'Pending' ? Colors.orange : cs.onSurface);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.onSurface.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          CircleAvatar(child: Text(txn.type[0].toUpperCase())),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn.description,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  txn.date,
                  style: TextStyle(
                    color: cs.onSurface.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${txn.amount.toStringAsFixed(2)}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                txn.status,
                style: TextStyle(color: statusColor, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

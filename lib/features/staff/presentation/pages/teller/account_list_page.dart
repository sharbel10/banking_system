import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/di/injection.dart';
import '../../../../banking/domain/entities/account_entity.dart';
import '../../../../banking/patterns/facade/banking_facade.dart';

class AccountsListPage extends StatelessWidget {
  const AccountsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final facade = sl<BankingFacade>();
    final accounts = facade.getAccounts();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/staff/teller'),
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
              'Total accounts: ${accounts.length}',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(height: 16),
          ...accounts.map((a) => _AccountCard(a)),
        ],
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  final AccountEntity a;
  const _AccountCard(this.a);

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

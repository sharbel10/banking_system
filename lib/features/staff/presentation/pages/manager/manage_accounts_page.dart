import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/di/injection.dart';
import '../../../../banking/domain/entities/account_entity.dart';
import '../../../../banking/patterns/state/account_state.dart';
import '../../../../banking/patterns/facade/banking_facade.dart';

class ManagerAccountsPage extends StatefulWidget {
  const ManagerAccountsPage({super.key});

  @override
  State<ManagerAccountsPage> createState() => _ManagerAccountsPageState();
}

class _ManagerAccountsPageState extends State<ManagerAccountsPage> {
  String? _msg;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final facade = sl<BankingFacade>();
    final accounts = facade.getAccounts();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Accounts'),
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
              'Total accounts: ${accounts.length}',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          if (_msg != null) ...[
            const SizedBox(height: 12),
            _Msg(_msg!),
          ],
          const SizedBox(height: 16),
          ...accounts.map((a) => _ManagerAccountCard(
            a: a,
            onChangeState: (state) {
              final res = facade.managerChangeAccountState(
                accountId: a.id,
                newState: state,
              );

              res.when(
                success: (_) => setState(() => _msg = 'Updated ${a.id} → ${state.label}'),
                failure: (m) => setState(() => _msg = m),
              );

              setState(() {}); // refresh
            },
          )),
        ],
      ),
    );
  }
}

class _ManagerAccountCard extends StatelessWidget {
  final AccountEntity a;
  final void Function(AccountState state) onChangeState;

  const _ManagerAccountCard({
    required this.a,
    required this.onChangeState,
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
          PopupMenuButton<AccountState>(
            icon: const Icon(Icons.tune_rounded),
            onSelected: onChangeState,
            itemBuilder: (_) => const [
              PopupMenuItem(value: AccountState.active, child: Text('Set Active')),
              PopupMenuItem(value: AccountState.frozen, child: Text('Freeze')),
              PopupMenuItem(value: AccountState.suspended, child: Text('Suspend')),
              PopupMenuItem(value: AccountState.closed, child: Text('Close')),
            ],
          ),
          const SizedBox(width: 8),
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

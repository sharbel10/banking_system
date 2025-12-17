import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../banking/domain/entities/transaction_entity.dart';
import '../bloc/new_transaction_cubit.dart';

class NewTransactionPage extends StatefulWidget {
  const NewTransactionPage({super.key});

  @override
  State<NewTransactionPage> createState() => _NewTransactionPageState();
}

class _NewTransactionPageState extends State<NewTransactionPage> {
  final _amountCtrl = TextEditingController();

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocProvider(
      create: (_) => sl<NewTransactionCubit>()..init(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('New Transaction'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.go('/staff/teller'),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: BlocBuilder<NewTransactionCubit, NewTransactionState>(
              builder: (context, state) {
                final cubit = context.read<NewTransactionCubit>();
          
                return Column(
                  children: [
                    // Type
                    _Card(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<TransactionType>(
                          value: state.type,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(
                              value: TransactionType.deposit,
                              child: Text('Deposit'),
                            ),
                            DropdownMenuItem(
                              value: TransactionType.withdraw,
                              child: Text('Withdraw'),
                            ),
                            DropdownMenuItem(
                              value: TransactionType.transfer,
                              child: Text('Transfer'),
                            ),
                          ],
                          onChanged: (v) => v == null ? null : cubit.setType(v),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
          
                    // From account
                    _Card(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: state.selectedFromId,
                          isExpanded: true,
                          hint: const Text('Select account'),
                          items: state.accounts
                              .map((a) => DropdownMenuItem(
                            value: a.id,
                            child: Text('${a.ownerName} • ${a.id}'),
                          ))
                              .toList(),
                          onChanged: (v) => v == null ? null : cubit.selectFrom(v),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
          
                    // Balance (from)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cs.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: cs.onSurface.withOpacity(0.08)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.account_balance_wallet_rounded, color: cs.primary),
                          const SizedBox(width: 10),
                          const Text('Balance', style: TextStyle(fontWeight: FontWeight.w800)),
                          const Spacer(),
                          Text(
                            '\$${state.fromBalance.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: cs.primary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
          
                    // To account (only for transfer)
                    if (state.type == TransactionType.transfer) ...[
                      const SizedBox(height: 12),
                      _Card(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: state.selectedToId,
                            isExpanded: true,
                            hint: const Text('Select destination account'),
                            items: state.accounts
                                .where((a) => a.id != state.selectedFromId)
                                .map((a) => DropdownMenuItem(
                              value: a.id,
                              child: Text('${a.ownerName} • ${a.id}'),
                            ))
                                .toList(),
                            onChanged: (v) => v == null ? null : cubit.selectTo(v),
                          ),
                        ),
                      ),
                    ],
          
                    const SizedBox(height: 12),
          
                    // Amount
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
          
                    const SizedBox(height: 14),
          
                    // Submit
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: state.loading
                            ? null
                            : () {
                          final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
                          cubit.submit(amount);
                        },
                        icon: state.loading
                            ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : const Icon(Icons.check_circle_rounded),
                        label: Text(state.loading ? 'Processing...' : 'Submit'),
                      ),
                    ),
          
                    if (state.error != null)
                      _MessageCard(
                        icon: Icons.error_rounded,
                        title: 'Error',
                        subtitle: state.error!,
                        bg: cs.error.withOpacity(0.10),
                      ),
          
                    if (state.tx != null)
                      if (state.tx != null)
                        _MessageCard(
                          icon: state.tx!.status == TransactionStatus.pending
                              ? Icons.hourglass_top_rounded
                              : state.tx!.status == TransactionStatus.approved
                              ? Icons.verified_rounded
                              : Icons.block_rounded,
                          title: state.tx!.status.name.toUpperCase(),
                          subtitle: state.tx!.note ?? '',
                          bg: state.tx!.status == TransactionStatus.pending
                              ? Colors.amber.withOpacity(0.18)          // ✅ أصفر
                              : state.tx!.status == TransactionStatus.approved
                              ? cs.secondary.withOpacity(0.12)      // ✅ أخضر
                              : cs.error.withOpacity(0.10),         // ✅ أحمر
                        ),

                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
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

class _MessageCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color bg;

  const _MessageCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.onSurface.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text(subtitle, style: TextStyle(color: cs.onSurface.withOpacity(0.75))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

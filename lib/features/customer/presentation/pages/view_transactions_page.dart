import 'package:banking_system/core/di/injection.dart';
import 'package:banking_system/features/customer/data/models/transaction_model.dart';
import 'package:banking_system/features/customer/patterns/facade/customer_facade_mock.dart';
import 'package:banking_system/features/customer/presentation/bloc/transactions/transactions_bloc.dart';
import 'package:banking_system/features/customer/presentation/bloc/transactions/transactions_event.dart';
import 'package:banking_system/features/customer/presentation/bloc/transactions/transactions_state.dart';
import 'package:banking_system/features/customer/presentation/widgets/transactions_chain_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/session/session_cubit.dart';

class ViewTransactionsPage extends StatelessWidget {
  const ViewTransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionState = context.read<SessionCubit>().state;
    final customerId = 'demo-customer'; // أو اقرأ من sessionState

    return BlocProvider(
      create: (_) {
        final facade = sl<CustomerFacadeMock>();
        ;
        final bloc = TransactionsBloc(facade: facade);
        bloc.add(LoadTransactions(customerId));
        return bloc;
      },
      child: const _ViewTransactionsView(),
    );
  }
}

class _ViewTransactionsView extends StatelessWidget {
  const _ViewTransactionsView();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: BlocBuilder<TransactionsBloc, TransactionsState>(
          builder: (context, state) {
            if (state is TransactionsLoading)
              return const Center(child: CircularProgressIndicator());
            if (state is TransactionsError)
              return Center(
                child: Text(
                  'Error: ${state.message}',
                  style: TextStyle(color: cs.error),
                ),
              );
            if (state is TransactionsLoaded) {
              final txns = state.transactions;
              if (txns.isEmpty)
                return Center(
                  child: Text(
                    'No transactions',
                    style: TextStyle(color: cs.onSurface.withOpacity(0.6)),
                  ),
                );
              return ListView.separated(
                itemCount: txns.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final t = txns[i];
                  return _TransactionTile(txn: t);
                },
              );
            }
            if (state is TransactionsProcessing) {
              return const Center(child: CircularProgressIndicator());
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionModel txn;
  const _TransactionTile({required this.txn});

  Color _statusColor(BuildContext context) {
    if (txn.status.toLowerCase() == 'approved') return Colors.green;
    if (txn.status.toLowerCase() == 'pending') return Colors.orange;
    return Theme.of(context).colorScheme.onSurface;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // احصل على نفس الـ bloc من الـ context الحالي
          final transactionsBloc = context.read<TransactionsBloc>();

          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (sheetContext) {
              // نستخدم BlocProvider.value لنعطي الـ bottom sheet نفس instance
              return BlocProvider.value(
                value: transactionsBloc,
                child: DraggableScrollableSheet(
                  expand: false,
                  initialChildSize: 0.6,
                  minChildSize: 0.4,
                  maxChildSize: 0.95,
                  builder: (context2, controller) => Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(18),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Transaction ${txn.id}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ListTile(
                            title: Text(txn.description),
                            subtitle: Text(txn.date),
                            trailing: Text(
                              '\$${txn.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(child: TransactionChainWidget(txn: txn)),
                          const SizedBox(height: 12),

                          // هنا نحتفظ بنفس BlocConsumer كما كان لديك
                          BlocConsumer<TransactionsBloc, TransactionsState>(
                            listener: (context, state) {
                              if (state is TransactionsLoaded) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Transaction updated'),
                                  ),
                                );
                                Navigator.of(context).pop();
                              }
                              if (state is TransactionsError) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: ${state.message}'),
                                  ),
                                );
                              }
                            },
                            builder: (context, state) {
                              final processing =
                                  state is TransactionsProcessing &&
                                  state.txnId == txn.id;
                              final disabled =
                                  txn.status.toLowerCase() == 'pending' ||
                                  processing;

                              return Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: disabled
                                          ? null
                                          : () {
                                              context
                                                  .read<TransactionsBloc>()
                                                  .add(RerunChain(txn.id));
                                            },
                                      child: processing
                                          ? SizedBox(
                                              height: 18,
                                              width: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Text(
                                              'Re-run processing (simulate)',
                                            ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },

        child: Padding(
          padding: const EdgeInsets.all(12),
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
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    txn.status,
                    style: TextStyle(
                      color: _statusColor(context),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

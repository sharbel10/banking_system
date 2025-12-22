import 'package:banking_system/core/di/injection.dart';
import 'package:banking_system/features/customer/patterns/facade/customer_facade_mock.dart';
import 'package:banking_system/features/customer/presentation/bloc/account/account_bloc.dart';
import 'package:banking_system/features/customer/presentation/bloc/account/account_event.dart';
import 'package:banking_system/features/customer/presentation/bloc/account/account_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/session/session_cubit.dart';
import '../widgets/account_tree_widget.dart';
import '../../domain/entities/account_component.dart';

class ViewAccountsPage extends StatelessWidget {
  const ViewAccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionState = context.read<SessionCubit>().state;
    String customerId = 'demo-customer';
    return BlocProvider(
      create: (_) {
        final facade = sl<CustomerFacadeMock>();
        ;
        final bloc = AccountsBloc(facade: facade);
        bloc.add(LoadAccounts(customerId));
        return bloc;
      },
      child: const _ViewAccountsView(),
    );
  }
}

class _ViewAccountsView extends StatelessWidget {
  const _ViewAccountsView();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              final sessionState = context.read<SessionCubit>().state;
              final customerId = 'demo-customer';
              context.read<AccountsBloc>().add(RefreshAccounts(customerId));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocBuilder<AccountsBloc, AccountsState>(
          builder: (context, state) {
            if (state is AccountsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AccountsLoaded) {
              final AccountComponent root = state.root;
              return Column(
                children: [
                  Card(
                    child: ListTile(
                      title: Text(
                        root.name,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      trailing: Text(
                        '\$${root.getTotalBalance().toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      child: AccountTreeWidget(node: root, onTap: (acct) {}),
                    ),
                  ),
                ],
              );
            } else if (state is AccountsError) {
              return Center(
                child: Text(
                  'Error: ${state.message}',
                  style: TextStyle(color: cs.error),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

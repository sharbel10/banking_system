import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../patterns/facade/customer_facade_mock.dart';
import '../../../../core/session/session_cubit.dart';

class CustomerSelectAccountPage extends StatelessWidget {
  const CustomerSelectAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final facade = sl<CustomerFacadeMock>();

    return Scaffold(
      appBar: AppBar(title: const Text('Choose Customer')),
      body: FutureBuilder(
        future: facade.fetchAccountsFlat('demo'),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final accounts = snap.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: accounts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final a = accounts[i];
              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                tileColor: Theme.of(context).colorScheme.surface,
                title: Text(a.name, style: const TextStyle(fontWeight: FontWeight.w900)),
                subtitle: Text(a.id),
                trailing: Text('\$${a.balance.toStringAsFixed(2)}'),
                onTap: () {
                  context.read<SessionCubit>().setCustomerAccount(a.id);
                  context.go('/customer/home');
                },
              );
            },
          );
        },
      ),
    );
  }
}

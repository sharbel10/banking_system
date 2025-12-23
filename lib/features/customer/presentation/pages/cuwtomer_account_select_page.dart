import 'package:banking_system/features/customer/domain/entities/account_converter.dart';
import 'package:banking_system/features/customer/patterns/decorator/account_decorator_factory.dart';
import 'package:banking_system/features/customer/patterns/decorator/overdraft_decorator.dart';
import 'package:banking_system/features/customer/patterns/decorator/premium_decorator.dart';
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

          final rawAccounts = snap.data!;

          final accounts = rawAccounts
              .map(
                (m) => AccountDecoratorFactory.applyAllDecorators(
                  AccountConverter.modelToEntity(m),
                ),
              )
              .toList();

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: accounts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final a = accounts[i];

              final isPremium =
                  AccountDecoratorFactory.hasDecorator<PremiumDecorator>(a);

              final hasOverdraft =
                  AccountDecoratorFactory.hasDecorator<OverdraftDecorator>(a);

              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                tileColor: Theme.of(context).colorScheme.surface,
                title: Text(
                  a.ownerName,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: Text(a.id),
                trailing: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${a.balance.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    if (isPremium)
                      _Badge(
                        label: 'Premium',
                        color: Colors.amber,
                        icon: Icons.star,
                      ),
                    if (!isPremium && hasOverdraft)
                      _Badge(
                        label: 'Overdraft',
                        color: Colors.blue,
                        icon: Icons.credit_card,
                      ),
                  ],
                ),
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

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _Badge({required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

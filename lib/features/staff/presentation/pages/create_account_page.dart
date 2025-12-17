import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../banking/domain/entities/account_entity.dart';
import '../../../banking/patterns/facade/banking_facade.dart';
import '../../../banking/patterns/factories/account_factory.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _nameCtrl = TextEditingController();
  final _balanceCtrl = TextEditingController();

  AccountType _type = AccountType.checking;
  String? _msg;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _balanceCtrl.dispose();
    super.dispose();
  }

  AccountFactory _factoryFor(AccountType t) {
    switch (t) {
      case AccountType.checking:
        return CheckingAccountFactory();
      case AccountType.savings:
        return SavingsAccountFactory();
      case AccountType.business:
        return BusinessAccountFactory();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final facade = sl<BankingFacade>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/staff/teller'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButtonFormField<AccountType>(
              value: _type,
              items: const [
                DropdownMenuItem(value: AccountType.checking, child: Text('Checking')),
                DropdownMenuItem(value: AccountType.savings, child: Text('Savings')),
                DropdownMenuItem(value: AccountType.business, child: Text('Business')),
              ],
              onChanged: (v) => v == null ? null : setState(() => _type = v),
              decoration: InputDecoration(
                labelText: 'Account type',
                filled: true,
                fillColor: cs.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: 'Owner name',
                filled: true,
                fillColor: cs.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _balanceCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Initial balance',
                filled: true,
                fillColor: cs.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_card_rounded),
                label: const Text('Create'),
                onPressed: () {
                  final name = _nameCtrl.text;
                  final bal = double.tryParse(_balanceCtrl.text.trim()) ?? 0;

                  final res = facade.createAccount(
                    factory: _factoryFor(_type),
                    ownerName: name,
                    initialBalance: bal,
                  );

                  res.when(
                    success: (acc) => setState(() => _msg = 'Created: ${acc.id} • ${acc.type.name}'),
                    failure: (m) => setState(() => _msg = m),
                  );
                },
              ),
            ),
            if (_msg != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cs.onSurface.withOpacity(0.08)),
                ),
                child: Text(_msg!, style: TextStyle(color: cs.onSurface.withOpacity(0.8))),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/di/injection.dart';
import '../../../../banking/domain/entities/account_entity.dart';
import '../../../../banking/patterns/facade/banking_facade.dart';
import '../../../../banking/patterns/factories/account_factory.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _nameCtrl = TextEditingController();
  final _balanceCtrl = TextEditingController();

  final _leafNameCtrl = TextEditingController();
  final _leafBalanceCtrl = TextEditingController();

  AccountType _type = AccountType.checking;

  String? _msg;
  String? _createdMainId;

  String? _leafMsg;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _balanceCtrl.dispose();
    _leafNameCtrl.dispose();
    _leafBalanceCtrl.dispose();
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              DropdownButtonFormField<AccountType>(
                value: _type,
                items: const [
                  DropdownMenuItem(
                    value: AccountType.checking,
                    child: Text('Checking'),
                  ),
                  DropdownMenuItem(
                    value: AccountType.savings,
                    child: Text('Savings'),
                  ),
                  DropdownMenuItem(
                    value: AccountType.business,
                    child: Text('Business'),
                  ),
                ],
                onChanged: (v) => v == null ? null : setState(() => _type = v),
                decoration: InputDecoration(
                  labelText: 'Account type',
                  filled: true,
                  fillColor: cs.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Owner name',
                  filled: true,
                  fillColor: cs.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
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
                      success: (acc) => setState(() {
                        _createdMainId = acc.id;
                        _msg = 'Created: ${acc.id} • ${acc.type.name}';
                        _leafMsg = null;
                        _leafNameCtrl.clear();
                        _leafBalanceCtrl.clear();
                      }),
                      failure: (m) => setState(() {
                        _msg = m;
                        _createdMainId = null;
                      }),
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
                  child: Text(
                    _msg!,
                    style: TextStyle(color: cs.onSurface.withOpacity(0.8)),
                  ),
                ),
              ],

              if (_createdMainId != null) ...[
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Create leaf account (sub-account)',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: cs.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _leafNameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Leaf name',
                    filled: true,
                    fillColor: cs.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _leafBalanceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Initial leaf balance',
                    filled: true,
                    fillColor: cs.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.account_tree_rounded),
                    label: const Text('Add Leaf'),
                    onPressed: () {
                      final leafName = _leafNameCtrl.text.trim();
                      final leafBal =
                          double.tryParse(_leafBalanceCtrl.text.trim()) ?? 0;

                      final res = facade.createSubAccount(
                        ownerMainAccountId: _createdMainId!,
                        name: leafName,
                        initialBalance: leafBal,
                      );

                      res.when(
                        success: (leaf) => setState(() {
                          _leafMsg = 'Leaf created: ${leaf.id} • ${leaf.name}';
                        }),
                        failure: (m) => setState(() {
                          _leafMsg = m;
                        }),
                      );
                    },
                  ),
                ),

                if (_leafMsg != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cs.secondary.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cs.onSurface.withOpacity(0.08)),
                    ),
                    child: Text(
                      _leafMsg!,
                      style: TextStyle(color: cs.onSurface.withOpacity(0.8)),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

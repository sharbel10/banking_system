import 'package:banking_system/features/banking/domain/entities/account_entity.dart';
import 'package:banking_system/features/banking/patterns/state/account_state.dart';
import 'package:banking_system/features/customer/domain/entities/account_leaf.dart';
import 'package:banking_system/features/customer/patterns/decorator/account_decorator.dart';
import 'package:banking_system/features/customer/patterns/decorator/account_decorator_factory.dart';
import 'package:banking_system/features/customer/patterns/decorator/overdraft_decorator.dart';
import 'package:banking_system/features/customer/patterns/decorator/premium_decorator.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/account_component.dart';
import '../../domain/entities/account_composite.dart';

typedef OnAccountTap = void Function(AccountComponent account);

class AccountTreeWidget extends StatelessWidget {
  final AccountComponent node;
  final OnAccountTap? onTap;
  final double indent;

  const AccountTreeWidget({
    required this.node,
    this.onTap,
    this.indent = 0.0,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!node.isComposite) {
      return _leafTile(context, node as AccountLeaf);
    }

    final composite = node as AccountComposite;
    return Padding(
      padding: EdgeInsets.only(left: indent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        title: Row(
          children: [
            Expanded(
              child: Text(
                node.name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              '\$${node.getTotalBalance().toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        subtitle: Text('Total: \$${node.getTotalBalance().toStringAsFixed(2)}'),
        children: composite.children
            .map(
              (c) =>
                  AccountTreeWidget(node: c, onTap: onTap, indent: indent + 8),
            )
            .toList(),
      ),
    );
  }

  debugPrintDecoratorChain(AccountEntity e) {
    AccountEntity current = e;
    final chain = <String>[];
    while (true) {
      chain.add(current.runtimeType.toString());
      if (current is AccountDecorator) {
        current = (current as AccountDecorator).inner;
      } else {
        break;
      }
    }
    print('Decorator chain for ${e.id}: ${chain.join(" -> ")}');
  }

  // account_tree_widget.dart (داخل _leafTile)
  Widget _leafTile(BuildContext context, AccountLeaf leaf) {
    // حاول الحصول على الـ entity الممرّر، وإلا إبني واحد مؤقت من بيانات الـ leaf
    AccountEntity entity;
    try {
      entity = leaf.entity;
    } catch (_) {
      // إذا الكلاس أصلاً لا يحمل entity، نركّب واحد مؤقت
      entity = AccountEntity(
        id: leaf.id,
        ownerName: leaf.name,
        balance: leaf.balance,
        type: AccountType
            .checking, // <-- اختر الافتراضي المناسب أو مرّر النوع من leaf إن وُجد
        state: AccountState.active, // <-- عدّل إن كنت تحفظ الحالة في leaf
      );
      entity = AccountDecoratorFactory.applyAllDecorators(entity);
    }

    // robust fallback: لو entity موجود لكنه غير مزخرف، نزخرفه هنا
    final decoratedEntity = AccountDecoratorFactory.applyAllDecorators(entity);

    // debug (اختياري)
    debugPrint(
      'UI Leaf ${leaf.id} -> decorated.runtimeType=${decoratedEntity.runtimeType}',
    );

    final bool isPremium =
        AccountDecoratorFactory.hasDecorator<PremiumDecorator>(decoratedEntity);
    final premium = AccountDecoratorFactory.extractDecorator<PremiumDecorator>(
      decoratedEntity,
    );

    final bool hasOverdraft =
        AccountDecoratorFactory.hasDecorator<OverdraftDecorator>(
          decoratedEntity,
        );
    final overdraft =
        AccountDecoratorFactory.extractDecorator<OverdraftDecorator>(
          decoratedEntity,
        );

    // ... بقية الشيفرة كما عندك لكن استبدل "entity" بـ "decoratedEntity" عند العرض

    final badges = <Widget>[];
    if (isPremium && premium != null) {
      badges.add(
        Chip(
          label: Text('Premium ${premium.premiumTier}'),
          avatar: const Icon(Icons.star, size: 16),
        ),
      );
    }
    if (hasOverdraft && overdraft != null) {
      badges.add(
        Chip(
          label: Text(
            'Overdraft \$${overdraft.overdraftLimit.toStringAsFixed(0)}',
          ),
          avatar: const Icon(Icons.account_balance_wallet, size: 16),
        ),
      );
    }

    return ListTile(
      contentPadding: EdgeInsets.only(left: indent + 12, right: 12),
      title: Text(leaf.name),
      subtitle: badges.isNotEmpty
          ? Wrap(spacing: 8, runSpacing: 4, children: badges)
          : null,
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '\$${leaf.getTotalBalance().toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          if (hasOverdraft && overdraft != null)
            Text(
              'Avail: \$${overdraft.availableBalance.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 12),
            ),
        ],
      ),
      onTap: () => onTap?.call(leaf),
    );
  }
}

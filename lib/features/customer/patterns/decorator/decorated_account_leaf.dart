import 'package:banking_system/features/banking/domain/entities/account_entity.dart';

import 'package:banking_system/features/customer/domain/entities/account_component.dart';
import 'package:banking_system/features/customer/patterns/decorator/account_decorator_factory.dart';
import 'package:banking_system/features/customer/patterns/decorator/overdraft_decorator.dart';
import 'package:banking_system/features/customer/patterns/decorator/premium_decorator.dart';
import 'package:flutter/material.dart';

/// ⭐ AccountLeaf مع دعم للديكوريتورات
class DecoratedAccountLeaf implements AccountComponent {
  final String id;
  final String name;
  final double balance;
  final String? parentId;
  final AccountEntity accountEntity;

  const DecoratedAccountLeaf({
    required this.id,
    required this.name,
    required this.balance,
    required this.parentId,
    required this.accountEntity,
  });

  @override
  bool get isComposite => false;

  @override
  double getTotalBalance() => balance;

  @override
  void addChild(AccountComponent child) {
    throw UnsupportedError('Cannot add child to a leaf');
  }

  @override
  void removeChild(String childId) {
    throw UnsupportedError('Cannot remove child from a leaf');
  }

  // ⭐ دالات للتحقق من الديكوريتورات
  bool hasOverdraft() {
    return AccountDecoratorFactory.hasDecorator<OverdraftDecorator>(
      accountEntity,
    );
  }

  bool isPremium() {
    return AccountDecoratorFactory.hasDecorator<PremiumDecorator>(
      accountEntity,
    );
  }

  OverdraftDecorator? get overdraftDecorator {
    return AccountDecoratorFactory.extractDecorator<OverdraftDecorator>(
      accountEntity,
    );
  }

  PremiumDecorator? get premiumDecorator {
    return AccountDecoratorFactory.extractDecorator<PremiumDecorator>(
      accountEntity,
    );
  }

  // ⭐ دالة للحصول على وصف مختصر مع الديكوريتورات
  String get decoratedDescription {
    final overdraft = overdraftDecorator;
    final premium = premiumDecorator;

    String description = name;
    if (premium != null) description += ' (Premium ${premium.tierName})';
    if (overdraft != null) description += ' (Overdraft Available)';

    return description;
  }

  // ⭐ دالة للحصول على لون حسب الديكوريتورات
  Color getDecoratorColor() {
    if (isPremium()) return Colors.amber;
    if (hasOverdraft()) return Colors.blue;
    return Colors.grey;
  }
}

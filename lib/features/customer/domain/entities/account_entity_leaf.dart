import 'package:banking_system/features/banking/domain/entities/account_entity.dart';
import 'package:banking_system/features/customer/domain/entities/account_component.dart';
import 'package:banking_system/features/customer/patterns/decorator/account_decorator_factory.dart';
import 'package:banking_system/features/customer/patterns/decorator/overdraft_decorator.dart';
import 'package:banking_system/features/customer/patterns/decorator/premium_decorator.dart';

class AccountEntityLeaf implements AccountComponent {
  final String id;
  final String name;
  final double balance;
  final String? parentId;
  final AccountEntity entity;

  AccountEntityLeaf({
    required this.id,
    required this.name,
    required this.balance,
    required this.parentId,
    required this.entity,
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

  bool hasOverdraft() {
    return AccountDecoratorFactory.hasDecorator<OverdraftDecorator>(entity);
  }

  bool isPremium() {
    return AccountDecoratorFactory.hasDecorator<PremiumDecorator>(entity);
  }

  OverdraftDecorator? get overdraftDecorator {
    return AccountDecoratorFactory.extractDecorator<OverdraftDecorator>(entity);
  }

  PremiumDecorator? get premiumDecorator {
    return AccountDecoratorFactory.extractDecorator<PremiumDecorator>(entity);
  }
}

import '../../domain/entities/account_entity.dart';

abstract class AccountFactory {
  AccountEntity create({
    required String ownerName,
    required double initialBalance,
  });
}

class CheckingAccountFactory implements AccountFactory {
  @override
  AccountEntity create({required String ownerName, required double initialBalance}) {
    return AccountEntity(
      id: 'ACC-${DateTime.now().millisecondsSinceEpoch}',
      ownerName: ownerName,
      balance: initialBalance,
      type: AccountType.checking,
    );
  }
}

class SavingsAccountFactory implements AccountFactory {
  @override
  AccountEntity create({required String ownerName, required double initialBalance}) {
    return AccountEntity(
      id: 'ACC-${DateTime.now().millisecondsSinceEpoch}',
      ownerName: ownerName,
      balance: initialBalance,
      type: AccountType.savings,
    );
  }
}

class BusinessAccountFactory implements AccountFactory {
  @override
  AccountEntity create({required String ownerName, required double initialBalance}) {
    return AccountEntity(
      id: 'ACC-${DateTime.now().millisecondsSinceEpoch}',
      ownerName: ownerName,
      balance: initialBalance,
      type: AccountType.business,
    );
  }
}

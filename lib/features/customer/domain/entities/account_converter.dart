import 'package:banking_system/features/banking/domain/entities/account_entity.dart';
import 'package:banking_system/features/banking/patterns/state/account_state.dart';
import 'package:banking_system/features/customer/data/models/account_model.dart';

class AccountConverter {
  static AccountEntity modelToEntity(AccountModel model) {
    return AccountEntity(
      id: model.id,
      ownerName: model.name,
      balance: model.balance,
      type: _mapAccountType(model.type),
      state: AccountState.active,
    );
  }

  static AccountModel entityToModel(AccountEntity entity) {
    return AccountModel(
      id: entity.id,
      name: entity.ownerName,
      balance: entity.balance,
      type: _reverseMapAccountType(entity.type),
    );
  }

  static AccountType _mapAccountType(String type) {
    switch (type.toLowerCase()) {
      case 'main':
      case 'checking':
        return AccountType.checking;
      case 'savings':
      case 'family':
        return AccountType.savings;
      case 'business':
        return AccountType.business;
      default:
        return AccountType.savings;
    }
  }

  static String _reverseMapAccountType(AccountType type) {
    switch (type) {
      case AccountType.checking:
        return 'checking';
      case AccountType.savings:
        return 'savings';
      case AccountType.business:
        return 'business';
    }
  }
}

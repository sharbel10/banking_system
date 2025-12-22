import 'package:banking_system/features/customer/data/models/account_model.dart';
import 'package:banking_system/features/customer/data/models/transaction_model.dart';
import 'package:banking_system/features/customer/domain/entities/account_component.dart';

abstract class CustomerHomeState {}

class CustomerHomeInitial extends CustomerHomeState {}

class CustomerHomeLoading extends CustomerHomeState {}

class CustomerHomeLoaded extends CustomerHomeState {
  final List<AccountModel> accounts; // خليها إذا بدك تضل تستخدمها
  final AccountComponent root;       //  الجديد
  final List<TransactionModel> recentTransactions;

  CustomerHomeLoaded({
    required this.accounts,
    required this.root,
    required this.recentTransactions,
  });
}

class CustomerHomeError extends CustomerHomeState {
  final String message;
  CustomerHomeError(this.message);
}

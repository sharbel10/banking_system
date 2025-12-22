// lib/features/customer/presentation/blocs/customer_home/customer_home_state.dart
import 'package:banking_system/features/customer/data/models/account_model.dart';
import 'package:banking_system/features/customer/data/models/transaction_model.dart';
import 'package:meta/meta.dart';

@immutable
abstract class CustomerHomeState {}

class CustomerHomeInitial extends CustomerHomeState {}

class CustomerHomeLoading extends CustomerHomeState {}

class CustomerHomeLoaded extends CustomerHomeState {
  final List<AccountModel> accounts;
  final List<TransactionModel> recentTransactions;
  CustomerHomeLoaded({
    required this.accounts,
    required this.recentTransactions,
  });
}

class CustomerHomeError extends CustomerHomeState {
  final String message;
  CustomerHomeError(this.message);
}

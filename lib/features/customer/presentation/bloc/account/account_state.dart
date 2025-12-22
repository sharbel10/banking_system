import 'package:banking_system/features/customer/domain/entities/account_component.dart';
import 'package:meta/meta.dart';

@immutable
abstract class AccountsState {}

class AccountsInitial extends AccountsState {}

class AccountsLoading extends AccountsState {}

class AccountsLoaded extends AccountsState {
  final AccountComponent root;
  AccountsLoaded(this.root);
}

class AccountsError extends AccountsState {
  final String message;
  AccountsError(this.message);
}

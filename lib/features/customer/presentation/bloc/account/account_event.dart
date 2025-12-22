import 'package:meta/meta.dart';

@immutable
abstract class AccountsEvent {}

class LoadAccounts extends AccountsEvent {
  final String customerId;
  LoadAccounts(this.customerId);
}

class RefreshAccounts extends AccountsEvent {
  final String customerId;
  RefreshAccounts(this.customerId);
}

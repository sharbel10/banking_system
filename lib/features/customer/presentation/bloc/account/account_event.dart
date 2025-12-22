import 'package:meta/meta.dart';

@immutable
abstract class AccountsEvent {}
class LoadAccounts extends AccountsEvent {
  final String customerId;
  final String? accountId;
  LoadAccounts(this.customerId, {this.accountId});
}

class RefreshAccounts extends AccountsEvent {
  final String customerId;
  final String? accountId;
  RefreshAccounts(this.customerId, {this.accountId});
}


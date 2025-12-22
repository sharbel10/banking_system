import 'package:meta/meta.dart';

@immutable
abstract class CustomerHomeEvent {}

class LoadCustomerHome extends CustomerHomeEvent {
  final String customerId;
  final String? accountId;
  LoadCustomerHome(this.customerId, {this.accountId});
}

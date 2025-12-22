import 'package:banking_system/features/customer/data/models/support_ticket_model.dart';
import 'package:meta/meta.dart';

@immutable
abstract class SupportState {}

class SupportInitial extends SupportState {}

class SupportLoading extends SupportState {}

class SupportLoaded extends SupportState {
  final List<SupportTicketModel> tickets;
  SupportLoaded(this.tickets);
}

class SupportProcessing extends SupportState {
  final String message;
  SupportProcessing(this.message);
}

class SupportError extends SupportState {
  final String message;
  SupportError(this.message);
}

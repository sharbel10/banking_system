import 'package:meta/meta.dart';

@immutable
abstract class SupportEvent {}

class LoadTickets extends SupportEvent {
  final String customerId;
  LoadTickets(this.customerId);
}

class CreateTicket extends SupportEvent {
  final String customerId;
  final String subject;
  final String message;
  CreateTicket({
    required this.customerId,
    required this.subject,
    required this.message,
  });
}

class RefreshTickets extends SupportEvent {
  final String customerId;
  RefreshTickets(this.customerId);
}

class UpdateTicketStatus extends SupportEvent {
  final String ticketId;
  final String newStatus;
  UpdateTicketStatus(this.ticketId, this.newStatus);
}

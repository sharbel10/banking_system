import 'dart:async';
import 'package:banking_system/features/customer/patterns/facade/customer_facade_mock.dart';
import 'package:bloc/bloc.dart';
import 'support_event.dart';
import 'support_state.dart';

class SupportBloc extends Bloc<SupportEvent, SupportState> {
  final CustomerFacadeMock facade;
  SupportBloc({required this.facade}) : super(SupportInitial()) {
    on<LoadTickets>(_onLoad);
    on<CreateTicket>(_onCreate);
    on<RefreshTickets>(_onLoad);
    on<UpdateTicketStatus>(_onUpdateStatus);
  }

  Future<void> _onLoad(SupportEvent event, Emitter emit) async {
    final customerId = (event is LoadTickets)
        ? event.customerId
        : (event as RefreshTickets).customerId;
    emit(SupportLoading());
    try {
      final tickets = await facade.fetchSupportTickets(customerId);
      emit(SupportLoaded(tickets));
    } catch (e) {
      emit(SupportError(e.toString()));
    }
  }

  Future<void> _onCreate(CreateTicket event, Emitter emit) async {
    emit(SupportProcessing('Creating ticket...'));
    try {
      await facade.createSupportTicket(
        customerId: event.customerId,
        subject: event.subject,
        message: event.message,
      );
      // reload
      final tickets = await facade.fetchSupportTickets(event.customerId);
      emit(SupportLoaded(tickets));
    } catch (e) {
      emit(SupportError(e.toString()));
    }
  }

  Future<void> _onUpdateStatus(UpdateTicketStatus event, Emitter emit) async {
    emit(SupportProcessing('Updating ticket...'));
    try {
      await facade.updateTicketStatus(event.ticketId, event.newStatus);

      final all = await facade.fetchSupportTickets('demo-customer');
      emit(SupportLoaded(all));
    } catch (e) {
      emit(SupportError(e.toString()));
    }
  }
}

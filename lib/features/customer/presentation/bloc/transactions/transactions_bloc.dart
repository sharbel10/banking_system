import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:banking_system/features/customer/patterns/facade/customer_facade_mock.dart';
import 'transactions_event.dart';
import 'transactions_state.dart';

class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  final CustomerFacadeMock facade;
  TransactionsBloc({required this.facade}) : super(TransactionsInitial()) {
    on<LoadTransactions>(_onLoad);
    on<RerunChain>(_onRerun);
  }

  Future<void> _onLoad(LoadTransactions event, Emitter emit) async {
    emit(TransactionsLoading());
    try {
      final txns = await facade.fetchTransactions(
        event.customerId,
        accountId: event.accountId,
      );
      emit(TransactionsLoaded(txns));
    } catch (e) {
      emit(TransactionsError(e.toString()));
    }
  }

  Future<void> _onRerun(RerunChain event, Emitter emit) async {
    emit(TransactionsProcessing(event.txnId));
    try {
      final updated = await facade.processTransaction(event.txnId);
      final txns = await facade.fetchTransactions('demo-customer');
      emit(TransactionsLoaded(txns));
    } catch (e) {
      emit(TransactionsError(e.toString()));
    }
  }
}

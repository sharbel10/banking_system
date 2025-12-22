import 'dart:async';
import 'package:banking_system/features/customer/patterns/facade/customer_facade_mock.dart';
import 'package:banking_system/features/customer/presentation/bloc/account/account_event.dart';
import 'package:banking_system/features/customer/presentation/bloc/account/account_state.dart';
import 'package:bloc/bloc.dart';

class AccountsBloc extends Bloc<AccountsEvent, AccountsState> {
  final CustomerFacadeMock facade;
  AccountsBloc({required this.facade}) : super(AccountsInitial()) {
    on<LoadAccounts>(_onLoad);
    on<RefreshAccounts>(_onLoad);
  }

  Future<void> _onLoad(AccountsEvent event, Emitter emit) async {
    emit(AccountsLoading());
    try {
      final customerId = (event is LoadAccounts) ? event.customerId : (event as RefreshAccounts).customerId;
      final accountId  = (event is LoadAccounts) ? event.accountId  : (event as RefreshAccounts).accountId;

      final root = await facade.fetchAccountsHierarchy(
        customerId,
        accountId: accountId,
      );

      emit(AccountsLoaded(root));
    } catch (e) {
      emit(AccountsError(e.toString()));
    }
  }

}

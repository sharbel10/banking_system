// customer_home_bloc.dart
import 'dart:async';
import 'package:banking_system/core/di/injection.dart';
import 'package:banking_system/features/customer/patterns/facade/customer_facade_mock.dart';
import 'package:bloc/bloc.dart';
import 'customer_home_event.dart';
import 'customer_home_state.dart';

class CustomerHomeBloc extends Bloc<CustomerHomeEvent, CustomerHomeState> {
  final CustomerFacadeMock facade;
  StreamSubscription? _notifSub;

  CustomerHomeBloc({CustomerFacadeMock? facade})
      : facade = facade ?? sl<CustomerFacadeMock>(),
        super(CustomerHomeInitial()) {
    on<LoadCustomerHome>(_onLoad);
  }

  Future<void> _onLoad(LoadCustomerHome event, Emitter emit) async {
    emit(CustomerHomeLoading());
    try {
      //  root tree (main + leafs)
      final root = await facade.fetchAccountsHierarchy(
        event.customerId,
        accountId: event.accountId,
      );

      // optional: keep flat accounts if you need them somewhere
      final accounts = await facade.fetchAccountsFlat(
        event.customerId,
        accountId: event.accountId,
      );

      final txns = await facade.fetchTransactions(
        event.customerId,
        accountId: event.accountId,
      );

      _notifSub?.cancel();
      _notifSub = facade.notificationsStream(event.customerId).listen((notif) {
        print('notif received: ${notif.title} - ${notif.body}');
      });

      emit(CustomerHomeLoaded(
        accounts: accounts,
        root: root,
        recentTransactions: txns,
      ));
    } catch (e) {
      emit(CustomerHomeError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _notifSub?.cancel();
    return super.close();
  }
}

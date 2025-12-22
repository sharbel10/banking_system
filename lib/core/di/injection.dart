import 'package:banking_system/features/customer/patterns/facade/customer_facade_mock.dart';
import 'package:banking_system/features/customer/presentation/bloc/account/account_bloc.dart';
import 'package:banking_system/features/customer/presentation/bloc/home/customer_home_bloc.dart';
import 'package:banking_system/features/customer/presentation/bloc/support/support_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../features/banking/data/datasources/banking_local_datasources.dart';
import '../../features/banking/patterns/facade/banking_facade.dart';
import '../../features/banking/patterns/facade/defualt_approval_chain_factory.dart';
import '../../features/banking/patterns/facade/defualt_transaction_strategy_factory.dart';
import '../../features/banking/patterns/observer/event_bus.dart';
import '../../features/banking/presentation/factories.dart';

import '../../features/staff/presentation/bloc/new_transaction_cubit.dart';

import '../session/session_cubit.dart';
import '../session/session_state.dart' as session;

import '../auth/current_session.dart' as auth;

final sl = GetIt.I;

Future<void> configureDependencies() async {
  // Session
  sl.registerLazySingleton<SessionCubit>(() => SessionCubit());

  // Data + Bus
  sl.registerLazySingleton<BankingLocalDataSource>(() => BankingLocalDataSource());
  sl.registerLazySingleton<EventBus>(() => EventBus());

  // Factories
  sl.registerLazySingleton<ApprovalChainFactory>(() => DefaultApprovalChainFactory());
  sl.registerLazySingleton<TransactionStrategyFactory>(
        () => DefaultTransactionStrategyFactory(sl<BankingLocalDataSource>()),
  );

  // CurrentSession (depends on SessionCubit state -> لازم factory)
  sl.registerFactory<auth.CurrentSession>(() {
    final st = sl<SessionCubit>().state;

    if (st.role == session.UserRole.customer) {
      return const auth.CurrentSession(auth.UserRole.customer);
    }

    final mode = st.staffMode ?? session.StaffMode.teller;
    return auth.CurrentSession(_mapStaffModeToUserRole(mode));
  });

  sl.registerFactory<BankingFacade>(() => BankingFacade(
    sl<BankingLocalDataSource>(),
    sl<EventBus>(),
    approvalChainFactory: sl<ApprovalChainFactory>(),
    strategyFactory: sl<TransactionStrategyFactory>(),
    session: sl<auth.CurrentSession>(),
  ));

  sl.registerLazySingleton<CustomerFacadeMock>(
        () => CustomerFacadeMock(banking: sl<BankingFacade>()),
  );

  sl<CustomerFacadeMock>();

  // Blocs
  sl.registerFactory(() => CustomerHomeBloc(facade: sl()));
  sl.registerFactory(() => AccountsBloc(facade: sl()));
  sl.registerFactory(() => SupportBloc(facade: sl()));

  // Cubits
  sl.registerFactory<NewTransactionCubit>(() => NewTransactionCubit(sl<BankingFacade>()));
}

auth.UserRole _mapStaffModeToUserRole(session.StaffMode m) {
  switch (m) {
    case session.StaffMode.teller:
      return auth.UserRole.teller;
    case session.StaffMode.manager:
      return auth.UserRole.manager;
  }
}

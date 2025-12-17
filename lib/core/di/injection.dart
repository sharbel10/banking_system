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

  sl.registerFactory<auth.CurrentSession>(() {
    final st = sl<SessionCubit>().state;

    // إذا مو staff، اعتبره customer
    if (st.role == session.UserRole.customer) {
      return const auth.CurrentSession(auth.UserRole.customer);
    }

    // staff: خد staffMode (teller/manager)
    final session.StaffMode mode = st.staffMode ?? session.StaffMode.teller;
    return auth.CurrentSession(_mapStaffModeToUserRole(mode));
  });


  // Facade
  sl.registerFactory<BankingFacade>(() => BankingFacade(
    sl<BankingLocalDataSource>(),
    sl<EventBus>(),
    approvalChainFactory: sl<ApprovalChainFactory>(),
    strategyFactory: sl<TransactionStrategyFactory>(),
    session: sl<auth.CurrentSession>(),
  ));

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



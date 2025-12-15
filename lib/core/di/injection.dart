import 'package:get_it/get_it.dart';

import '../../features/banking/data/datasources/banking_local_datasources.dart';
import '../../features/banking/patterns/facade/banking_facade.dart';
import '../../features/banking/patterns/observer/event_bus.dart';
import '../../features/staff/presentation/bloc/new_transaction_cubit.dart';
import '../session/session_cubit.dart';

final sl = GetIt.I;

Future<void> configureDependencies() async {
  sl.registerLazySingleton<SessionCubit>(() => SessionCubit());
  sl.registerLazySingleton<BankingLocalDataSource>(() => BankingLocalDataSource());
  sl.registerLazySingleton<EventBus>(() => EventBus());
  sl.registerLazySingleton<BankingFacade>(() => BankingFacade(sl<EventBus>(), sl<BankingLocalDataSource>()));
  sl.registerFactory<NewTransactionCubit>(() => NewTransactionCubit(sl<BankingFacade>()));

}


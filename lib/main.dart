import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/app.dart';
import 'core/di/injection.dart';
import 'core/session/session_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<SessionCubit>(
          create: (_) => sl<SessionCubit>(),
        ),
      ],
      child: const BankingApp(),
    ),
  );
}

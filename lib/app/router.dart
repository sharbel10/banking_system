import 'package:go_router/go_router.dart';

import '../features/role_selection/presentation/role_selection_page.dart';
import '../features/staff/presentation/pages/staff_dashboard_page.dart';
import '../features/staff/presentation/pages/teller_homepage.dart';
import '../features/staff/presentation/pages/new_transaction_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/role',
    routes: [
      GoRoute(
        path: '/role',
        builder: (context, state) => const RoleSelectionPage(),
      ),
      GoRoute(
        path: '/staff/dashboard',
        builder: (context, state) => const StaffDashboardPage(),
      ),
      GoRoute(
        path: '/staff/teller',
        builder: (context, state) => const TellerHomePage(),
      ),
      GoRoute(
        path: '/staff/teller/new-transaction',
        builder: (context, state) => const NewTransactionPage(),
      ),
    ],
  );
}

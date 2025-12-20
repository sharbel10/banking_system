import 'package:go_router/go_router.dart';

import '../features/role_selection/presentation/role_selection_page.dart';

import '../features/staff/presentation/pages/manager/manage_accounts_page.dart';
import '../features/staff/presentation/pages/manager/manager_reports_page.dart';
import '../features/staff/presentation/pages/staff_dashboard_page.dart';
import '../features/staff/presentation/pages/teller/create_account_page.dart';
import '../features/staff/presentation/pages/teller/teller_homepage.dart';
import '../features/staff/presentation/pages/teller/new_transaction_page.dart';
import '../features/staff/presentation/pages/teller/scheduled_transaction_page.dart';
import '../features/staff/presentation/pages/teller/account_list_page.dart';

import '../features/staff/presentation/pages/manager/manager_home_page.dart';
import '../features/staff/presentation/pages/manager/manager_inbox_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/role',
    routes: [
      // ----------------------------
      // Role selection
      // ----------------------------
      GoRoute(
        path: '/role',
        builder: (context, state) => const RoleSelectionPage(),
      ),

      // ----------------------------
      // Staff dashboard
      // ----------------------------
      GoRoute(
        path: '/staff/dashboard',
        builder: (context, state) => const StaffDashboardPage(),
      ),

      // ----------------------------
      // Teller
      // ----------------------------
      GoRoute(
        path: '/staff/teller',
        builder: (context, state) => const TellerHomePage(),
      ),
      GoRoute(
        path: '/staff/teller/new-transaction',
        builder: (context, state) => const NewTransactionPage(),
      ),
      GoRoute(
        path: '/staff/teller/scheduled',
        builder: (context, state) => const ScheduledTransactionsPage(),
      ),
      GoRoute(
        path: '/staff/teller/create-account',
        builder: (context, state) => const CreateAccountPage(),
      ),
      GoRoute(
        path: '/staff/teller/accounts',
        builder: (context, state) => const AccountsListPage(),
      ),

      // ----------------------------
      // Manager
      // ----------------------------
      GoRoute(
        path: '/staff/manager',
        builder: (context, state) => const ManagerHomePage(),
      ),
      GoRoute(
        path: '/staff/manager/inbox',
        builder: (context, state) => const ManagerInboxPage(),
      ),
      GoRoute(
        path: '/staff/manager/accounts',
        builder: (context, state) => const ManagerAccountsPage(),
      ),
      GoRoute(
        path: '/staff/manager/reports',
        builder: (_, __) => const ManagerReportsPage(),
      ),

    ],
  );
}

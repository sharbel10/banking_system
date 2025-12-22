import 'package:banking_system/features/customer/presentation/pages/customer_home_page.dart';
import 'package:banking_system/features/customer/presentation/pages/view_accounts_page.dart';
import 'package:banking_system/features/customer/presentation/pages/view_transactions_page.dart';
import 'package:go_router/go_router.dart';

import '../features/customer/presentation/pages/cuwtomer_account_select_page.dart';
import '../features/role_selection/presentation/role_selection_page.dart';

import '../features/staff/presentation/pages/manager/manage_accounts_page.dart';
import '../features/staff/presentation/pages/manager/manager_audit_logs.dart';
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
      GoRoute(
        path: '/staff/manager/audit',
        builder: (_, __) => const ManagerAuditLogsPage(),
      ),
// ----------------------------
      GoRoute(
        path: '/customer/select',
        builder: (context, state) => const CustomerSelectAccountPage(),
      ),
      GoRoute(
        path: '/customer/home',
        builder: (context, state) {
          return const CustomerHomePage(); // الصفحة تتعامل بنفسها مع Bloc/getIt
        },
      ),
      GoRoute(
        path: '/customer/accounts',
        builder: (context, state) => const ViewAccountsPage(),
      ),
      GoRoute(
        path: '/customer/transactions',
        builder: (ctx, state) => const ViewTransactionsPage(),
      ),
    ],
  );
}

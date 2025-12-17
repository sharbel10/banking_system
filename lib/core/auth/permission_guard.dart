import '../utils/result.dart';
import 'current_session.dart';

enum Permission {
  submitTransaction,
  approveTransaction,
  rejectTransaction,
  manageScheduled,
  manageAccounts
}

class PermissionGuard {
  final CurrentSession _session;
  const PermissionGuard(this._session);

  Result<void> require(Permission p) {
    final role = _session.role;

    final allowed = switch (p) {
      Permission.submitTransaction =>
      role == UserRole.teller || role == UserRole.manager || role == UserRole.admin,
      Permission.approveTransaction =>
      role == UserRole.manager || role == UserRole.admin,
      Permission.rejectTransaction =>
      role == UserRole.manager || role == UserRole.admin,
      Permission.manageScheduled =>
      role == UserRole.teller || role == UserRole.manager || role == UserRole.admin,
      Permission.manageAccounts =>
      role == UserRole.teller || role == UserRole.manager || role == UserRole.admin,

    };

    return allowed ? const Success(null) : const Failure('Unauthorized');
  }
}

enum UserRole { none, customer, staff }
enum StaffMode { teller, manager }

class SessionState {
  final UserRole role;
  final StaffMode? staffMode;
  final String? customerAccountId;

  const SessionState({
    required this.role,
    required this.staffMode,
    required this.customerAccountId,
  });

  const SessionState.initial()
      : role = UserRole.none,
        staffMode = null,
        customerAccountId = null;

  SessionState copyWith({
    UserRole? role,
    StaffMode? staffMode,
    String? customerAccountId,
    bool clearStaffMode = false,
    bool clearCustomerAccount = false,
  }) {
    return SessionState(
      role: role ?? this.role,
      staffMode: clearStaffMode ? null : (staffMode ?? this.staffMode),
      customerAccountId: clearCustomerAccount
          ? null
          : (customerAccountId ?? this.customerAccountId),
    );
  }
}

enum UserRole { none, customer, staff }
enum StaffMode { teller, manager }

class SessionState {
  final UserRole role;
  final StaffMode? staffMode;

  const SessionState({
    required this.role,
    required this.staffMode,
  });

  const SessionState.initial()
      : role = UserRole.none,
        staffMode = null;

  SessionState copyWith({
    UserRole? role,
    StaffMode? staffMode,
    bool clearStaffMode = false,
  }) {
    return SessionState(
      role: role ?? this.role,
      staffMode: clearStaffMode ? null : (staffMode ?? this.staffMode),
    );
  }
}

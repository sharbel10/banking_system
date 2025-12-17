enum UserRole { customer, teller, manager, admin }

class CurrentSession {
  final UserRole role;
  const CurrentSession(this.role);
}

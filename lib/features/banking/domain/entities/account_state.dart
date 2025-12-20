enum AccountState { active, frozen, suspended, closed }

extension AccountStateX on AccountState {
  String get label {
    switch (this) {
      case AccountState.active:
        return 'Active';
      case AccountState.frozen:
        return 'Frozen';
      case AccountState.suspended:
        return 'Suspended';
      case AccountState.closed:
        return 'Closed';
    }
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';

import 'session_state.dart';

class SessionCubit extends Cubit<SessionState> {
  SessionCubit() : super(const SessionState.initial());

  void actAsCustomer() {
    emit(state.copyWith(role: UserRole.customer, clearStaffMode: true));
  }

  void actAsStaff() {
    emit(state.copyWith(role: UserRole.staff, clearStaffMode: true));
  }

  void setStaffMode(StaffMode mode) {
    emit(state.copyWith(role: UserRole.staff, staffMode: mode));
  }

  void reset() {
    emit(const SessionState.initial());
  }
}

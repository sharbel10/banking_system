import 'dart:async';
import 'package:banking_system/features/customer/data/models/notification_model.dart';
import 'package:banking_system/features/customer/patterns/facade/customer_facade_mock.dart';
import 'package:bloc/bloc.dart';

import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final CustomerFacadeMock facade;
  final String customerId;
  StreamSubscription<NotificationModel>? _sub;
  final List<NotificationModel> _items = [];

  NotificationsCubit({required this.facade, required this.customerId})
    : super(NotificationsInitial()) {
    _startListening();
  }

  void _startListening() {
    try {
      _sub?.cancel();
      _sub = facade
          .notificationsStream(customerId)
          .listen(
            (notif) {
              _items.insert(0, notif);
              emit(NotificationsLoadSuccess(List.unmodifiable(_items)));
            },
            onError: (err, st) {
              emit(NotificationsError(err.toString()));
            },
          );
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  Future<void> loadInitial([List<NotificationModel>? initial]) async {
    if (initial != null && initial.isNotEmpty) {
      _items.clear();
      _items.addAll(initial.reversed);
      emit(NotificationsLoadSuccess(List.unmodifiable(_items)));
      return;
    }
    if (_items.isEmpty) emit(NotificationsEmpty());
  }

  void markAllRead() {
    _items.clear();
    emit(NotificationsEmpty());
  }

  void removeNotification(String id) {
    _items.removeWhere((n) => n.id == id);
    if (_items.isEmpty)
      emit(NotificationsEmpty());
    else
      emit(NotificationsLoadSuccess(List.unmodifiable(_items)));
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}

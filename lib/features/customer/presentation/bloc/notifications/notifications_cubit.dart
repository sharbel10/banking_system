import 'dart:async';

import 'package:banking_system/features/customer/data/models/notification_model.dart';
import 'package:banking_system/features/customer/patterns/facade/customer_facade_mock.dart';
import 'package:banking_system/features/customer/presentation/bloc/notifications/notifications_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final CustomerFacadeMock facade;
  final String customerId;
  StreamSubscription<NotificationModel>? _sub;
  final List<NotificationModel> _items = [];

  NotificationsCubit({required this.facade, required this.customerId})
    : super(NotificationsInitial()) {
    _start();
  }

  Future<void> _start() async {
    try {
      final past = await facade.fetchPastNotifications(customerId);
      if (past.isNotEmpty) {
        _items.clear();
        _items.addAll(past);
        emit(NotificationsLoadSuccess(List.unmodifiable(_items)));
      } else {
        emit(NotificationsEmpty());
      }

      _sub?.cancel();
      _sub = facade.notificationsStream(customerId).listen((notif) {
        _items.insert(0, notif);
        emit(NotificationsLoadSuccess(List.unmodifiable(_items)));
      }, onError: (err) => emit(NotificationsError(err.toString())));
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}

import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../../data/models/notification_model.dart';
import '../../../patterns/facade/customer_facade_mock.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final CustomerFacadeMock facade;
  final String customerId;

  StreamSubscription<NotificationModel>? _sub;
  final List<NotificationModel> _items = [];

  NotificationsCubit({
    required this.facade,
    required this.customerId,
  }) : super(NotificationsInitial()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final past = await facade.fetchPastNotifications(customerId);
      _items
        ..clear()
        ..addAll(past);

      _emitList();

      _sub?.cancel();
      _sub = facade.notificationsStream(customerId).listen((n) {
        _items.insert(0, n);
        _emitList();
      });
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  void _emitList() {
    if (_items.isEmpty) {
      emit(NotificationsEmpty());
    } else {
      emit(NotificationsLoadSuccess(List.unmodifiable(_items)));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}

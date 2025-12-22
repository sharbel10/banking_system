import 'package:banking_system/features/customer/data/models/notification_model.dart';
import 'package:meta/meta.dart';

@immutable
abstract class NotificationsState {}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoadSuccess extends NotificationsState {
  final List<NotificationModel> notifications;
  NotificationsLoadSuccess(this.notifications);
}

class NotificationsEmpty extends NotificationsState {}

class NotificationsError extends NotificationsState {
  final String message;
  NotificationsError(this.message);
}

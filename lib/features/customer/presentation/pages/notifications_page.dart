import 'package:banking_system/core/di/injection.dart';
import 'package:banking_system/features/customer/data/models/notification_model.dart';
import 'package:banking_system/features/customer/patterns/facade/customer_facade_mock.dart';
import 'package:banking_system/features/customer/presentation/bloc/notifications/notifications_cubit.dart';
import 'package:banking_system/features/customer/presentation/bloc/notifications/notifications_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/session/session_cubit.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionState = context.read<SessionCubit>().state;
    final customerId = 'demo-customer';

    final facade = () {
      try {} catch (_) {}
      return sl<CustomerFacadeMock>();
    }();

    return BlocProvider(
      create: (_) => NotificationsCubit(facade: facade, customerId: customerId),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        // actions: [
        //   IconButton(
        //     tooltip: 'Mark all read',
        //     onPressed: () => context.read<NotificationsCubit>().markAllRead(),
        //     icon: Icon(Icons.mark_email_read_rounded, color: cs.onSurface),
        //   ),
        // ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: BlocBuilder<NotificationsCubit, NotificationsState>(
          builder: (context, state) {
            if (state is NotificationsInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is NotificationsEmpty) {
              return Center(
                child: Text(
                  'No notifications',
                  style: TextStyle(color: cs.onSurface.withOpacity(0.6)),
                ),
              );
            } else if (state is NotificationsError) {
              return Center(
                child: Text(
                  'Error: ${state.message}',
                  style: TextStyle(color: cs.error),
                ),
              );
            } else if (state is NotificationsLoadSuccess) {
              final items = state.notifications;
              return ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final n = items[i];
                  return _NotifTile(notification: n);
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final NotificationModel notification;
  const _NotifTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text(notification.title),
              content: Text(notification.body),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
                // TextButton(
                //   onPressed: () {
                //     context.read<NotificationsCubit>().removeNotification(
                //       notification.id,
                //     );
                //     Navigator.of(context).pop();
                //   },
                //   child: const Text('Remove'),
                // ),
              ],
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(Icons.notifications_rounded, color: cs.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.body,
                      style: TextStyle(color: cs.onSurface.withOpacity(0.72)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // IconButton(
              //   tooltip: 'Remove',
              //   onPressed: () => context
              //       .read<NotificationsCubit>()
              //       .removeNotification(notification.id),
              //   icon: Icon(
              //     Icons.close_rounded,
              //     color: cs.onSurface.withOpacity(0.5),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

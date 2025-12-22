import 'package:banking_system/features/customer/data/models/support_ticket_model.dart';
import 'package:flutter/material.dart';

typedef VoidCallbackWithId = void Function();

class SupportTicketTile extends StatelessWidget {
  final SupportTicketModel ticket;
  final VoidCallback onClose;
  final VoidCallback onTap;

  const SupportTicketTile({
    required this.ticket,
    required this.onClose,
    required this.onTap,
    super.key,
  });

  Color _statusColor(BuildContext context) {
    final s = ticket.status.toLowerCase();
    if (s == 'open') return Colors.orange;
    if (s == 'in progress' || s == 'in_progress') return Colors.blue;
    if (s == 'closed') return Colors.green;
    return Theme.of(context).colorScheme.onSurface;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(Icons.support_agent_rounded, color: _statusColor(context)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.subject,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      ticket.createdAt,
                      style: TextStyle(
                        color: cs.onSurface.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                ticket.status,
                style: TextStyle(
                  color: _statusColor(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onClose,
                icon: Icon(
                  Icons.close_rounded,
                  color: cs.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

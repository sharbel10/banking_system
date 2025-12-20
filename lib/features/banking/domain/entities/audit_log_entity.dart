enum AuditAction {
  txSubmitted,
  txApproved,
  txRejected,
  accountStateChanged,
  scheduledCreated,
  scheduledCanceled,
  scheduledRun,
  accountCreated,
}

class AuditLogEntity {
  final String id;
  final DateTime at;
  final String actor;
  final AuditAction action;
  final String message;

  const AuditLogEntity({
    required this.id,
    required this.at,
    required this.actor,
    required this.action,
    required this.message,
  });
}

class SupportTicketModel {
  final String id;
  final String customerId;
  final String subject;
  final String message;
  final String status;
  final String createdAt;

  SupportTicketModel({
    required this.id,
    required this.customerId,
    required this.subject,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  SupportTicketModel copyWith({
    String? id,
    String? customerId,
    String? subject,
    String? message,
    String? status,
    String? createdAt,
  }) {
    return SupportTicketModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      subject: subject ?? this.subject,
      message: message ?? this.message,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

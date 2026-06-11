import 'enums/payment_status.dart';

class PaymentModel {
  final String id;
  final String emergencyId;
  final String paymentType;
  final double amount;
  final String? recipientId;
  final PaymentStatus status;
  final String? moolreReference;
  final DateTime? releasedAt;
  final DateTime createdAt;

  PaymentModel({
    required this.id,
    required this.emergencyId,
    required this.paymentType,
    required this.amount,
    this.recipientId,
    this.status = PaymentStatus.pending,
    this.moolreReference,
    this.releasedAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      emergencyId: json['emergency_id'] as String,
      paymentType: json['payment_type'] as String,
      amount: (json['amount'] as num).toDouble(),
      recipientId: json['recipient_id'] as String?,
      status:
          PaymentStatus.fromString(json['status'] as String? ?? 'pending'),
      moolreReference: json['moolre_reference'] as String?,
      releasedAt: json['released_at'] != null
          ? DateTime.parse(json['released_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'emergency_id': emergencyId,
      'payment_type': paymentType,
      'amount': amount,
      'recipient_id': recipientId,
      'status': status.value,
      'moolre_reference': moolreReference,
      'released_at': releasedAt?.toIso8601String(),
    };
  }
}
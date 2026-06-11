import 'enums/payment_status.dart';

class ContributionModel {
  final String id;
  final String emergencyId;
  final String contributorId;
  final double amount;
  final String paymentMethod;
  final PaymentStatus paymentStatus;
  final String? moolreTransactionId;
  final DateTime createdAt;

  ContributionModel({
    required this.id,
    required this.emergencyId,
    required this.contributorId,
    required this.amount,
    this.paymentMethod = 'mobile_money',
    this.paymentStatus = PaymentStatus.pending,
    this.moolreTransactionId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ContributionModel.fromJson(Map<String, dynamic> json) {
    return ContributionModel(
      id: json['id'] as String,
      emergencyId: json['emergency_id'] as String,
      contributorId: json['contributor_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      paymentMethod: json['payment_method'] as String? ?? 'mobile_money',
      paymentStatus:
          PaymentStatus.fromString(json['payment_status'] as String? ?? 'pending'),
      moolreTransactionId: json['moolre_transaction_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'emergency_id': emergencyId,
      'contributor_id': contributorId,
      'amount': amount,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus.value,
      'moolre_transaction_id': moolreTransactionId,
    };
  }
}
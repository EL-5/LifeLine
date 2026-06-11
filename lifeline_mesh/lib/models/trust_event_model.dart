class TrustEventModel {
  final String id;
  final String emergencyId;
  final String validatorId;
  final String validationType;
  final String status;
  final String? notes;
  final DateTime createdAt;

  TrustEventModel({
    required this.id,
    required this.emergencyId,
    required this.validatorId,
    required this.validationType,
    this.status = 'pending',
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory TrustEventModel.fromJson(Map<String, dynamic> json) {
    return TrustEventModel(
      id: json['id'] as String,
      emergencyId: json['emergency_id'] as String,
      validatorId: json['validator_id'] as String,
      validationType: json['validation_type'] as String,
      status: json['status'] as String? ?? 'pending',
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'emergency_id': emergencyId,
      'validator_id': validatorId,
      'validation_type': validationType,
      'status': status,
      'notes': notes,
    };
  }
}
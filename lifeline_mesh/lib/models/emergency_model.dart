import 'enums/emergency_status.dart';
import 'enums/severity_level.dart';

class EmergencyModel {
  final String id;
  final String patientId;
  final String category;
  final List<String> symptoms;
  final SeverityLevel severity;
  final Map<String, dynamic> location;
  final String? hospitalId;
  final String? driverId;
  final EmergencyStatus status;
  final double targetAmount;
  final double raisedAmount;
  final bool fraudFlag;
  final String? aiSummary;
  final DateTime createdAt;
  final DateTime updatedAt;

  EmergencyModel({
    required this.id,
    required this.patientId,
    required this.category,
    this.symptoms = const [],
    this.severity = SeverityLevel.moderate,
    this.location = const {'lat': 0.0, 'lng': 0.0, 'address': ''},
    this.hospitalId,
    this.driverId,
    this.status = EmergencyStatus.pending,
    this.targetAmount = 0.0,
    this.raisedAmount = 0.0,
    this.fraudFlag = false,
    this.aiSummary,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory EmergencyModel.fromJson(Map<String, dynamic> json) {
    return EmergencyModel(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      category: json['category'] as String? ?? 'unknown',
      symptoms: (json['symptoms'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      severity: SeverityLevel.fromString(json['severity'] as String? ?? 'moderate'),
      location: json['location'] as Map<String, dynamic>? ??
          {'lat': 0.0, 'lng': 0.0, 'address': ''},
      hospitalId: json['hospital_id'] as String?,
      driverId: json['driver_id'] as String?,
      status: EmergencyStatus.fromString(json['status'] as String? ?? 'pending'),
      targetAmount: (json['target_amount'] as num?)?.toDouble() ?? 0.0,
      raisedAmount: (json['raised_amount'] as num?)?.toDouble() ?? 0.0,
      fraudFlag: json['fraud_flag'] as bool? ?? false,
      aiSummary: json['ai_summary'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'category': category,
      'symptoms': symptoms,
      'severity': severity.value,
      'location': location,
      'hospital_id': hospitalId,
      'driver_id': driverId,
      'status': status.value,
      'target_amount': targetAmount,
      'raised_amount': raisedAmount,
      'fraud_flag': fraudFlag,
      'ai_summary': aiSummary,
    };
  }

  double get fundingProgress =>
      targetAmount > 0 ? (raisedAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

  bool get isActive => status.isActive;

  String get note => symptoms.isNotEmpty ? symptoms.join(', ') : 'No additional details provided';
}
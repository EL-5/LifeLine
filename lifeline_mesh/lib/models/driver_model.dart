class DriverModel {
  final String id;
  final String userId;
  final String? vehicleType;
  final String? vehicleRegistration;
  final bool availabilityStatus;
  final String verificationStatus;
  final Map<String, dynamic> currentLocation;
  final double totalEarnings;
  final DateTime createdAt;
  final DateTime updatedAt;

  DriverModel({
    required this.id,
    required this.userId,
    this.vehicleType,
    this.vehicleRegistration,
    this.availabilityStatus = false,
    this.verificationStatus = 'unverified',
    this.currentLocation = const {'lat': 0.0, 'lng': 0.0},
    this.totalEarnings = 0.0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      vehicleType: json['vehicle_type'] as String?,
      vehicleRegistration: json['vehicle_registration'] as String?,
      availabilityStatus: json['availability_status'] as bool? ?? false,
      verificationStatus: json['verification_status'] as String? ?? 'unverified',
      currentLocation: json['current_location'] as Map<String, dynamic>? ??
          {'lat': 0.0, 'lng': 0.0},
      totalEarnings: (json['total_earnings'] as num?)?.toDouble() ?? 0.0,
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
      'user_id': userId,
      'vehicle_type': vehicleType,
      'vehicle_registration': vehicleRegistration,
      'availability_status': availabilityStatus,
      'verification_status': verificationStatus,
      'current_location': currentLocation,
      'total_earnings': totalEarnings,
    };
  }
}
class HospitalModel {
  final String id;
  final String name;
  final Map<String, dynamic> location;
  final int emergencyCapacity;
  final String verificationStatus;
  final String? contactPhone;
  final DateTime createdAt;

  HospitalModel({
    required this.id,
    required this.name,
    this.location = const {'lat': 0.0, 'lng': 0.0, 'address': ''},
    this.emergencyCapacity = 0,
    this.verificationStatus = 'unverified',
    this.contactPhone,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory HospitalModel.fromJson(Map<String, dynamic> json) {
    return HospitalModel(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as Map<String, dynamic>? ??
          {'lat': 0.0, 'lng': 0.0, 'address': ''},
      emergencyCapacity: json['emergency_capacity'] as int? ?? 0,
      verificationStatus: json['verification_status'] as String? ?? 'unverified',
      contactPhone: json['contact_phone'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'emergency_capacity': emergencyCapacity,
      'verification_status': verificationStatus,
      'contact_phone': contactPhone,
    };
  }
}
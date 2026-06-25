import 'enums/user_role.dart';

class UserModel {
  final String id;
  final UserRole role;
  final String? fullName;
  final String? phone;
  final String? email;
  final String? profilePhoto;
  final double trustScore;
  final String verificationStatus;
  final String? deviceId;
  final String? fcmToken;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    this.role = UserRole.user,
    this.fullName,
    this.phone,
    this.email,
    this.profilePhoto,
    this.trustScore = 0.0,
    this.verificationStatus = 'unverified',
    this.deviceId,
    this.fcmToken,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      role: UserRole.fromString(json['role'] as String? ?? 'user'),
      fullName: json['full_name'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      profilePhoto: json['profile_photo'] as String?,
      trustScore: (json['trust_score'] as num?)?.toDouble() ?? 0.0,
      verificationStatus: json['verification_status'] as String? ?? 'unverified',
      deviceId: json['device_id'] as String?,
      fcmToken: json['fcm_token'] as String?,
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
      'role': role.value,
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'profile_photo': profilePhoto,
      'trust_score': trustScore,
      'verification_status': verificationStatus,
      'device_id': deviceId,
      'fcm_token': fcmToken,
    };
  }

  UserModel copyWith({
    String? id,
    UserRole? role,
    String? fullName,
    String? phone,
    String? email,
    String? profilePhoto,
    double? trustScore,
    String? verificationStatus,
    String? deviceId,
    String? fcmToken,
  }) {
    return UserModel(
      id: id ?? this.id,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      trustScore: trustScore ?? this.trustScore,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      deviceId: deviceId ?? this.deviceId,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
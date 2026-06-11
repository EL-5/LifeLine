class FamilyConnectionModel {
  final String id;
  final String userId;
  final String familyMemberId;
  final String relationshipType;
  final String status;
  final DateTime createdAt;

  FamilyConnectionModel({
    required this.id,
    required this.userId,
    required this.familyMemberId,
    required this.relationshipType,
    this.status = 'invited',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory FamilyConnectionModel.fromJson(Map<String, dynamic> json) {
    return FamilyConnectionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      familyMemberId: json['family_member_id'] as String,
      relationshipType: json['relationship_type'] as String,
      status: json['status'] as String? ?? 'invited',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'family_member_id': familyMemberId,
      'relationship_type': relationshipType,
      'status': status,
    };
  }
}
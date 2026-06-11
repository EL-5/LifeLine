class AuditLogModel {
  final String id;
  final String? actorId;
  final String action;
  final String? resourceType;
  final String? resourceId;
  final Map<String, dynamic> metadata;
  final String? ipAddress;
  final DateTime createdAt;

  AuditLogModel({
    required this.id,
    this.actorId,
    required this.action,
    this.resourceType,
    this.resourceId,
    this.metadata = const {},
    this.ipAddress,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AuditLogModel.fromJson(Map<String, dynamic> json) {
    return AuditLogModel(
      id: json['id'] as String,
      actorId: json['actor_id'] as String?,
      action: json['action'] as String,
      resourceType: json['resource_type'] as String?,
      resourceId: json['resource_id'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      ipAddress: json['ip_address'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'actor_id': actorId,
      'action': action,
      'resource_type': resourceType,
      'resource_id': resourceId,
      'metadata': metadata,
      'ip_address': ipAddress,
    };
  }
}
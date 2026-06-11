enum UserRole {
  patient,
  family,
  communitySupporter,
  driver,
  hospital,
  moderator,
  admin;

  String get value {
    switch (this) {
      case UserRole.patient:
        return 'patient';
      case UserRole.family:
        return 'family';
      case UserRole.communitySupporter:
        return 'community_supporter';
      case UserRole.driver:
        return 'driver';
      case UserRole.hospital:
        return 'hospital';
      case UserRole.moderator:
        return 'moderator';
      case UserRole.admin:
        return 'admin';
    }
  }

  static UserRole fromString(String value) {
    switch (value) {
      case 'patient':
        return UserRole.patient;
      case 'family':
        return UserRole.family;
      case 'community_supporter':
        return UserRole.communitySupporter;
      case 'driver':
        return UserRole.driver;
      case 'hospital':
        return UserRole.hospital;
      case 'moderator':
        return UserRole.moderator;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.patient;
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.patient:
        return 'Patient';
      case UserRole.family:
        return 'Family Member';
      case UserRole.communitySupporter:
        return 'Community Supporter';
      case UserRole.driver:
        return 'Driver';
      case UserRole.hospital:
        return 'Hospital';
      case UserRole.moderator:
        return 'Moderator';
      case UserRole.admin:
        return 'Admin';
    }
  }
}
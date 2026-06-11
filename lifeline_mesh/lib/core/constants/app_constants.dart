class AppConstants {
  AppConstants._();

  static const String appName = 'Lifeline Mesh';
  static const String tagline = 'From emergency to treatment — coordinated, funded, and delivered in real time.';

  // Emergency
  static const int sosHoldDurationSeconds = 3;
  static const int emergencyCreationTimeoutSeconds = 30;
  static const int locationUpdateIntervalMs = 5000;
  static const int driverSearchRadiusKm = 15;

  // UI
  static const double defaultPadding = 16.0;
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double sosButtonSize = 180.0;

  // Trust Scoring
  static const double trustScoreInitial = 50.0;
  static const double trustScoreMax = 100.0;
  static const double trustScoreCommunityValidation = 5.0;
  static const double trustScoreDriverConfirmation = 10.0;
  static const double trustScoreHospitalConfirmation = 15.0;

  // Pagination
  static const int defaultPageSize = 20;
}
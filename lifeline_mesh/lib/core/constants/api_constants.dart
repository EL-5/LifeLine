class ApiConstants {
  ApiConstants._();

  // Supabase
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://gkhlrqlgmkreubsruzej.supabase.co',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdraGxycWxnbWtyZXVic3J1emVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODExMjc5MTgsImV4cCI6MjA5NjcwMzkxOH0.YHYs6yD9gPEOrA7FwY36N26M3jPotrn4f70bh5FnDiA',
  );

  // Tables
  static const String tableUsers = 'users';
  static const String tableEmergencies = 'emergencies';
  static const String tableFamilyConnections = 'family_connections';
  static const String tableContributions = 'contributions';
  static const String tableDrivers = 'drivers';
  static const String tableHospitals = 'hospitals';
  static const String tablePayments = 'payments';
  static const String tableAuditLogs = 'audit_logs';
  static const String tableTrustEvents = 'trust_events';

  // Realtime Channels
  static const String channelEmergencies = 'emergencies';
  static const String channelDriverLocation = 'driver-location';
  static const String channelFunding = 'funding-updates';

  // Edge Functions
  static const String fnCreateEmergency = 'create-emergency';
  static const String fnDispatchDriver = 'dispatch-driver';
  static const String fnAiTriage = 'ai-triage';
  static const String fnProcessContribution = 'process-contribution';
  static const String fnReleasePayment = 'release-payment';
  static const String fnFraudDetection = 'fraud-detection';
  static const String fnSendNotification = 'send-notification';
  static const String fnGenerateReport = 'generate-report';
}
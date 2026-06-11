enum EmergencyStatus {
  pending,
  dispatched,
  driverAssigned,
  driverArrived,
  enRouteHospital,
  arrivedHospital,
  inTreatment,
  completed,
  cancelled,
  flagged;

  String get value {
    switch (this) {
      case EmergencyStatus.pending:
        return 'pending';
      case EmergencyStatus.dispatched:
        return 'dispatched';
      case EmergencyStatus.driverAssigned:
        return 'driver_assigned';
      case EmergencyStatus.driverArrived:
        return 'driver_arrived';
      case EmergencyStatus.enRouteHospital:
        return 'en_route_hospital';
      case EmergencyStatus.arrivedHospital:
        return 'arrived_hospital';
      case EmergencyStatus.inTreatment:
        return 'in_treatment';
      case EmergencyStatus.completed:
        return 'completed';
      case EmergencyStatus.cancelled:
        return 'cancelled';
      case EmergencyStatus.flagged:
        return 'flagged';
    }
  }

  static EmergencyStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return EmergencyStatus.pending;
      case 'dispatched':
        return EmergencyStatus.dispatched;
      case 'driver_assigned':
        return EmergencyStatus.driverAssigned;
      case 'driver_arrived':
        return EmergencyStatus.driverArrived;
      case 'en_route_hospital':
        return EmergencyStatus.enRouteHospital;
      case 'arrived_hospital':
        return EmergencyStatus.arrivedHospital;
      case 'in_treatment':
        return EmergencyStatus.inTreatment;
      case 'completed':
        return EmergencyStatus.completed;
      case 'cancelled':
        return EmergencyStatus.cancelled;
      case 'flagged':
        return EmergencyStatus.flagged;
      default:
        return EmergencyStatus.pending;
    }
  }

  bool get isActive => this != EmergencyStatus.completed &&
      this != EmergencyStatus.cancelled;

  bool get needsDriver => this == EmergencyStatus.pending ||
      this == EmergencyStatus.dispatched;
}
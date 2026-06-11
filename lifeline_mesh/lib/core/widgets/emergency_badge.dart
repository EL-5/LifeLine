import 'package:flutter/material.dart';
import '../../models/enums/severity_level.dart';
import '../../models/enums/emergency_status.dart';
import '../theme/colors.dart';

class SeverityBadge extends StatelessWidget {
  final SeverityLevel severity;

  const SeverityBadge({super.key, required this.severity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: severity.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        severity.displayName,
        style: TextStyle(
          color: severity.color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final EmergencyStatus status;

  const StatusBadge({super.key, required this.status});

  Color get _color {
    switch (status) {
      case EmergencyStatus.pending:
        return AppColors.statusPending;
      case EmergencyStatus.dispatched:
      case EmergencyStatus.driverAssigned:
      case EmergencyStatus.driverArrived:
      case EmergencyStatus.enRouteHospital:
        return AppColors.statusActive;
      case EmergencyStatus.arrivedHospital:
      case EmergencyStatus.inTreatment:
      case EmergencyStatus.completed:
        return AppColors.statusCompleted;
      case EmergencyStatus.cancelled:
        return AppColors.statusCancelled;
      case EmergencyStatus.flagged:
        return AppColors.statusFlagged;
    }
  }

  String get _label {
    switch (status) {
      case EmergencyStatus.pending:
        return 'Pending';
      case EmergencyStatus.dispatched:
        return 'Dispatched';
      case EmergencyStatus.driverAssigned:
        return 'Driver Assigned';
      case EmergencyStatus.driverArrived:
        return 'Driver Arrived';
      case EmergencyStatus.enRouteHospital:
        return 'En Route to Hospital';
      case EmergencyStatus.arrivedHospital:
        return 'Arrived at Hospital';
      case EmergencyStatus.inTreatment:
        return 'In Treatment';
      case EmergencyStatus.completed:
        return 'Completed';
      case EmergencyStatus.cancelled:
        return 'Cancelled';
      case EmergencyStatus.flagged:
        return 'Flagged';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _label,
        style: TextStyle(
          color: _color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
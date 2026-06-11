import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

enum SeverityLevel {
  critical,
  serious,
  moderate,
  mild;

  String get value {
    switch (this) {
      case SeverityLevel.critical:
        return 'critical';
      case SeverityLevel.serious:
        return 'serious';
      case SeverityLevel.moderate:
        return 'moderate';
      case SeverityLevel.mild:
        return 'mild';
    }
  }

  static SeverityLevel fromString(String value) {
    switch (value) {
      case 'critical':
        return SeverityLevel.critical;
      case 'serious':
        return SeverityLevel.serious;
      case 'moderate':
        return SeverityLevel.moderate;
      case 'mild':
        return SeverityLevel.mild;
      default:
        return SeverityLevel.moderate;
    }
  }

  Color get color {
    switch (this) {
      case SeverityLevel.critical:
        return AppColors.severityCritical;
      case SeverityLevel.serious:
        return AppColors.severitySerious;
      case SeverityLevel.moderate:
        return AppColors.severityModerate;
      case SeverityLevel.mild:
        return AppColors.severityMild;
    }
  }

  String get displayName {
    switch (this) {
      case SeverityLevel.critical:
        return 'Critical';
      case SeverityLevel.serious:
        return 'Serious';
      case SeverityLevel.moderate:
        return 'Moderate';
      case SeverityLevel.mild:
        return 'Mild';
    }
  }

  int get responsePriority => index;
}
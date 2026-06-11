import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/emergency_badge.dart';
import '../../../providers/emergency_provider.dart';
import '../../../models/enums/emergency_status.dart';
import '../../../models/emergency_model.dart';

class EmergencyLiveTrackingScreen extends ConsumerWidget {
  final String emergencyId;

  const EmergencyLiveTrackingScreen({
    super.key,
    required this.emergencyId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emergencyAsync = ref.watch(emergencyDetailProvider(emergencyId));

    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Tracking')),
      body: emergencyAsync.when(
        data: (emergency) {
          if (emergency == null) {
            return const Center(child: Text('Emergency not found'));
          }
          return _TrackingContent(emergency: emergency);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _TrackingContent extends StatelessWidget {
  final EmergencyModel emergency;

  const _TrackingContent({required this.emergency});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Timeline
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.timeline, color: AppColors.trustBlue),
                      const SizedBox(width: 8),
                      Text('Status Timeline', style: AppTextStyles.titleMedium),
                      const Spacer(),
                      StatusBadge(status: emergency.status),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _StatusStep(
                    icon: Icons.warning,
                    label: 'Emergency Reported',
                    isComplete: true,
                    isActive: true,
                  ),
                  _StatusStep(
                    icon: Icons.directions_car,
                    label: 'Driver Dispatched',
                    isComplete: emergency.status.index >= EmergencyStatus.dispatched.index,
                    isActive: emergency.status == EmergencyStatus.dispatched,
                  ),
                  _StatusStep(
                    icon: Icons.person_pin,
                    label: 'Driver Arrived',
                    isComplete: emergency.status.index >= EmergencyStatus.driverArrived.index,
                    isActive: emergency.status == EmergencyStatus.driverArrived,
                  ),
                  _StatusStep(
                    icon: Icons.local_hospital,
                    label: 'Arrived at Hospital',
                    isComplete: emergency.status.index >= EmergencyStatus.arrivedHospital.index,
                    isActive: emergency.status == EmergencyStatus.arrivedHospital,
                  ),
                  _StatusStep(
                    icon: Icons.check_circle,
                    label: 'In Treatment',
                    isComplete: emergency.status.index >= EmergencyStatus.inTreatment.index,
                    isActive: emergency.status == EmergencyStatus.inTreatment,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Map placeholder
          Card(
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.calmBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map, size: 48, color: AppColors.textSecondary),
                    SizedBox(height: 8),
                    Text('Live map will appear here'),
                    Text(
                      'Google Maps / OSM integration',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Emergency Details
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Emergency Details', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 12),
                  _detailRow('Category', emergency.category),
                  _detailRow('Severity', emergency.severity.displayName),
                  _detailRow('Emergency ID', emergency.id.substring(0, 8)),
                  _detailRow('Status', emergency.status.value),
                  if (emergency.targetAmount > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Funding: GHS ${emergency.raisedAmount} / GHS ${emergency.targetAmount}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: emergency.fundingProgress,
                      backgroundColor: AppColors.divider,
                      color: AppColors.successGreen,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(color: AppColors.textSecondary)),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class _StatusStep extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isComplete;
  final bool isActive;

  const _StatusStep({
    required this.icon,
    required this.label,
    required this.isComplete,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final color = isComplete
        ? AppColors.successGreen
        : isActive
            ? AppColors.statusActive
            : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isComplete ? Icons.check : icon,
              size: 16,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isComplete || isActive ? Colors.black : AppColors.textSecondary,
            ),
          ),
          if (isActive)
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
    );
  }
}
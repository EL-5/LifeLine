import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/emergency_badge.dart';
import '../../../providers/emergency_provider.dart';

class EmergencyDetailScreen extends ConsumerWidget {
  final String emergencyId;

  const EmergencyDetailScreen({super.key, required this.emergencyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emergencyAsync = ref.watch(emergencyDetailProvider(emergencyId));

    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Details')),
      body: emergencyAsync.when(
        data: (emergency) {
          if (emergency == null) {
            return const Center(child: Text('Emergency not found'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Patient & Status
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SeverityBadge(severity: emergency.severity),
                            const SizedBox(width: 8),
                            StatusBadge(status: emergency.status),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(emergency.category,
                            style: AppTextStyles.titleLarge),
                        const SizedBox(height: 8),
                        Text(
                          'Symptoms: ${emergency.symptoms.join(", ")}',
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ETA & Transport
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Transport Info', style: AppTextStyles.titleMedium),
                        const SizedBox(height: 12),
                        _row('ETA', '12 minutes'),
                        _row('Driver', 'Assigning...'),
                        _row('Distance', '3.2 km'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Cost Estimate
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Treatment Estimate', style: AppTextStyles.titleMedium),
                        const SizedBox(height: 12),
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Estimated Cost (GHS)',
                            hintText: 'Enter treatment cost estimate',
                            prefixText: 'GHS ',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        AppButton(
                          label: 'Submit Estimate',
                          onPressed: () {},
                          type: ButtonType.primary,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Mark Ready',
                        onPressed: () {},
                        type: ButtonType.success,
                        icon: Icons.check,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        label: 'Confirm Arrival',
                        onPressed: () {},
                        type: ButtonType.primary,
                        icon: Icons.local_hospital,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(color: AppColors.textSecondary)),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/empty_state.dart';

class FraudMonitoringScreen extends StatefulWidget {
  const FraudMonitoringScreen({super.key});

  @override
  State<FraudMonitoringScreen> createState() => _FraudMonitoringScreenState();
}

class _FraudMonitoringScreenState extends State<FraudMonitoringScreen> {
  final List<Map<String, dynamic>> _flaggedEmergencies = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fraud Monitoring')),
      body: _flaggedEmergencies.isEmpty
          ? const EmptyState(
              icon: Icons.shield_outlined,
              title: 'No Flagged Emergencies',
              subtitle: 'All emergencies are currently clean',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _flaggedEmergencies.length,
              itemBuilder: (context, index) {
                return Card(
                  color: AppColors.emergencyRedLight,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.warning, color: AppColors.emergencyRed),
                            const SizedBox(width: 8),
                            Text('Flagged Emergency', style: AppTextStyles.titleSmall),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Suspicious behavior detected by AI',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: AppButton(
                                label: 'Dismiss Flag',
                                onPressed: () {},
                                type: ButtonType.secondary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: AppButton(
                                label: 'Override',
                                onPressed: () {},
                                type: ButtonType.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
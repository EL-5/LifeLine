import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/app_button.dart';

class IncomingRequestScreen extends StatelessWidget {
  final String emergencyId;

  const IncomingRequestScreen({super.key, required this.emergencyId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Request')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.emergencyRedLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.emergency,
                        color: AppColors.emergencyRed,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Accident Emergency', style: AppTextStyles.titleLarge),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.severityCritical.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Critical',
                        style: TextStyle(
                          color: AppColors.severityCritical,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _detailRow(Icons.person, 'Patient', 'John Doe'),
                    _detailRow(Icons.location_on, 'Location', 'Accra Central, 2.3 km'),
                    _detailRow(Icons.phone, 'Contact', '+233 XX XXX XXXX'),
                    _detailRow(Icons.description, 'Note', 'Patient is conscious, bleeding'),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Decline',
                    onPressed: () => context.pop(),
                    type: ButtonType.danger,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: 'Accept & Navigate',
                    onPressed: () => context.push('/driver/navigate/$emergencyId'),
                    type: ButtonType.emergency,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(color: AppColors.textSecondary)),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
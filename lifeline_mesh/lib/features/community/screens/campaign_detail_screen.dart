import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/app_button.dart';

class CampaignDetailScreen extends StatefulWidget {
  final String emergencyId;

  const CampaignDetailScreen({super.key, required this.emergencyId});

  @override
  State<CampaignDetailScreen> createState() => _CampaignDetailScreenState();
}

class _CampaignDetailScreenState extends State<CampaignDetailScreen> {
  double _contributionAmount = 50;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Campaign Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.emergencyRedLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.emergency,
                            color: AppColors.emergencyRed,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Emergency Campaign', style: AppTextStyles.titleMedium),
                              const Text(
                                'Accra, Ghana',
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: 0.45,
                      backgroundColor: AppColors.divider,
                      color: AppColors.successGreen,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _statColumn('Raised', 'GHS 1,800'),
                        _statColumn('Target', 'GHS 4,000'),
                        _statColumn('Supporters', '24'),
                        _statColumn('Remaining', 'GHS 2,200'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Make a Contribution', style: AppTextStyles.titleLarge),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'GHS ${_contributionAmount.toStringAsFixed(0)}',
                      style: AppTextStyles.displayMedium.copyWith(
                        color: AppColors.successGreen,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: [10, 25, 50, 100, 200, 500].map((amount) {
                        final isSelected = _contributionAmount == amount;
                        return ChoiceChip(
                          label: Text('GHS $amount'),
                          selected: isSelected,
                          selectedColor: AppColors.successGreenLight,
                          onSelected: (_) =>
                              setState(() => _contributionAmount = amount.toDouble()),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      label: 'Contribute GHS ${_contributionAmount.toStringAsFixed(0)}',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Contribution initiated')),
                        );
                      },
                      type: ButtonType.success,
                      icon: Icons.favorite,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Transparency Dashboard', style: AppTextStyles.titleLarge),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _transparencyRow(Icons.local_hospital, 'Hospital', 'Ready'),
                    const Divider(),
                    _transparencyRow(Icons.directions_car, 'Driver', 'Assigned'),
                    const Divider(),
                    _transparencyRow(Icons.people, 'Family', 'Notified'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }

  Widget _transparencyRow(IconData icon, String label, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.successGreenLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Done',
              style: TextStyle(
                color: AppColors.successGreen,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
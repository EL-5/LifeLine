import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/emergency_badge.dart';
import '../../../models/emergency_model.dart';

class EmergencyCard extends StatelessWidget {
  final EmergencyModel emergency;
  final VoidCallback? onTap;

  const EmergencyCard({
    super.key,
    required this.emergency,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: emergency.severity.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.emergency,
                      color: emergency.severity.color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      emergency.category,
                      style: AppTextStyles.titleSmall,
                    ),
                  ),
                  SeverityBadge(severity: emergency.severity),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  StatusBadge(status: emergency.status),
                  const Spacer(),
                  Text(
                    'GHS ${emergency.raisedAmount} / GHS ${emergency.targetAmount}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.successGreen,
                    ),
                  ),
                ],
              ),
              if (emergency.targetAmount > 0) ...[
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: emergency.fundingProgress,
                  backgroundColor: AppColors.divider,
                  color: AppColors.successGreen,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
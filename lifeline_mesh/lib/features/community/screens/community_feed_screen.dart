import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/empty_state.dart';

class CommunityFeedScreen extends StatefulWidget {
  const CommunityFeedScreen({super.key});

  @override
  State<CommunityFeedScreen> createState() => _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends State<CommunityFeedScreen> {
  final List<Map<String, dynamic>> _campaigns = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Community Support')),
      body: _campaigns.isEmpty
          ? EmptyState(
              icon: Icons.volunteer_activism,
              title: 'No Active Campaigns',
              subtitle: 'Verified emergency campaigns needing support will appear here',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _campaigns.length,
              itemBuilder: (context, index) {
                final campaign = _campaigns[index];
                return _CampaignCard(
                  campaign: campaign,
                  onTap: () => context.push(
                    '/community/campaign/${campaign['id']}',
                  ),
                );
              },
            ),
    );
  }
}

class _CampaignCard extends StatelessWidget {
  final Map<String, dynamic> campaign;
  final VoidCallback onTap;

  const _CampaignCard({required this.campaign, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final progress = (campaign['raised'] as num?)?.toDouble() ?? 0;
    final target = (campaign['target'] as num?)?.toDouble() ?? 1;

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
                        Text(
                          campaign['title'] ?? 'Emergency Campaign',
                          style: AppTextStyles.titleSmall,
                        ),
                        Text(
                          campaign['location'] ?? 'Unknown location',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.successGreenLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Verified',
                      style: TextStyle(
                        color: AppColors.successGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: progress / target,
                backgroundColor: AppColors.divider,
                color: AppColors.successGreen,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'GHS ${progress.toStringAsFixed(0)} raised',
                    style: const TextStyle(
                      color: AppColors.successGreen,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'GHS ${target.toStringAsFixed(0)} target',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Contribute Now',
                onPressed: onTap,
                type: ButtonType.success,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
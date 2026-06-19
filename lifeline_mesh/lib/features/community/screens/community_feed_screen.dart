import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../providers/community_provider.dart';

class CommunityFeedScreen extends ConsumerWidget {
  const CommunityFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaignsAsync = ref.watch(communityEmergenciesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Community Support')),
      body: campaignsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (campaigns) => campaigns.isEmpty
            ? const EmptyState(
                icon: Icons.volunteer_activism,
                title: 'No Active Campaigns',
                subtitle:
                    'Verified emergency campaigns needing support will appear here',
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: campaigns.length,
                itemBuilder: (context, index) {
                  final campaign = campaigns[index];
                  return _CampaignCard(
                    title: campaign.category,
                    location: campaign.location['address'] as String? ??
                        'Unknown location',
                    raised: campaign.raisedAmount,
                    target: campaign.targetAmount,
                    onTap: () => context.push(
                      '/community/campaign/${campaign.id}',
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _CampaignCard extends StatelessWidget {
  final String title;
  final String location;
  final double raised;
  final double target;
  final VoidCallback onTap;

  const _CampaignCard({
    required this.title,
    required this.location,
    required this.raised,
    required this.target,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = target > 0 ? (raised / target).clamp(0.0, 1.0) : 0.0;

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
                          title,
                          style: AppTextStyles.titleSmall,
                        ),
                        Text(
                          location,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                value: progress,
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
                    'GHS ${raised.toStringAsFixed(0)} raised',
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
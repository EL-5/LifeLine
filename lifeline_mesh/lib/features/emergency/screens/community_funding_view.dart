import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../providers/emergency_provider.dart';

class CommunityFundingView extends ConsumerWidget {
  const CommunityFundingView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emergenciesAsync = ref.watch(communityEmergenciesProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: emergenciesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading feed: $err')),
        data: (emergencies) {
          if (emergencies.isEmpty) {
            return const Center(
              child: Text(
                'No active emergencies require funding at the moment.\nThank you for being a hero!',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: emergencies.length,
            itemBuilder: (context, index) {
              final em = emergencies[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              em.category.replaceAll('_', ' ').toUpperCase(),
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.trustBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              em.status.name,
                              style: const TextStyle(color: AppColors.trustBlue, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Mock Patient Name Fetching
                      Consumer(
                        builder: (context, ref, child) {
                          final patientData = ref.watch(patientDetailsProvider(em.patientId));
                          return patientData.when(
                            data: (data) => Text(
                              'Patient: ${data?['full_name'] ?? 'Anonymous Member'}',
                              style: const TextStyle(color: AppColors.textSecondary),
                            ),
                            loading: () => const Text('Loading patient...', style: TextStyle(color: AppColors.textSecondary)),
                            error: (_, __) => const Text('Patient: Anonymous'),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: em.fundingProgress,
                        backgroundColor: AppColors.divider,
                        color: AppColors.successGreen,
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'GHS ${em.raisedAmount} raised',
                            style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.successGreen),
                          ),
                          Text(
                            'Goal: GHS ${em.targetAmount}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (em.raisedAmount >= em.targetAmount && em.targetAmount > 0)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.successGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Fully Funded! 🎉',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.successGreen, fontWeight: FontWeight.bold),
                          ),
                        )
                      else
                        AppButton(
                          label: 'Contribute Now',
                          icon: Icons.volunteer_activism,
                          onPressed: () => _showDonationModal(context, em.id),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showDonationModal(BuildContext context, String emergencyId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite, color: AppColors.emergencyRed, size: 48),
            const SizedBox(height: 16),
            const Text('Support Your Community', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Select an amount to simulate a contribution. 100% of your donation goes directly to emergency care.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _DonationChip(amount: 50, emergencyId: emergencyId),
                _DonationChip(amount: 100, emergencyId: emergencyId),
                _DonationChip(amount: 500, emergencyId: emergencyId),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _DonationChip extends StatelessWidget {
  final double amount;
  final String emergencyId;

  const _DonationChip({required this.amount, required this.emergencyId});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text('GHS ${amount.toInt()}'),
      labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      backgroundColor: AppColors.trustBlue,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      onPressed: () async {
        Navigator.pop(context); // Close modal
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Processing donation...')));
        
        try {
          await EmergencyFundingService.contribute(emergencyId, amount);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Thank you! GHS $amount contributed successfully.')));
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to contribute: $e')));
          }
        }
      },
    );
  }
}

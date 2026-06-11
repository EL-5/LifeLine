import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../providers/driver_provider.dart';

class DriverDashboard extends ConsumerWidget {
  const DriverDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableEmergencies = ref.watch(availableEmergenciesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver'),
        actions: [
          IconButton(
            icon: const Icon(Icons.earbuds),
            onPressed: () => context.push('/driver/earnings'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Availability Toggle
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.circle, color: AppColors.successGreen, size: 12),
                  const SizedBox(width: 8),
                  const Text('Available for emergencies',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  const Spacer(),
                  Switch(
                    value: true,
                    onChanged: (_) {},
                    activeColor: AppColors.successGreen,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: availableEmergencies.when(
              data: (emergencies) {
                if (emergencies.isEmpty) {
                  return const EmptyState(
                    icon: Icons.check_circle_outline,
                    title: 'No Emergencies',
                    subtitle: 'You\'ll be notified when an emergency occurs nearby',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: emergencies.length,
                  itemBuilder: (context, index) {
                    final emergency = emergencies[index];
                    return Card(
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
                                    color: AppColors.emergencyRedLight,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.emergency,
                                    color: AppColors.emergencyRed,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(emergency.category,
                                          style: AppTextStyles.titleSmall),
                                      Text(
                                        '${emergency.location['address'] ?? 'Unknown location'}',
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(Icons.speed, size: 16,
                                    color: emergency.severity.color),
                                const SizedBox(width: 4),
                                Text(emergency.severity.displayName,
                                    style: TextStyle(
                                      color: emergency.severity.color,
                                      fontWeight: FontWeight.w600,
                                    )),
                                const Spacer(),
                                Icon(Icons.location_on,
                                    size: 16, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                const Text('2.3 km away',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    )),
                              ],
                            ),
                            const SizedBox(height: 12),
                            AppButton(
                              label: 'Accept Request',
                              onPressed: () => context.push(
                                '/driver/request/${emergency.id}',
                              ),
                              type: ButtonType.emergency,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
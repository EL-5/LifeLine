import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/emergency_badge.dart';
import '../../../providers/hospital_provider.dart';
import '../../../providers/auth_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HospitalDashboard extends ConsumerWidget {
  const HospitalDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emergencies = ref.watch(hospitalIncomingEmergenciesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hospital Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statItem('Incoming', '3', AppColors.warningAmber),
                _statItem('Critical', '1', AppColors.severityCritical),
                _statItem('Avg ETA', '12 min', AppColors.trustBlue),
              ],
            ),
          ),
          Expanded(
            child: emergencies.when(
              data: (list) {
                if (list.isEmpty) {
                  return const EmptyState(
                    icon: Icons.check_circle,
                    title: 'No Incoming Emergencies',
                    subtitle: 'Hospital is clear',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final emergency = list[index];
                    return Card(
                      child: InkWell(
                        onTap: () => context.push(
                          '/hospital/emergency/${emergency.id}',
                        ),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  SeverityBadge(severity: emergency.severity),
                                  const Spacer(),
                                  const Icon(Icons.access_time,
                                      size: 14, color: AppColors.textSecondary),
                                  const SizedBox(width: 4),
                                  const Text('ETA: 12 min',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      )),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                emergency.category,
                                style: AppTextStyles.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${emergency.symptoms.length} symptoms reported',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(Icons.people, size: 16,
                                      color: AppColors.textSecondary),
                                  const SizedBox(width: 4),
                                  const Text('Family notified',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      )),
                                  const Spacer(),
                                  const Icon(Icons.monetization_on,
                                      size: 16, color: AppColors.successGreen),
                                  const SizedBox(width: 4),
                                  Text(
                                    'GHS ${emergency.targetAmount.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.successGreen,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        // TODO: Mark as ready
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.successGreen,
                                        side: const BorderSide(color: AppColors.successGreen),
                                      ),
                                      child: const Text('Mark Ready'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => context.push(
                                        '/hospital/emergency/${emergency.id}',
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.trustBlue,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('View Details'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).animate().fadeIn(duration: 300.ms, delay: (index * 100).ms).slideY(begin: 0.1);
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

  Widget _statItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 24,
              color: color,
            )),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../providers/driver_provider.dart';

class DriverDashboard extends ConsumerStatefulWidget {
  const DriverDashboard({super.key});

  @override
  ConsumerState<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends ConsumerState<DriverDashboard> {
  bool _isAvailable = false;
  bool _isUpdatingAvailability = false;

  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }

  Future<void> _loadAvailability() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    final result = await Supabase.instance.client
        .from('drivers')
        .select('availability_status')
        .eq('user_id', userId)
        .maybeSingle();
    if (mounted && result != null) {
      setState(() => _isAvailable = result['availability_status'] as bool? ?? false);
    }
  }

  Future<void> _toggleAvailability(bool value) async {
    if (_isUpdatingAvailability) return;
    setState(() => _isUpdatingAvailability = true);
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;
      await Supabase.instance.client
          .from('drivers')
          .update({'availability_status': value}).eq('user_id', userId);
      setState(() => _isAvailable = value);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdatingAvailability = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableEmergencies = ref.watch(availableEmergenciesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver'),
        actions: [
          IconButton(
            icon: const Icon(Icons.monetization_on),
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
                  Icon(
                    Icons.circle,
                    color: _isAvailable
                        ? AppColors.successGreen
                        : AppColors.textSecondary,
                    size: 12,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isAvailable
                        ? 'Available for emergencies'
                        : 'Currently offline',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  _isUpdatingAvailability
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Switch(
                          value: _isAvailable,
                          onChanged: _toggleAvailability,
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
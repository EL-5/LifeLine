import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../providers/admin_provider.dart';

class DriverApprovalsScreen extends ConsumerWidget {
  const DriverApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingDriversProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Approvals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(pendingDriversProvider),
          )
        ],
      ),
      body: pendingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (drivers) {
          if (drivers.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 64, color: AppColors.successGreen),
                  SizedBox(height: 16),
                  Text('All caught up!', style: TextStyle(fontSize: 18, color: AppColors.textSecondary)),
                  Text('No pending driver applications.', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: drivers.length,
            itemBuilder: (context, index) {
              final d = drivers[index];
              final user = d['users'] ?? {};
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: AppColors.trustBlue,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user['full_name'] ?? 'Unknown User', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text(user['email'] ?? 'No email', style: const TextStyle(color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      const Text('Vehicle Information', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.trustBlue)),
                      const SizedBox(height: 8),
                      Text('Vehicle: ${d['vehicle_type'] ?? 'N/A'}'),
                      Text('Registration: ${d['vehicle_registration'] ?? 'N/A'}'),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _handleReject(context, ref, d['id']),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.emergencyRed,
                                side: const BorderSide(color: AppColors.emergencyRed),
                              ),
                              child: const Text('Reject'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _handleApprove(context, ref, d['id'], d['user_id']),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.successGreen,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Approve'),
                            ),
                          ),
                        ],
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

  void _handleApprove(BuildContext context, WidgetRef ref, String driverId, String userId) async {
    try {
      await ref.read(adminControllerProvider).approveDriver(driverId, userId);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Driver approved!')));
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _handleReject(BuildContext context, WidgetRef ref, String driverId) async {
    try {
      await ref.read(adminControllerProvider).rejectDriver(driverId);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Application rejected.')));
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}

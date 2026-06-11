import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/emergency_badge.dart';
import '../../../providers/emergency_provider.dart';

class EmergencyHistoryScreen extends ConsumerWidget {
  const EmergencyHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emergencies = ref.watch(emergencyListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Emergency History')),
      body: emergencies.when(
        data: (list) {
          if (list.isEmpty) {
            return const EmptyState(
              icon: Icons.history,
              title: 'No Emergency History',
              subtitle: 'Your past emergencies will appear here',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final emergency = list[index];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: emergency.severity.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.emergency,
                      color: emergency.severity.color,
                    ),
                  ),
                  title: Text(
                    emergency.category,
                    style: AppTextStyles.titleSmall,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          SeverityBadge(severity: emergency.severity),
                          const SizedBox(width: 8),
                          StatusBadge(status: emergency.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(emergency.createdAt),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Navigate to emergency detail
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
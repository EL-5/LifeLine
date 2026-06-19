import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../providers/admin_provider.dart';

class FraudMonitoringScreen extends ConsumerWidget {
  const FraudMonitoringScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flaggedAsync = ref.watch(flaggedEmergenciesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Fraud Monitoring')),
      body: flaggedAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (flagged) => flagged.isEmpty
            ? const EmptyState(
                icon: Icons.shield_outlined,
                title: 'No Flagged Emergencies',
                subtitle: 'All emergencies are currently clean',
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: flagged.length,
                itemBuilder: (context, index) {
                  final emergency = flagged[index];
                  return Card(
                    color: AppColors.emergencyRedLight,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.warning,
                                  color: AppColors.emergencyRed),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Flagged: ${emergency.category}',
                                  style: AppTextStyles.titleSmall,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ID: ${emergency.id.substring(0, 8)}',
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Severity: ${emergency.severity.displayName} | '
                            'Status: ${emergency.status.value}',
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 12),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: AppButton(
                                  label: 'Dismiss Flag',
                                  onPressed: () async {
                                    await Supabase.instance.client
                                        .from('emergencies')
                                        .update({'fraud_flag': false}).eq(
                                            'id', emergency.id);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content:
                                                  Text('Flag dismissed')));
                                    }
                                  },
                                  type: ButtonType.secondary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: AppButton(
                                  label: 'Cancel Emergency',
                                  onPressed: () async {
                                    await Supabase.instance.client
                                        .from('emergencies')
                                        .update({
                                      'fraud_flag': true,
                                      'status': 'cancelled'
                                    }).eq('id', emergency.id);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  'Emergency cancelled')));
                                    }
                                  },
                                  type: ButtonType.danger,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
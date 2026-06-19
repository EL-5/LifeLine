import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../providers/family_provider.dart';

class FamilyManagementScreen extends ConsumerWidget {
  const FamilyManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyAsync = ref.watch(familyConnectionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Network'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _showInviteDialog(context, ref),
          ),
        ],
      ),
      body: familyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (members) => members.isEmpty
            ? EmptyState(
                icon: Icons.people_outline,
                title: 'No Family Members',
                subtitle:
                    'Add family members to keep them informed during emergencies',
                action: AppButton(
                  label: 'Invite Family Member',
                  onPressed: () => _showInviteDialog(context, ref),
                  icon: Icons.person_add,
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: members.length,
                itemBuilder: (context, index) {
                  final member = members[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.trustBlueLight,
                        child: Text(
                          (member.relationshipType ?? 'F')[0].toUpperCase(),
                          style:
                              const TextStyle(color: AppColors.trustBlue),
                        ),
                      ),
                      title:
                          Text('Member ${member.familyMemberId.substring(0, 8)}'),
                      subtitle:
                          Text(member.relationshipType ?? 'Family'),
                      trailing: Text(
                        member.status,
                        style: TextStyle(
                          color: member.status == 'accepted'
                              ? AppColors.successGreen
                              : AppColors.warningAmber,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _showInviteDialog(BuildContext context, WidgetRef ref) {
    final phoneController = TextEditingController();
    final relController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        bool isSending = false;
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Invite Family Member'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: relController,
                  decoration: const InputDecoration(
                    labelText: 'Relationship',
                    hintText: 'e.g. Spouse, Parent, Child',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    hintText: '+233 XX XXX XXXX',
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              AppButton(
                label: isSending ? 'Sending...' : 'Send Invite',
                onPressed: isSending
                    ? null
                    : () async {
                        if (phoneController.text.isEmpty) return;
                        setState(() => isSending = true);
                        try {
                          final inviteFn =
                              ref.read(inviteFamilyMemberProvider);
                          await inviteFn(
                            phoneController.text.trim(),
                            relController.text.trim().isEmpty
                                ? 'Family'
                                : relController.text.trim(),
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Invite sent!')),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.toString()),
                                backgroundColor: AppColors.emergencyRed,
                              ),
                            );
                          }
                        } finally {
                          if (context.mounted) {
                            setState(() => isSending = false);
                          }
                        }
                      },
                type: ButtonType.primary,
              ),
            ],
          ),
        );
      },
    );
  }
}
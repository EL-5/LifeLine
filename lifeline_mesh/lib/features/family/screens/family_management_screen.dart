import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../providers/family_provider.dart';
import '../../../core/services/moolre_api_service.dart';

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
    String selectedRelation = 'emergency_friend';

    final relationships = [
      {'label': 'Parent', 'value': 'parent'},
      {'label': 'Spouse', 'value': 'spouse'},
      {'label': 'Sibling', 'value': 'sibling'},
      {'label': 'Guardian', 'value': 'guardian'},
      {'label': 'Emergency Friend', 'value': 'emergency_friend'},
    ];

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
                DropdownButtonFormField<String>(
                  value: selectedRelation,
                  decoration: const InputDecoration(
                    labelText: 'Relationship',
                    border: OutlineInputBorder(),
                  ),
                  items: relationships.map((rel) {
                    return DropdownMenuItem(
                      value: rel['value'],
                      child: Text(rel['label']!),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => selectedRelation = val);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    hintText: '+233 XX XXX XXXX',
                    border: OutlineInputBorder(),
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
                        final phone = phoneController.text.trim();
                        if (phone.isEmpty) return;
                        
                        setState(() => isSending = true);
                        try {
                          final inviteFn = ref.read(inviteFamilyMemberProvider);
                          final moolre = ref.read(moolreApiServiceProvider);
                          
                          try {
                            // Try linking internally first
                            await inviteFn(phone, selectedRelation);
                            
                            // If successful, they have an account
                            await moolre.sendEmergencySms(
                              phone: phone, 
                              message: "Hello! I've added you to my Lifeline Mesh Family Network. Please open the app and accept the invite."
                            );
                            await moolre.sendEmergencyWhatsApp(
                              phone: phone, 
                              message: "🏥 *Lifeline Mesh Family Invite*\n\nHello! I've added you to my Family Network so you are notified during emergencies. Please open the app and accept."
                            );

                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invite sent! Member notified.')));
                            }
                          } catch (innerE) {
                            if (innerE.toString().contains('Ask them to sign up first')) {
                              // They are not on the app. Send them an invite to join!
                              await moolre.sendEmergencySms(
                                phone: phone, 
                                message: "I am using Lifeline Mesh for my medical emergencies. Join my Family Network to be notified instantly if I need help. Download: https://lifelinemesh.com"
                              );
                              await moolre.sendEmergencyWhatsApp(
                                phone: phone, 
                                message: "🏥 *Lifeline Mesh Invitation*\n\nI am using Lifeline Mesh for my medical emergencies. Please join my Family Network to be notified instantly if I need help.\n\nDownload the app: https://lifelinemesh.com"
                              );
                              
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('SMS/WhatsApp Invite sent for them to join the app!')));
                              }
                            } else {
                              throw innerE; // Re-throw real errors
                            }
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
import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/empty_state.dart';

class FamilyManagementScreen extends StatefulWidget {
  const FamilyManagementScreen({super.key});

  @override
  State<FamilyManagementScreen> createState() => _FamilyManagementScreenState();
}

class _FamilyManagementScreenState extends State<FamilyManagementScreen> {
  final List<Map<String, String>> _familyMembers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Network'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _showInviteDialog,
          ),
        ],
      ),
      body: _familyMembers.isEmpty
          ? EmptyState(
              icon: Icons.people_outline,
              title: 'No Family Members',
              subtitle: 'Add family members to keep them informed during emergencies',
              action: AppButton(
                label: 'Invite Family Member',
                onPressed: _showInviteDialog,
                icon: Icons.person_add,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _familyMembers.length,
              itemBuilder: (context, index) {
                final member = _familyMembers[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.trustBlueLight,
                      child: Text(
                        member['name']![0].toUpperCase(),
                        style: const TextStyle(color: AppColors.trustBlue),
                      ),
                    ),
                    title: Text(member['name']!),
                    subtitle: Text(member['relationship']!),
                    trailing: Text(
                      member['status']!,
                      style: TextStyle(
                        color: member['status'] == 'Accepted'
                            ? AppColors.successGreen
                            : AppColors.warningAmber,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showInviteDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invite Family Member'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                hintText: 'Enter name',
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
            label: 'Send Invite',
            onPressed: () {
              if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                setState(() {
                  _familyMembers.add({
                    'name': nameController.text,
                    'relationship': 'Family',
                    'status': 'Invited',
                  });
                });
                Navigator.pop(context);
              }
            },
            type: ButtonType.primary,
          ),
        ],
      ),
    );
  }
}
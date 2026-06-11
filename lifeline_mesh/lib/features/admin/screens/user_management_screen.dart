import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/empty_state.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final _searchController = TextEditingController();
  final List<Map<String, String>> _users = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users by name or phone...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: _users.isEmpty
                ? const EmptyState(
                    icon: Icons.people_outline,
                    title: 'No Users Found',
                    subtitle: 'Users will appear here once registered',
                  )
                : ListView.builder(
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      final user = _users[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.trustBlueLight,
                          child: Text(
                            user['name']?[0] ?? '?',
                            style: const TextStyle(color: AppColors.trustBlue),
                          ),
                        ),
                        title: Text(user['name'] ?? 'Unknown'),
                        subtitle: Text('${user['role']} - ${user['phone']}'),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {},
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'edit', child: Text('Edit')),
                            const PopupMenuItem(value: 'suspend', child: Text('Suspend')),
                            const PopupMenuItem(value: 'delete', child: Text('Delete')),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/enums/user_role.dart';
import '../../../providers/auth_provider.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    final roles = [
      _RoleOption(
        UserRole.user,
        Icons.person,
        'I need emergency help',
        AppColors.emergencyRed,
      ),
      _RoleOption(
        UserRole.driver,
        Icons.directions_car,
        'I want to transport patients',
        AppColors.trustBlue,
      ),
      _RoleOption(
        UserRole.hospital,
        Icons.local_hospital,
        'I represent a hospital',
        AppColors.successGreen,
      ),
      _RoleOption(
        UserRole.communitySupporter,
        Icons.people,
        'I want to support my community',
        AppColors.warningAmber,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Choose Your Role')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How will you use\nLifeline Mesh?',
                style: AppTextStyles.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Select your primary role to get started',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.separated(
                  itemCount: roles.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final role = roles[index];
                    return _RoleCard(
                      option: role,
                      onTap: () {
                        final user = authState.user;
                        if (user != null) {
                          final updated = user.copyWith(role: role.role);
                          if (user.fullName == null) {
                            context.push('/auth/profile', extra: updated);
                          } else {
                            ref.read(authProvider.notifier).setupProfile(updated);
                            _navigateToDashboard(context, role.role);
                          }
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDashboard(BuildContext context, UserRole role) {
    switch (role) {
      case UserRole.driver:
        context.go('/driver/dashboard');
      case UserRole.hospital:
        context.go('/hospital/dashboard');
      case UserRole.admin:
      case UserRole.moderator:
        context.go('/admin/dashboard');
      default:
        context.go('/user/dashboard');
    }
  }
}

class _RoleOption {
  final UserRole role;
  final IconData icon;
  final String description;
  final Color color;

  _RoleOption(this.role, this.icon, this.description, this.color);
}

class _RoleCard extends StatelessWidget {
  final _RoleOption option;
  final VoidCallback onTap;

  const _RoleCard({required this.option, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: option.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(option.icon, color: option.color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.role.displayName,
                      style: AppTextStyles.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      option.description,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
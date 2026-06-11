import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../models/user_model.dart';
import '../../../models/enums/user_role.dart';
import '../../../providers/auth_provider.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;

    final extra = GoRouterState.of(context).extra;
    final UserModel? existingUser = extra is UserModel ? extra : null;
    final authState = ref.read(authProvider);
    final baseUser = existingUser ?? authState.user;

    if (baseUser == null) return;

    final updated = baseUser.copyWith(
      fullName: _nameController.text.trim(),
    );

    ref.read(authProvider.notifier).setupProfile(updated);
    _navigateToDashboard(updated.role);
  }

  void _navigateToDashboard(UserRole role) {
    switch (role) {
      case UserRole.driver:
        context.go('/driver/dashboard');
      case UserRole.hospital:
        context.go('/hospital/dashboard');
      case UserRole.admin:
      case UserRole.moderator:
        context.go('/admin/dashboard');
      default:
        context.go('/patient/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Profile')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(flex: 2),
                Text(
                  'Tell us your name',
                  style: AppTextStyles.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'This helps others identify you in an emergency',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      // TODO: Image picker
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.trustBlueLight,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 36,
                        color: AppColors.trustBlue,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                AppTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                const SizedBox(height: 32),
                AppButton(
                  label: 'Save & Continue',
                  onPressed: _saveProfile,
                  type: ButtonType.primary,
                ),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
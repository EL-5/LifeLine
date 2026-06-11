import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _sendOtp() {
    if (!_formKey.currentState!.validate()) return;
    final phone = _phoneController.text.trim();
    ref.read(authProvider.notifier).sendOtp(phone);
    context.push('/auth/otp', extra: phone);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(flex: 2),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.emergencyRed,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.add_circle_outline, color: Colors.white, size: 36),
                ),
                const SizedBox(height: 24),
                Text(
                  'Welcome to\nLifeline Mesh',
                  style: AppTextStyles.displayMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your phone number to get started',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                AppTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  hint: '+233 XX XXX XXXX',
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
                const SizedBox(height: 24),
                if (authState.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      authState.error!,
                      style: const TextStyle(color: AppColors.emergencyRed, fontSize: 14),
                    ),
                  ),
                AppButton(
                  label: 'Send Verification Code',
                  onPressed: _sendOtp,
                  loading: authState.status == AuthStatus.loading,
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
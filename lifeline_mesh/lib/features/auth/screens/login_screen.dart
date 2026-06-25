import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';

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

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Close keyboard
    FocusScope.of(context).unfocus();

    final phone = _phoneController.text.trim();
    
    // Make sure we have the correct phone format (must include +)
    final formattedPhone = phone.startsWith('+') ? phone : '+$phone';

    try {
      await ref.read(authProvider.notifier).sendOtp(formattedPhone);
      
      if (mounted) {
        final authState = ref.read(authProvider);
        if (authState.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${authState.error}')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Success! Pushing to OTP screen...')),
          );
          context.go('/auth/otp', extra: formattedPhone);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Crash: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: math.max(0.0, MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom - 48),
              ),
              child: IntrinsicHeight(
                child: Form(
                  key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: Icon(
                          Theme.of(context).brightness == Brightness.light 
                              ? Icons.dark_mode 
                              : Icons.light_mode,
                        ),
                        onPressed: () {
                          ref.read(themeModeProvider.notifier).toggleTheme(context);
                        },
                      ),
                    ),
                    const Spacer(),
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
                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      'Developer Quick Login (Bypass SMS)',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => ref.read(authProvider.notifier).devQuickLogin('user4@test.com', 'user'),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.emergencyRed, foregroundColor: Colors.white),
                            child: const Text('User'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => ref.read(authProvider.notifier).devQuickLogin('driver4@test.com', 'driver'),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.trustBlue, foregroundColor: Colors.white),
                            child: const Text('Driver'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => ref.read(authProvider.notifier).devQuickLogin('hospital4@test.com', 'hospital'),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.successGreen, foregroundColor: Colors.white),
                            child: const Text('Hospital'),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
}
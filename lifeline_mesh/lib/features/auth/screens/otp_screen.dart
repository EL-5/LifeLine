import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../providers/auth_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otpControllers = List.generate(6, (_) => TextEditingController());
  final _otpFocusNodes = List.generate(6, (_) => FocusNode());

  String get _phone => (GoRouterState.of(context).extra as String?) ?? '';

  @override
  void dispose() {
    for (var c in _otpControllers) {
      c.dispose();
    }
    for (var f in _otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otpCode =>
      _otpControllers.map((c) => c.text).join();

  void _onOtpChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _otpFocusNodes[index + 1].requestFocus();
    }
    if (_otpCode.length == 6) {
      _verifyOtp();
    }
  }

  void _verifyOtp() {
    if (_otpCode.length != 6) return;
    ref.read(authProvider.notifier).verifyOtp(
      phone: _phone,
      token: _otpCode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.status == AuthStatus.authenticated) {
        final user = next.user;
        if (user != null && user.role.value == 'patient' && user.fullName == null) {
          context.push('/auth/profile');
        } else {
          _navigateToDashboard(user?.role.value ?? 'patient');
        }
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Verify Phone')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),
              Text(
                'Enter Verification Code',
                style: AppTextStyles.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Code sent to $_phone',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              Form(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 48,
                      height: 56,
                      child: TextField(
                        controller: _otpControllers[index],
                        focusNode: _otpFocusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.divider),
                          ),
                        ),
                        onChanged: (v) => _onOtpChanged(index, v),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 24),
              if (authState.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    authState.error!,
                    style: const TextStyle(color: AppColors.emergencyRed),
                  ),
                ),
              AppButton(
                label: 'Verify',
                onPressed: _verifyOtp,
                loading: authState.status == AuthStatus.loading,
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDashboard(String role) {
    switch (role) {
      case 'driver':
        context.go('/driver/dashboard');
      case 'hospital':
        context.go('/hospital/dashboard');
      case 'admin':
      case 'moderator':
        context.go('/admin/dashboard');
      default:
        context.go('/patient/dashboard');
    }
  }
}
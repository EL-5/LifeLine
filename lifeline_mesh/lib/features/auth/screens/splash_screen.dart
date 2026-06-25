import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/enums/user_role.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Wait for the build phase to complete before modifying providers
    await Future.delayed(Duration.zero);
    
    // Check auth status immediately
    await ref.read(authProvider.notifier).checkAuthStatus();
    
    // Wait for splash animation (min 2 seconds)
    await Future.delayed(const Duration(seconds: 2));
    
    const storage = FlutterSecureStorage();
    final hasSeenOnboarding = await storage.read(key: 'has_seen_onboarding');

    if (mounted) {
      if (true || hasSeenOnboarding != 'true') {
        context.go('/onboarding');
      } else {
        final authState = ref.read(authProvider);
        if (authState.status == AuthStatus.authenticated) {
          final role = authState.user?.role ?? UserRole.patient;
          // Determine dashboard route manually here
          String route = '/patient/dashboard';
          if (role == UserRole.driver) route = '/driver/dashboard';
          if (role == UserRole.hospital) route = '/hospital/dashboard';
          if (role == UserRole.admin || role == UserRole.moderator) route = '/admin/dashboard';
          context.go(route);
        } else {
          context.go('/auth/login');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.emergencyRed,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.add_circle_outline,
                size: 56,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppConstants.appName,
              style: AppTextStyles.displayLarge.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Emergency Coordination Network',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              color: AppColors.emergencyRed,
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../models/enums/user_role.dart';

// Screen imports
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/auth/screens/role_selection_screen.dart';
import '../../features/auth/screens/profile_setup_screen.dart';
import '../../features/emergency/screens/emergency_dashboard.dart';
import '../../features/emergency/screens/sos_trigger_screen.dart';
import '../../features/emergency/screens/symptom_selection_screen.dart';
import '../../features/emergency/screens/emergency_live_tracking_screen.dart';
import '../../features/emergency/screens/emergency_history_screen.dart';
import '../../features/family/screens/family_management_screen.dart';
import '../../features/community/screens/community_feed_screen.dart';
import '../../features/community/screens/campaign_detail_screen.dart';
import '../../features/driver/screens/driver_dashboard.dart';
import '../../features/driver/screens/incoming_request_screen.dart';
import '../../features/driver/screens/driver_navigation_screen.dart';
import '../../features/driver/screens/driver_earnings_screen.dart';
import '../../features/hospital/screens/hospital_dashboard.dart';
import '../../features/hospital/screens/emergency_detail_screen.dart';
import '../../features/payments/screens/wallet_screen.dart';
import '../../features/payments/screens/transaction_history_screen.dart';
import '../../features/admin/screens/admin_dashboard.dart';
import '../../features/admin/screens/analytics_screen.dart';
import '../../features/admin/screens/user_management_screen.dart';
import '../../features/admin/screens/fraud_monitoring_screen.dart';
import '../../features/admin/screens/audit_log_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoggedIn = authState.status == AuthStatus.authenticated;
      final isInitialOrLoading = authState.status == AuthStatus.initial || authState.status == AuthStatus.loading;
      final isOnAuthScreen = state.matchedLocation.startsWith('/auth') || state.matchedLocation == '/onboarding';
      final isOnSplash = state.matchedLocation == '/splash';

      if (isOnSplash) {
        if (isInitialOrLoading) return null;
        return isLoggedIn ? _getDefaultRouteForRole(authState.user?.role ?? UserRole.patient) : '/auth/login';
      }

      if (!isLoggedIn && !isOnAuthScreen) {
        return '/auth/login';
      }
      if (isLoggedIn && isOnAuthScreen) {
        final role = authState.user?.role ?? UserRole.patient;
        return _getDefaultRouteForRole(role);
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/otp',
        builder: (context, state) => const OtpScreen(),
      ),
      GoRoute(
        path: '/auth/role',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/auth/profile',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      // Patient routes
      GoRoute(
        path: '/patient/dashboard',
        builder: (context, state) => const EmergencyDashboard(),
      ),
      GoRoute(
        path: '/patient/sos',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SosTriggerScreen(),
      ),
      GoRoute(
        path: '/patient/sos/symptoms',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SymptomSelectionScreen(),
      ),
      GoRoute(
        path: '/patient/track/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => EmergencyLiveTrackingScreen(
          emergencyId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/patient/history',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const EmergencyHistoryScreen(),
      ),
      GoRoute(
        path: '/patient/family',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const FamilyManagementScreen(),
      ),
      // Community routes
      GoRoute(
        path: '/community',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CommunityFeedScreen(),
      ),
      GoRoute(
        path: '/community/campaign/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => CampaignDetailScreen(
          emergencyId: state.pathParameters['id']!,
        ),
      ),
      // Driver routes
      GoRoute(
        path: '/driver/dashboard',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const DriverDashboard(),
      ),
      GoRoute(
        path: '/driver/request/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => IncomingRequestScreen(
          emergencyId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/driver/navigate/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => DriverNavigationScreen(
          emergencyId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/driver/earnings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const DriverEarningsScreen(),
      ),
      // Hospital routes
      GoRoute(
        path: '/hospital/dashboard',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const HospitalDashboard(),
      ),
      GoRoute(
        path: '/hospital/emergency/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => EmergencyDetailScreen(
          emergencyId: state.pathParameters['id']!,
        ),
      ),
      // Payment routes
      GoRoute(
        path: '/wallet',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const WalletScreen(),
      ),
      GoRoute(
        path: '/wallet/transactions',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const TransactionHistoryScreen(),
      ),
      // Admin routes
      GoRoute(
        path: '/admin/dashboard',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AdminDashboard(),
      ),
      GoRoute(
        path: '/admin/analytics',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AnalyticsScreen(),
      ),
      GoRoute(
        path: '/admin/users',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const UserManagementScreen(),
      ),
      GoRoute(
        path: '/admin/fraud',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const FraudMonitoringScreen(),
      ),
      GoRoute(
        path: '/admin/audit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AuditLogScreen(),
      ),
    ],
  );

  ref.listen(authProvider, (previous, next) {
    router.refresh();
  });

  return router;
});

String _getDefaultRouteForRole(UserRole role) {
  switch (role) {
    case UserRole.patient:
    case UserRole.family:
    case UserRole.communitySupporter:
      return '/patient/dashboard';
    case UserRole.driver:
      return '/driver/dashboard';
    case UserRole.hospital:
      return '/hospital/dashboard';
    case UserRole.moderator:
    case UserRole.admin:
      return '/admin/dashboard';
  }
}
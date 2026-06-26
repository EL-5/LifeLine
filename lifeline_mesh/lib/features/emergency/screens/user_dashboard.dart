import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/emergency_badge.dart';
import '../../../providers/emergency_provider.dart';
import '../../../providers/auth_provider.dart';
import 'community_funding_view.dart';
import '../../payments/screens/wallet_screen.dart';
import '../../../providers/driver_provider.dart';
import '../../../providers/driver_provider.dart';
import '../../ai/screens/ai_triage_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

class UserDashboard extends ConsumerStatefulWidget {
  const UserDashboard({super.key});

  @override
  ConsumerState<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends ConsumerState<UserDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        actions: [
          if (_currentIndex == 0)
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () => context.push('/user/history'),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              context.go('/auth/login');
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: AppColors.trustBlue,
          unselectedItemColor: AppColors.textSecondary,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          backgroundColor: Colors.white,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.emergency),
              label: 'SOS',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.volunteer_activism),
              label: 'Community',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.smart_toy_outlined),
              label: 'AI Triage',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet),
              label: 'Wallet',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Lifeline Mesh';
      case 1:
        return 'Community Support';
      case 2:
        return 'AI Assistant';
      case 3:
        return 'Wallet';
      case 4:
        return 'Profile';
      default:
        return 'Lifeline';
    }
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return const _HomeTab();
      case 1:
        return const CommunityFundingView();
      case 2:
        return const AiTriageScreen();
      case 3:
        return const WalletScreen();
      case 4:
        return const _ProfileTab();
      default:
        return const SizedBox.shrink();
    }
  }
}

class _HomeTab extends ConsumerWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeEmergency = ref.watch(activeEmergencyProvider);
    final user = ref.watch(authProvider).user;
    final isDriver = user?.role.value == 'driver';

    return activeEmergency.when(
      data: (emergency) {
        if (emergency != null) {
          return _ActiveEmergencyView(emergency: emergency);
        }
        return _NoEmergencyView(isDriver: isDriver);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => _NoEmergencyView(isDriver: isDriver),
    );
  }
}

class _NoEmergencyView extends ConsumerWidget {
  final bool isDriver;

  const _NoEmergencyView({required this.isDriver});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasApplied = ref.watch(hasAppliedToDriveProvider);
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 32),
          Text(
            'Emergency Assistance',
            style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700),
          ).animate().fadeIn().slideY(begin: -0.2),
          const SizedBox(height: 8),
          const Text(
            'Tap the SOS button if you need immediate help',
            style: TextStyle(color: AppColors.textSecondary),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 48),
          _SOSButton(
            onPressed: () => context.push('/user/sos'),
          ).animate().scale(delay: 200.ms, duration: 400.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 64),
          
          // Apply to Drive Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.trustBlue, Color(0xFF1E88E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.trustBlue.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    if (isDriver) {
                      context.go('/driver/dashboard');
                    } else if (hasApplied) {
                      context.push('/user/apply_driver/pending');
                    } else {
                      context.push('/user/apply_driver');
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(hasApplied ? Icons.hourglass_top : Icons.drive_eta, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isDriver ? 'Switch to Driver Portal' : (hasApplied ? 'Application Pending' : 'Apply to be a Driver'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isDriver ? 'Go online and receive dispatch alerts.' : (hasApplied ? 'We are currently reviewing your application.' : 'Earn money by transporting patients.'),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _ProfileTab extends ConsumerWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isDriver = user?.role.value == 'driver';

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: AppColors.trustBlue.withValues(alpha: 0.1),
          child: const Icon(Icons.person, size: 50, color: AppColors.trustBlue),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            user?.fullName ?? 'User',
            style: AppTextStyles.titleLarge,
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            user?.role.displayName ?? 'User',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(height: 32),
        const Divider(),
        
        // Family & Emergency Contacts
        ListTile(
          leading: const Icon(Icons.family_restroom, color: AppColors.trustBlue),
          title: const Text('Family & Contacts', style: TextStyle(fontWeight: FontWeight.w600)),
          subtitle: const Text('Manage your emergency contacts', style: TextStyle(fontSize: 12)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => context.push('/user/family'),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.health_and_safety, color: AppColors.successGreen),
          title: const Text('AI Health Specialist', style: TextStyle(fontWeight: FontWeight.w600)),
          subtitle: const Text('Get your personalized preventative care plan', style: TextStyle(fontSize: 12)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => context.push('/user/health'),
        ),
        const Divider(),
        
        // Switch to Driver Portal (if driver)
        if (isDriver) ...[
          ListTile(
            leading: const Icon(Icons.drive_eta, color: AppColors.successGreen),
            title: const Text('Switch to Driver Portal', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('Go online and receive dispatch alerts', style: TextStyle(fontSize: 12)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => context.go('/driver/dashboard'),
          ),
          const Divider(),
        ],

        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.w500)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            context.push('/user/settings');
          },
        ),
        ListTile(
          leading: const Icon(Icons.help_outline),
          title: const Text('Help & Support', style: TextStyle(fontWeight: FontWeight.w500)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            context.push('/user/help');
          },
        ),
      ],
    );
  }
}

class _SOSButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _SOSButton({required this.onPressed});

  @override
  State<_SOSButton> createState() => _SOSButtonState();
}

class _SOSButtonState extends State<_SOSButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.emergencyRed,
                AppColors.emergencyRed.withValues(alpha: 0.8),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.emergencyRed.withValues(alpha: 0.5),
                blurRadius: 40,
                spreadRadius: 10,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 15,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Inner depth ring
              Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.warning_rounded, color: Colors.white, size: 48),
                  const SizedBox(height: 8),
                  Text(
                    'SOS',
                    style: AppTextStyles.sosButton.copyWith(
                      fontSize: 32,
                      shadows: [
                        const Shadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        )
                      ]
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'TAP FOR HELP',
                      style: TextStyle(
                        color: Colors.white, 
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveEmergencyView extends StatelessWidget {
  final dynamic emergency;

  const _ActiveEmergencyView({required this.emergency});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.emergencyRed.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.emergency, color: AppColors.emergencyRed),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Active Emergency',
                          style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      StatusBadge(status: emergency.status),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Divider(),
                  ),
                  _infoRow(Icons.category_outlined, 'Category', emergency.category),
                  _infoRow(
                    Icons.speed_outlined,
                    'Severity',
                    emergency.severity.displayName,
                  ),
                  _infoRow(
                    Icons.local_hospital_outlined,
                    'Hospital ID',
                    emergency.hospitalId ?? 'Assigning...',
                  ),
                  const SizedBox(height: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Funding Progress', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                          Text(
                            'GHS ${emergency.raisedAmount} / GHS ${emergency.targetAmount}',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: emergency.fundingProgress,
                          backgroundColor: AppColors.divider,
                          color: AppColors.successGreen,
                          minHeight: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ).animate().fadeIn().slideY(begin: 0.1),
          const SizedBox(height: 24),
          AppButton(
            label: 'Track Emergency Live',
            onPressed: () => context.push('/user/track/${emergency.id}'),
            icon: Icons.my_location,
          ).animate().fadeIn(delay: 200.ms),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(color: AppColors.textSecondary, fontSize: 15)),
          Expanded(
            child: Text(
              value, 
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

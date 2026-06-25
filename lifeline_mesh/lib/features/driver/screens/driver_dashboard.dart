import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../providers/driver_provider.dart';
import '../../../providers/auth_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DriverDashboard extends ConsumerStatefulWidget {
  const DriverDashboard({super.key});

  @override
  ConsumerState<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends ConsumerState<DriverDashboard> {
  bool _isAvailable = false;
  bool _isUpdatingAvailability = false;

  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }

  Future<void> _loadAvailability() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    final result = await Supabase.instance.client
        .from('drivers')
        .select('availability_status')
        .eq('user_id', userId)
        .maybeSingle();
    if (mounted && result != null) {
      setState(() => _isAvailable = result['availability_status'] as bool? ?? false);
    }
  }

  Future<void> _toggleAvailability(bool value) async {
    if (_isUpdatingAvailability) return;
    setState(() => _isUpdatingAvailability = true);
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;
      await Supabase.instance.client
          .from('drivers')
          .update({'availability_status': value}).eq('user_id', userId);
      setState(() => _isAvailable = value);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdatingAvailability = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableEmergencies = ref.watch(availableEmergenciesProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceDark,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        title: const Text('Dispatch Radar', style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1.2)),
        actions: [
          IconButton(
            icon: const Icon(Icons.monetization_on_rounded),
            onPressed: () => context.push('/driver/earnings'),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.surfaceDark, Color(0xFF0D1117)],
          ),
        ),
        child: Column(
          children: [
            // Availability Panel
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  boxShadow: [
                    if (_isAvailable)
                      BoxShadow(
                        color: AppColors.successGreen.withValues(alpha: 0.2),
                        blurRadius: 20,
                        spreadRadius: -5,
                      )
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isAvailable ? AppColors.successGreen : AppColors.textSecondary,
                        boxShadow: [
                          if (_isAvailable)
                            BoxShadow(color: AppColors.successGreen.withValues(alpha: 0.5), blurRadius: 8)
                        ],
                      ),
                    ).animate(target: _isAvailable ? 1 : 0).shimmer(duration: 2.seconds),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isAvailable ? 'System Online' : 'System Offline',
                            style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
                          ),
                          Text(
                            _isAvailable ? 'Scanning for emergencies...' : 'Go online to receive dispatch alerts',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    _isUpdatingAvailability
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.successGreen),
                          )
                        : Switch(
                            value: _isAvailable,
                            onChanged: _toggleAvailability,
                            activeColor: AppColors.successGreen,
                            activeTrackColor: AppColors.successGreen.withValues(alpha: 0.3),
                            inactiveThumbColor: AppColors.textSecondary,
                            inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
                          ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: availableEmergencies.when(
                data: (emergencies) {
                  if (emergencies.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.radar, size: 80, color: AppColors.textSecondary.withValues(alpha: 0.3))
                              .animate(onPlay: (controller) => controller.repeat())
                              .shimmer(duration: 3.seconds, color: Colors.white24),
                          const SizedBox(height: 24),
                          const Text(
                            'No Active Dispatch Alerts',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: emergencies.length,
                    itemBuilder: (context, index) {
                      final emergency = emergencies[index];
                      final address = emergency.location['address'] ?? 'Coordinates acquired';
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161B22),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: emergency.severity.color.withValues(alpha: 0.3)),
                          boxShadow: [
                            BoxShadow(
                              color: emergency.severity.color.withValues(alpha: 0.1),
                              blurRadius: 15,
                              spreadRadius: -2,
                            )
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => context.push('/driver/request/${emergency.id}'),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: emergency.severity.color.withValues(alpha: 0.15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.emergency_share, color: emergency.severity.color, size: 28)
                                            .animate(onPlay: (controller) => controller.repeat())
                                            .shimmer(duration: 2.seconds),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    emergency.category.replaceAll('_', ' ').toUpperCase(),
                                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 0.5),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: emergency.severity.color.withValues(alpha: 0.2),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    emergency.severity.displayName.toUpperCase(),
                                                    style: TextStyle(color: emergency.severity.color, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                const Icon(Icons.my_location_rounded, size: 14, color: AppColors.textSecondary),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    address,
                                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  LinearProgressIndicator(
                                    value: emergency.fundingProgress,
                                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                                    color: AppColors.successGreen,
                                    minHeight: 6,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('GHS ${emergency.raisedAmount} raised', style: const TextStyle(color: AppColors.successGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                                      Text('Goal: GHS ${emergency.targetAmount}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: AppButton(
                                      label: 'View Dispatch Details',
                                      onPressed: () => context.push('/driver/request/${emergency.id}'),
                                      type: ButtonType.emergency,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ).animate().fadeIn(duration: 400.ms, delay: (index * 100).ms).slideY(begin: 0.1, curve: Curves.easeOutQuad);
                    },
                  );
                },
                loading: () => Center(
                  child: const CircularProgressIndicator(color: AppColors.emergencyRed)
                      .animate()
                      .scale(duration: 200.ms),
                ),
                error: (e, _) => Center(
                  child: Text('Error loading dispatch feed: $e', style: const TextStyle(color: AppColors.emergencyRed)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
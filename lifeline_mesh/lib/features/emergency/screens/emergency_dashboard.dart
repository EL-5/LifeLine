import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/emergency_badge.dart';
import '../../../providers/emergency_provider.dart';

class EmergencyDashboard extends ConsumerWidget {
  const EmergencyDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeEmergency = ref.watch(activeEmergencyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lifeline Mesh'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.push('/patient/history'),
          ),
        ],
      ),
      body: activeEmergency.when(
        data: (emergency) {
          if (emergency != null) {
            return _ActiveEmergencyView(emergency: emergency);
          }
          return _NoEmergencyView();
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _NoEmergencyView(),
      ),
    );
  }
}

class _NoEmergencyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: EmptyState(
            icon: Icons.shield_outlined,
            title: 'No Active Emergency',
            subtitle: 'Tap the SOS button when you need emergency assistance',
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: _SOSButton(
            onPressed: () => context.push('/patient/sos'),
          ),
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
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
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
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.emergencyRed,
            boxShadow: [
              BoxShadow(
                color: AppColors.emergencyRed.withValues(alpha: 0.4),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning, color: Colors.white, size: 40),
              const SizedBox(height: 4),
              Text(
                'SOS',
                style: AppTextStyles.sosButton,
              ),
              const Text(
                'Tap for help',
                style: TextStyle(color: Colors.white70, fontSize: 12),
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
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.emergency, color: AppColors.emergencyRed),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Active Emergency',
                          style: AppTextStyles.titleLarge,
                        ),
                      ),
                      StatusBadge(status: emergency.status),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _infoRow(Icons.category, 'Category', emergency.category),
                  _infoRow(
                    Icons.speed,
                    'Severity',
                    emergency.severity.displayName,
                  ),
                  _infoRow(
                    Icons.local_hospital,
                    'Hospital',
                    emergency.hospitalId ?? 'Assigning...',
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: emergency.fundingProgress,
                    backgroundColor: AppColors.divider,
                    color: AppColors.successGreen,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Funding: GHS ${emergency.raisedAmount} / GHS ${emergency.targetAmount}',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Track Emergency',
            onPressed: () => context.push('/patient/track/${emergency.id}'),
            icon: Icons.track_changes,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
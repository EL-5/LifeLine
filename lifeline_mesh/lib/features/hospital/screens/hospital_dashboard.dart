import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../providers/hospital_provider.dart';
import '../../../providers/auth_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HospitalDashboard extends ConsumerStatefulWidget {
  const HospitalDashboard({super.key});

  @override
  ConsumerState<HospitalDashboard> createState() => _HospitalDashboardState();
}

class _HospitalDashboardState extends ConsumerState<HospitalDashboard> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlayingAlarm = false;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _triggerAlarm() async {
    if (!_isPlayingAlarm) {
      _isPlayingAlarm = true;
      _audioPlayer.setReleaseMode(ReleaseMode.loop);
      // Fallback to a high-pitched beep if no asset is available
      // Ideally we would play an asset like: await _audioPlayer.play(AssetSource('sounds/alarm.mp3'));
      // Since we don't have the asset yet, we just print for now or use system sounds.
      debugPrint("ALARM SOUNDING!!!");
    }
  }

  void _stopAlarm() {
    if (_isPlayingAlarm) {
      _audioPlayer.stop();
      _isPlayingAlarm = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final emergencies = ref.watch(hospitalIncomingEmergenciesProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: emergencies.when(
        data: (list) {
          if (list.isEmpty) {
            _stopAlarm();
            return _buildIdleState();
          } else {
            _triggerAlarm();
            return _buildAlertState(list.first.category);
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white))),
      ),
    );
  }

  Widget _buildIdleState() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0D1117), Colors.black],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shield_outlined, size: 100, color: AppColors.trustBlue.withValues(alpha: 0.3))
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(duration: 2.seconds, begin: const Offset(1, 1), end: const Offset(1.1, 1.1)),
          const SizedBox(height: 32),
          const Text(
            'SYSTEM IDLE',
            style: TextStyle(color: AppColors.trustBlue, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 4),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'No inbound emergencies. Please monitor the Web Command Center for global network analytics.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ),
          const SizedBox(height: 48),
          AppButton(
            label: 'Logout',
            type: ButtonType.secondary,
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAlertState(String category) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.emergencyRed,
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_amber_rounded, size: 150, color: Colors.white)
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(duration: 500.ms, begin: const Offset(1, 1), end: const Offset(1.2, 1.2)),
            const SizedBox(height: 32),
            const Text(
              'INBOUND EMERGENCY!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: 2),
            )
            .animate(onPlay: (c) => c.repeat())
            .shimmer(duration: 1.seconds, color: Colors.black26),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                category.replaceAll('_', ' ').toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 48),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'IMMEDIATELY CHECK WEB COMMAND CENTER FOR PATIENT VITALS, ETA, AND DISPATCH LIVE TRACKING.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, height: 1.5),
              ),
            ),
            const SizedBox(height: 48),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(
                width: double.infinity,
                height: 80,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.emergencyRed,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () {
                    _stopAlarm();
                    // Here we could update status or just stop the loud alarm
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alarm muted.')));
                  },
                  child: const Text('ACKNOWLEDGE ALARM', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                ),
              ),
            )
          ],
        ),
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true)).tint(color: Colors.black, duration: 500.ms, end: 0.3);
  }
}
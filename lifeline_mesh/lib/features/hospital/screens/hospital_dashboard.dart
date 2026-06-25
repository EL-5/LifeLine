import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../core/theme/colors.dart';
import '../../../providers/hospital_provider.dart';
import '../../../providers/auth_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';

class HospitalDashboard extends ConsumerStatefulWidget {
  const HospitalDashboard({super.key});

  @override
  ConsumerState<HospitalDashboard> createState() => _HospitalDashboardState();
}

class _HospitalDashboardState extends ConsumerState<HospitalDashboard> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlayingAlarm = false;
  bool _isMuted = false;
  late Timer _clockTimer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _triggerAlarm() async {
    if (!_isPlayingAlarm && !_isMuted) {
      _isPlayingAlarm = true;
      _audioPlayer.setReleaseMode(ReleaseMode.loop);
      // Play the strong siren sound via public URL to avoid any web codec or missing asset blocks
      await _audioPlayer.play(UrlSource('https://actions.google.com/sounds/v1/alarms/bugle_tune.ogg'));
      debugPrint("ALARM SOUNDING!!!");
    }
  }

  void _stopAlarm() {
    if (_isPlayingAlarm) {
      _audioPlayer.stop();
      _isPlayingAlarm = false;
    }
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      if (_isMuted) {
        _stopAlarm();
      } else {
        _triggerAlarm();
      }
    });
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final emergencies = ref.watch(hospitalIncomingEmergenciesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Slate 900
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B), // Slate 800
        title: Row(
          children: [
            const Icon(Icons.medical_services, color: AppColors.trustBlue),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'EMERGENCY DEPT.',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.0, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.trustBlue.withValues(alpha: 0.3)),
              ),
              child: Text(
                _formatTime(_currentTime),
                style: const TextStyle(color: AppColors.trustBlue, fontFamily: 'monospace', fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70),
            tooltip: 'Sign Out',
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              context.go('/auth/login');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: emergencies.when(
        data: (list) {
          if (list.isEmpty) {
            _stopAlarm();
            if (_isMuted) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() => _isMuted = false);
              });
            }
            return _buildIdleState();
          } else {
            _triggerAlarm();
            return _buildAlertState(list);
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AppColors.emergencyRed))),
      ),
    );
  }

  Widget _buildIdleState() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildStatCard('SYSTEM STATUS', 'ONLINE', Icons.check_circle, AppColors.successGreen),
              const SizedBox(width: 16),
              _buildStatCard('INBOUND', '0', Icons.airport_shuttle, AppColors.textSecondary),
              const SizedBox(width: 16),
              _buildStatCard('BED AVAILABILITY', '92%', Icons.bed, AppColors.trustBlue),
            ],
          ),
          const Spacer(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 250,
                      height: 250,
                      child: CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.trustBlue.withValues(alpha: 0.1)),
                      ),
                    ),
                    Icon(Icons.radar, size: 100, color: AppColors.trustBlue.withValues(alpha: 0.2))
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(duration: 2.seconds, begin: const Offset(1, 1), end: const Offset(1.2, 1.2)),
                  ],
                ),
                const SizedBox(height: 48),
                const Text(
                  'MONITORING MESH NETWORK',
                  style: TextStyle(color: AppColors.trustBlue, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: 4),
                ).animate(onPlay: (c) => c.repeat(reverse: true)).fade(duration: 1.seconds, begin: 0.3, end: 1.0),
                const SizedBox(height: 16),
                const Text(
                  'No active emergencies assigned to this facility.\nWeb Command Center is recording global telemetry.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertState(List<dynamic> emergencies) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF450A0A), // Dark red
        border: Border.all(color: AppColors.emergencyRed, width: 4),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(color: AppColors.emergencyRed, borderRadius: BorderRadius.circular(8)),
                child: Text('CODE RED (${emergencies.length} ACTIVE)', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 4)),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeOut(duration: 300.ms),
              const SizedBox(height: 32),
              const Icon(Icons.warning_amber_rounded, size: 80, color: AppColors.emergencyRed)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(duration: 500.ms, begin: const Offset(1, 1), end: const Offset(1.1, 1.1)),
              const SizedBox(height: 24),
              const Text(
                'INBOUND CRITICAL\nPATIENTS',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 2, height: 1.2),
              ),
              const SizedBox(height: 24),
              
              // List of active emergencies
              ...emergencies.map((e) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    border: Border.all(color: AppColors.emergencyRed.withValues(alpha: 0.5)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        e.category.toString().replaceAll('_', ' ').toUpperCase(),
                        style: const TextStyle(color: AppColors.emergencyRed, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Severity: ${e.severity.displayName}',
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              )),
              
              const SizedBox(height: 32),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Switch to Web Command Center immediately for telemetry, live ETA tracking, and responder communications.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: 250,
                height: 54,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isMuted ? Colors.white : AppColors.emergencyRed,
                    foregroundColor: _isMuted ? AppColors.emergencyRed : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _toggleMute,
                  icon: Icon(_isMuted ? Icons.volume_up : Icons.volume_off),
                  label: Text(_isMuted ? 'UNMUTE ALARM' : 'MUTE ALARM', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true)).tint(color: AppColors.emergencyRed, duration: 800.ms, end: 0.1);
  }
}
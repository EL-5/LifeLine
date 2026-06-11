import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/location_service.dart';

class SosTriggerScreen extends ConsumerStatefulWidget {
  const SosTriggerScreen({super.key});

  @override
  ConsumerState<SosTriggerScreen> createState() => _SosTriggerScreenState();
}

class _SosTriggerScreenState extends ConsumerState<SosTriggerScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _holdController;
  bool _isHolding = false;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _holdController = AnimationController(
      vsync: this,
      duration: Duration(seconds: AppConstants.sosHoldDurationSeconds),
    );
    _initLocation();
  }

  Future<void> _initLocation() async {
    final locationService = ref.read(locationServiceProvider);
    try {
      _currentPosition = await locationService.getCurrentLocation();
    } catch (_) {}
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _holdController.dispose();
    super.dispose();
  }

  void _startHold() {
    setState(() => _isHolding = true);
    _holdController.forward().then((_) {
      if (mounted) {
        context.push('/patient/sos/symptoms', extra: {
          'location': _currentPosition != null
              ? {
                  'lat': _currentPosition!.latitude,
                  'lng': _currentPosition!.longitude,
                }
              : null,
        });
      }
    });
  }

  void _cancelHold() {
    _holdController.reset();
    setState(() => _isHolding = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              elevation: 0,
              title: const Text('Emergency SOS'),
            ),
            const Spacer(),
            Text(
              'Hold the button for ${AppConstants.sosHoldDurationSeconds} seconds',
              style: AppTextStyles.bodyLarge.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onLongPressStart: (_) => _startHold(),
              onLongPressEnd: (_) => _cancelHold(),
              onLongPressCancel: _cancelHold,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: AppConstants.sosButtonSize,
                      height: AppConstants.sosButtonSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isHolding
                            ? AppColors.emergencyRed
                            : AppColors.emergencyRed.withValues(alpha: 0.8),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.emergencyRed.withValues(alpha: 0.5),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'SOS',
                            style: AppTextStyles.emergencyNumber,
                          ),
                          const SizedBox(height: 8),
                          if (_isHolding)
                            SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(
                                value: _holdController.value,
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          else
                            const Text(
                              'HOLD HERE',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                letterSpacing: 2,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Your location will be shared automatically.\nOnly use in a real emergency.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(color: Colors.white38),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
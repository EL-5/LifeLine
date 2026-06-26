import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/emergency_badge.dart';
import '../../../providers/emergency_provider.dart';
import '../../../models/enums/emergency_status.dart';
import '../../../models/emergency_model.dart';
import '../../../core/services/ai_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EmergencyLiveTrackingScreen extends ConsumerWidget {
  final String emergencyId;

  const EmergencyLiveTrackingScreen({
    super.key,
    required this.emergencyId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emergencyAsync = ref.watch(emergencyDetailProvider(emergencyId));

    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Tracking')),
      body: emergencyAsync.when(
        data: (emergency) {
          if (emergency == null) {
            return const Center(child: Text('Emergency not found'));
          }
          return _TrackingContent(emergency: emergency);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _TrackingContent extends ConsumerStatefulWidget {
  final EmergencyModel emergency;

  const _TrackingContent({required this.emergency});

  @override
  ConsumerState<_TrackingContent> createState() => _TrackingContentState();
}

class _TrackingContentState extends ConsumerState<_TrackingContent> {
  bool _voiceEnabled = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakInstructions();
    });
  }

  @override
  void didUpdateWidget(covariant _TrackingContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.emergency.status != widget.emergency.status) {
      _speakInstructions();
    }
  }

  Future<void> _speakInstructions() async {
    final aiService = ref.read(aiServiceProvider);
    if (!_voiceEnabled) {
      await aiService.stop();
      return;
    }
    
    String message = "Emergency alert active. Help is on the way. Please stay calm.";
    
    if (widget.emergency.status == EmergencyStatus.dispatched) {
      message = "An ambulance has been dispatched and is en route to your location. Please ensure the path is clear.";
    } else if (widget.emergency.status == EmergencyStatus.driverArrived) {
      message = "The ambulance has arrived. Please step outside.";
    }

    if (widget.emergency.status == EmergencyStatus.pending) {
      if (widget.emergency.category == 'chest_pain') {
        message += " Please sit down, rest, and loosen any tight clothing.";
      } else if (widget.emergency.category == 'breathing_difficulty') {
        message += " Sit upright and try to take slow, deep breaths.";
      } else if (widget.emergency.category == 'accident' || widget.emergency.category == 'violence_injury') {
        message += " Do not move if you suspect a neck or back injury. Apply pressure to any bleeding.";
      } else if (widget.emergency.category == 'stroke') {
        message += " Keep the person safe and at rest. Note the time the symptoms started.";
      }
    }

    await aiService.speak(message);
  }

  @override
  void dispose() {
    ref.read(aiServiceProvider).stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final driverLocationAsync = widget.emergency.driverId != null
        ? ref.watch(driverLocationStreamProvider(widget.emergency.driverId!))
        : const AsyncValue.data(null);

    final emergencyLocation = LatLng(
      widget.emergency.location['lat'] as double,
      widget.emergency.location['lng'] as double,
    );

    LatLng? driverLocation;
    driverLocationAsync.whenData((loc) {
      if (loc != null && loc['location'] != null) {
        driverLocation = LatLng(
          loc['location']['lat'] as double,
          loc['location']['lng'] as double,
        );
      }
    });

    final markers = {
      Marker(
        markerId: const MarkerId('emergency_location'),
        position: emergencyLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'Emergency Location'),
      ),
      if (driverLocation != null)
        Marker(
          markerId: const MarkerId('driver_location'),
          position: driverLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Ambulance Driver'),
        ),
    };
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Timeline
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.timeline, color: AppColors.trustBlue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Status Timeline',
                          style: AppTextStyles.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _voiceEnabled ? Icons.volume_up : Icons.volume_off,
                          color: _voiceEnabled ? AppColors.trustBlue : AppColors.textSecondary,
                        ),
                        onPressed: () {
                          setState(() => _voiceEnabled = !_voiceEnabled);
                          if (!_voiceEnabled) ref.read(aiServiceProvider).stop();
                          else _speakInstructions();
                        },
                      ),
                      StatusBadge(status: widget.emergency.status),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _StatusStep(
                    icon: Icons.warning,
                    label: 'Emergency Reported',
                    isComplete: true,
                    isActive: true,
                  ),
                  _StatusStep(
                    icon: Icons.directions_car,
                    label: 'Driver Dispatched',
                    isComplete: widget.emergency.status.index >= EmergencyStatus.dispatched.index,
                    isActive: widget.emergency.status == EmergencyStatus.dispatched,
                  ),
                  _StatusStep(
                    icon: Icons.person_pin,
                    label: 'Driver Arrived',
                    isComplete: widget.emergency.status.index >= EmergencyStatus.driverArrived.index,
                    isActive: widget.emergency.status == EmergencyStatus.driverArrived,
                  ),
                  _StatusStep(
                    icon: Icons.local_hospital,
                    label: 'Arrived at Hospital',
                    isComplete: widget.emergency.status.index >= EmergencyStatus.arrivedHospital.index,
                    isActive: widget.emergency.status == EmergencyStatus.arrivedHospital,
                  ),
                  _StatusStep(
                    icon: Icons.check_circle,
                    label: 'In Treatment',
                    isComplete: widget.emergency.status.index >= EmergencyStatus.inTreatment.index,
                    isActive: widget.emergency.status == EmergencyStatus.inTreatment,
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
          const SizedBox(height: 16),

          // Live Google Map
          Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SizedBox(
              height: 250,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: driverLocation ?? emergencyLocation,
                  zoom: 15,
                ),
                markers: markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
              ),
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 100.ms).scale(begin: const Offset(0.95, 0.95)),
          const SizedBox(height: 16),

          // Emergency Details
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Emergency Details', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 12),
                  _detailRow('Category', widget.emergency.category),
                  _detailRow('Severity', widget.emergency.severity.displayName),
                  _detailRow('Emergency ID', widget.emergency.id.substring(0, 8)),
                  _detailRow('Status', widget.emergency.status.value),
                  if (widget.emergency.targetAmount > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Funding: GHS ${widget.emergency.raisedAmount} / GHS ${widget.emergency.targetAmount}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: widget.emergency.fundingProgress,
                      backgroundColor: AppColors.divider,
                      color: AppColors.successGreen,
                    ),
                  ],
                  if (widget.emergency.driverId != null) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.trustBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.call),
                        label: const Text('Call Ambulance Driver', style: TextStyle(fontWeight: FontWeight.w600)),
                        onPressed: () async {
                          final uri = Uri.parse('tel:+233241234567');
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          }
                        },
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.1),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(color: AppColors.textSecondary)),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class _StatusStep extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isComplete;
  final bool isActive;

  const _StatusStep({
    required this.icon,
    required this.label,
    required this.isComplete,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final color = isComplete
        ? AppColors.successGreen
        : isActive
            ? AppColors.statusActive
            : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isComplete ? Icons.check : icon,
              size: 16,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isComplete || isActive ? Colors.black : AppColors.textSecondary,
            ),
          ),
          if (isActive)
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
    );
  }
}
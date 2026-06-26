import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../providers/emergency_provider.dart';
import '../../../models/enums/emergency_status.dart';

class DriverNavigationScreen extends ConsumerStatefulWidget {
  final String emergencyId;

  const DriverNavigationScreen({super.key, required this.emergencyId});

  @override
  ConsumerState<DriverNavigationScreen> createState() => _DriverNavigationScreenState();
}

class _DriverNavigationScreenState extends ConsumerState<DriverNavigationScreen> {
  bool _isUpdating = false;
  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _startLocationTracking();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _startLocationTracking() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    
    if (permission == LocationPermission.deniedForever) return;

    // Stream location every 5 seconds
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // minimum change (in meters) to trigger update
        timeLimit: Duration(seconds: 5), // but also fire updates at least this often if requested
      ),
    ).listen((Position position) {
      _updateDriverLocationInDb(position.latitude, position.longitude);
    });
  }

  Future<void> _updateDriverLocationInDb(double lat, double lng) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    
    try {
      await Supabase.instance.client
          .from('drivers')
          .update({
            'current_location': {'lat': lat, 'lng': lng}
          })
          .eq('user_id', user.id);
    } catch (_) {
      // Ignore background errors for location updates
    }
  }

  Future<void> _updateStatus(String newStatusStr) async {
    setState(() => _isUpdating = true);
    try {
      await Supabase.instance.client
          .from('emergencies')
          .update({'status': newStatusStr})
          .eq('id', widget.emergencyId);
      
      if (mounted) {
        if (newStatusStr == 'completed') {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Emergency Mission Completed!')));
           context.go('/driver/dashboard');
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: $e')));
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _launchDirections(double lat, double lng) async {
    final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch maps.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final emergencyAsync = ref.watch(emergencyDetailProvider(widget.emergencyId));

    return Scaffold(
      appBar: AppBar(title: const Text('Live Navigation')),
      body: emergencyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (emergency) {
          if (emergency == null) return const Center(child: Text('Emergency not found'));

          final emergencyLocation = LatLng(
            emergency.location['lat'] as double,
            emergency.location['lng'] as double,
          );

          return Column(
            children: [
              // Live Google Map
              Expanded(
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: emergencyLocation,
                    zoom: 15,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('emergency'),
                      position: emergencyLocation,
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                      infoWindow: const InfoWindow(title: 'Target Location'),
                    )
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),
              ),
              // Bottom controls
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: AppColors.emergencyRed),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Target Destination', style: TextStyle(fontWeight: FontWeight.w600)),
                                Text(emergency.location['address'] ?? 'Emergency Site', style: const TextStyle(color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          Text(
                            emergency.status.name.toUpperCase(),
                            style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.trustBlue, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_isUpdating)
                        const Center(child: CircularProgressIndicator())
                      else
                        _buildActionButtons(emergency.status, emergencyLocation),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(EmergencyStatus status, LatLng location) {
    if (status == EmergencyStatus.completed) {
      return AppButton(
        label: 'Mission Completed. Return to Dashboard',
        onPressed: () => context.go('/driver/dashboard'),
        type: ButtonType.primary,
      );
    }

    if (status == EmergencyStatus.enRouteHospital || status == EmergencyStatus.arrivedHospital) {
      return Row(
        children: [
          Expanded(
            child: AppButton(
              label: 'Directions',
              icon: Icons.directions,
              onPressed: () => _launchDirections(location.latitude, location.longitude),
              type: ButtonType.secondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppButton(
              label: status == EmergencyStatus.arrivedHospital ? 'Complete Mission' : 'Confirm Dropoff',
              onPressed: () => _updateStatus(status == EmergencyStatus.arrivedHospital ? 'completed' : 'arrived_hospital'),
              type: ButtonType.success,
            ),
          ),
        ],
      );
    }

    // Default: Driver is assigned or arrived at patient
    return Row(
      children: [
        Expanded(
          child: AppButton(
            label: 'Directions',
            icon: Icons.directions,
            onPressed: () => _launchDirections(location.latitude, location.longitude),
            type: ButtonType.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AppButton(
            label: status == EmergencyStatus.driverArrived ? 'Confirm Pickup' : 'Mark Arrived',
            onPressed: () => _updateStatus(status == EmergencyStatus.driverArrived ? 'en_route_hospital' : 'driver_arrived'),
            type: ButtonType.primary,
          ),
        ),
      ],
    );
  }
}
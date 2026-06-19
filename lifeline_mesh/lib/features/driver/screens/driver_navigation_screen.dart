import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../providers/emergency_provider.dart';

class DriverNavigationScreen extends ConsumerWidget {
  final String emergencyId;

  const DriverNavigationScreen({super.key, required this.emergencyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emergencyAsync = ref.watch(emergencyDetailProvider(emergencyId));

    return Scaffold(
      appBar: AppBar(title: const Text('Navigation')),
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
                      infoWindow: const InfoWindow(title: 'Patient Location'),
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
                          const Text('Patient Location', style: TextStyle(fontWeight: FontWeight.w600)),
                          Text(emergency.location['address'] ?? 'Emergency Site', style: const TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    const Text('Navigating...', style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Mark as Arrived',
                        onPressed: () => context.pop(),
                        type: ButtonType.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Confirm Pickup',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Patient picked up')),
                          );
                        },
                        type: ButtonType.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        label: 'Confirm Dropoff',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Patient delivered to hospital')),
                          );
                        },
                        type: ButtonType.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
            ],
          );
        },
      ),
    );
  }
}
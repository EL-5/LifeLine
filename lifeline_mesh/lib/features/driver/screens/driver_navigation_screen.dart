import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/app_button.dart';

class DriverNavigationScreen extends StatelessWidget {
  final String emergencyId;

  const DriverNavigationScreen({super.key, required this.emergencyId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Navigation')),
      body: Column(
        children: [
          // Map placeholder
          Expanded(
            child: Container(
              color: AppColors.calmBackground,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map, size: 64, color: AppColors.textSecondary),
                    SizedBox(height: 8),
                    Text('Navigation Map',
                        style: TextStyle(color: AppColors.textSecondary)),
                    Text('Google Maps / OSM integration',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
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
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Patient Location', style: TextStyle(fontWeight: FontWeight.w600)),
                          Text('Accra Central', style: TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    const Text('2.3 km', style: TextStyle(fontWeight: FontWeight.w600)),
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
      ),
    );
  }
}
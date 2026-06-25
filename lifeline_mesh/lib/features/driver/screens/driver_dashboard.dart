import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/app_button.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final Completer<GoogleMapController> _mapController = Completer();
  LatLng? _currentPosition;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _loadAvailability();
    _determinePosition();
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

  Future<void> _toggleAvailability() async {
    if (_isUpdatingAvailability) return;
    setState(() => _isUpdatingAvailability = true);
    try {
      final newValue = !_isAvailable;
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;
      await Supabase.instance.client
          .from('drivers')
          .update({'availability_status': newValue}).eq('user_id', userId);
      setState(() => _isAvailable = newValue);
      
      if (newValue) {
        _animateMapToCurrentPosition();
      }
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

  Future<void> _determinePosition() async {
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

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high)
    );
    
    if (mounted) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
      _animateMapToCurrentPosition();
    }
  }

  Future<void> _animateMapToCurrentPosition() async {
    if (_currentPosition == null) return;
    final controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: _currentPosition!, zoom: 15.0),
    ));
  }

  void _updateMarkers(List<dynamic> emergencies) {
    if (!_isAvailable) {
      setState(() => _markers = {});
      return;
    }

    final newMarkers = <Marker>{};
    for (var em in emergencies) {
      if (em.location != null && em.location['lat'] != null && em.location['lng'] != null) {
        newMarkers.add(
          Marker(
            markerId: MarkerId(em.id),
            position: LatLng(em.location['lat'], em.location['lng']),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: InfoWindow(title: 'Emergency: ${em.category}', snippet: em.severity.displayName),
          ),
        );
      }
    }
    
    if (_currentPosition != null) {
       newMarkers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: _currentPosition!,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            infoWindow: const InfoWindow(title: 'My Location'),
          ),
        );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _markers = newMarkers;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final availableEmergencies = ref.watch(availableEmergenciesProvider);
    
    availableEmergencies.whenData((emergencies) {
       _updateMarkers(emergencies);
    });

    return Scaffold(
      key: _scaffoldKey,
      drawer: const _DriverDrawer(),
      body: Stack(
        children: [
          // 1. Full Screen Map
          if (_currentPosition != null)
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPosition!,
                zoom: 14.0,
              ),
              onMapCreated: (controller) => _mapController.complete(controller),
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              compassEnabled: false,
              mapType: MapType.normal,
            )
          else
            const Center(child: CircularProgressIndicator(color: AppColors.trustBlue)),
            
          // Gray overlay when offline
          if (!_isAvailable)
            Container(
              color: Colors.white.withValues(alpha: 0.6),
            ),

          // 2. Top UI Controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Menu Button
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.menu, color: Colors.black87),
                      onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Floating SOS Safety Shield
          Positioned(
            right: 16,
            bottom: 250, // Above the bottom sheet
            child: FloatingActionButton(
              heroTag: 'sos',
              backgroundColor: Colors.white,
              onPressed: () => context.push('/user/sos'),
              child: const Icon(Icons.security, color: AppColors.trustBlue, size: 28),
            ),
          ),
          
          Positioned(
            right: 16,
            bottom: 320,
            child: FloatingActionButton(
              heroTag: 'recenter',
              backgroundColor: Colors.white,
              onPressed: _animateMapToCurrentPosition,
              child: const Icon(Icons.my_location, color: Colors.black87),
            ),
          ),

          // 4. Draggable Bottom Sheet / Panel
          DraggableScrollableSheet(
            initialChildSize: _isAvailable ? 0.4 : 0.25,
            minChildSize: 0.25,
            maxChildSize: 0.7,
            snap: true,
            snapSizes: const [0.25, 0.4, 0.7],
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, -5))
                  ],
                ),
                child: Column(
                  children: [
                    // Handle Bar
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 8),
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    
                    // Offline State UI
                    if (!_isAvailable)
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'You\'re Offline',
                              style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 8),
                            const Text('Go online to receive emergency requests.', style: TextStyle(color: AppColors.textSecondary)),
                            const Spacer(),
                            // Giant GO Button
                            GestureDetector(
                              onTap: _toggleAvailability,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.trustBlue,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.trustBlue.withValues(alpha: 0.4),
                                      blurRadius: 20,
                                      offset: const Offset(0, 5),
                                    )
                                  ],
                                ),
                                child: _isUpdatingAvailability
                                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                                    : const Center(
                                        child: Text(
                                          'GO',
                                          style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                      )
                    // Online State UI (Emergency Feed)
                    else
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                              child: AppButton(
                                label: 'Go Offline',
                                onPressed: _toggleAvailability,
                                type: ButtonType.secondary,
                              ),
                            ),
                            const Divider(),
                            Expanded(
                              child: availableEmergencies.when(
                                data: (emergencies) {
                                  if (emergencies.isEmpty) {
                                    return const Center(
                                      child: Text('Finding emergencies near you...', style: TextStyle(color: AppColors.textSecondary)),
                                    );
                                  }
                                  return ListView.separated(
                                    controller: scrollController,
                                    padding: const EdgeInsets.all(16),
                                    itemCount: emergencies.length,
                                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                                    itemBuilder: (context, index) {
                                      final emergency = emergencies[index];
                                      return Card(
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          side: BorderSide(color: Colors.grey.shade200),
                                        ),
                                        color: Colors.grey.shade50,
                                        margin: EdgeInsets.zero,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(16),
                                          onTap: () => context.push('/driver/request/${emergency.id}'),
                                          child: ListTile(
                                          contentPadding: const EdgeInsets.all(16),
                                          leading: CircleAvatar(
                                            backgroundColor: emergency.severity.color.withValues(alpha: 0.1),
                                            child: Icon(Icons.local_hospital, color: emergency.severity.color),
                                          ),
                                          title: Text(emergency.category, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                                          subtitle: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 4),
                                              Text('${emergency.severity.displayName} Emergency', style: const TextStyle(color: Colors.black54)),
                                              const SizedBox(height: 8),
                                              LinearProgressIndicator(
                                                value: emergency.fundingProgress,
                                                backgroundColor: Colors.grey.shade300,
                                                color: AppColors.successGreen,
                                              ),
                                            ],
                                          ),
                                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                loading: () => const Center(child: CircularProgressIndicator()),
                                error: (e, _) => Center(child: Text('Error: $e')),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DriverDrawer extends ConsumerWidget {
  const _DriverDrawer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    
    return Drawer(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Premium Header
          Container(
            padding: const EdgeInsets.only(top: 60, bottom: 24, left: 24, right: 24),
            decoration: const BoxDecoration(
              color: AppColors.surfaceDark,
              image: DecorationImage(
                image: NetworkImage('https://www.transparenttextures.com/patterns/cubes.png'),
                opacity: 0.05,
                repeat: ImageRepeat.repeat,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                  ),
                  child: const CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.trustBlue,
                    child: Icon(Icons.person, size: 36, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.fullName ?? 'Driver',
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '5.0',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),

          // Menu Items
          _buildMenuItem(
            icon: Icons.person_outline,
            title: 'Switch to User Portal',
            onTap: () {
              Navigator.pop(context);
              context.go('/user/dashboard');
            },
          ),
          _buildMenuItem(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Earnings & Wallet',
            onTap: () {
              Navigator.pop(context);
              context.push('/driver/earnings');
            },
          ),
          _buildMenuItem(
            icon: Icons.history,
            title: 'Trip History',
            onTap: () {
              Navigator.pop(context);
            },
          ),
          _buildMenuItem(
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: () {
              Navigator.pop(context);
            },
          ),

          const Spacer(),
          
          // App Version info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Text(
              'Lifeline Mesh v1.0.0',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ),

          // Logout Button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.pop(context);
                ref.read(authProvider.notifier).logout();
                context.go('/login');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.emergencyRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.logout, color: AppColors.emergencyRed, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Logout',
                      style: TextStyle(color: AppColors.emergencyRed, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Icon(icon, color: Colors.black87, size: 26),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../providers/driver_provider.dart';
import '../../../providers/emergency_provider.dart';
import '../../../models/emergency_model.dart';
import '../../../core/services/moolre_api_service.dart';

class IncomingRequestScreen extends ConsumerStatefulWidget {
  final String emergencyId;

  const IncomingRequestScreen({super.key, required this.emergencyId});

  @override
  ConsumerState<IncomingRequestScreen> createState() => _IncomingRequestScreenState();
}

class _IncomingRequestScreenState extends ConsumerState<IncomingRequestScreen> {
  late PageController _pageController;
  bool _isControllerInitialized = false;
  bool _isAccepting = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final emergenciesAsync = ref.watch(availableEmergenciesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('DISPATCH ALERTS', style: TextStyle(color: AppColors.emergencyRed, fontWeight: FontWeight.w800, letterSpacing: 2)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: emergenciesAsync.when(
        data: (emergencies) {
          if (emergencies.isEmpty) {
            return const Center(child: Text('No active emergencies.', style: TextStyle(color: Colors.white)));
          }

          if (!_isControllerInitialized) {
            int initialIndex = emergencies.indexWhere((e) => e.id == widget.emergencyId);
            if (initialIndex == -1) initialIndex = 0;
            _pageController = PageController(initialPage: initialIndex);
            _isControllerInitialized = true;
          }

          return Column(
            children: [
              if (emergencies.length > 1)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.swipe, color: Colors.white54, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Swipe to view ${emergencies.length} emergencies',
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: emergencies.length,
                  itemBuilder: (context, index) {
                    final emergency = emergencies[index];
                    return _buildEmergencyCard(context, ref, emergency, index, emergencies.length);
                  },
                ),
              ),
              // Dots indicator
              if (emergencies.length > 1)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      emergencies.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.emergencyRed)),
        error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white))),
      ),
    );
  }

  Widget _buildEmergencyCard(BuildContext context, WidgetRef ref, EmergencyModel emergency, int currentIndex, int total) {
    final patientAsync = ref.watch(patientDetailsProvider(emergency.patientId));
    final address = emergency.location['address'] ?? 'Coordinates acquired';

    return Stack(
      children: [
        // Radar background pulse
        Center(
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: emergency.severity.color.withOpacity(0.2), width: 2),
            ),
          ).animate(onPlay: (c) => c.repeat()).scale(begin: const Offset(0.5, 0.5), end: const Offset(2, 2), duration: 2.seconds).fadeOut(),
        ),
        
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Severity Icon
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: emergency.severity.color.withOpacity(0.15),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: emergency.severity.color.withOpacity(0.3),
                              blurRadius: 30,
                              spreadRadius: 5,
                            )
                          ],
                        ),
                        child: Icon(
                          Icons.warning_rounded,
                          color: emergency.severity.color,
                          size: 64,
                        ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 800.ms),
                      ),
                      const SizedBox(height: 24),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          emergency.category.replaceAll('_', ' ').toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: emergency.severity.color,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${emergency.severity.displayName.toUpperCase()} PRIORITY',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1),
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // Data Card
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF161B22),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            patientAsync.when(
                              data: (patientData) => Column(
                                children: [
                                  _detailRow(Icons.person_rounded, 'PATIENT', patientData?['full_name'] ?? 'Unknown Patient', Colors.white),
                                  const Divider(color: Colors.white10, height: 24),
                                  _detailRow(Icons.phone_rounded, 'CONTACT', patientData?['phone'] ?? 'No Phone Provided', AppColors.successGreen),
                                  const Divider(color: Colors.white10, height: 24),
                                ],
                              ),
                              loading: () => const Padding(padding: EdgeInsets.only(bottom: 24), child: CircularProgressIndicator()),
                              error: (_, __) => const SizedBox(),
                            ),
                            _detailRow(Icons.location_on_rounded, 'LOCATION', address, Colors.white),
                            const Divider(color: Colors.white10, height: 24),
                            _detailRow(Icons.medical_information_rounded, 'NOTES', emergency.note, AppColors.emergencyRed),
                          ],
                        ),
                      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16), // Add spacing between scroll view and actions
              
              // Actions
              SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: AppButton(
                        label: 'DECLINE',
                        onPressed: () {
                          if (total > 1) {
                            if (currentIndex < total - 1) {
                              _pageController.nextPage(duration: 300.ms, curve: Curves.easeIn);
                            } else {
                              _pageController.previousPage(duration: 300.ms, curve: Curves.easeIn);
                            }
                          } else {
                            context.pop();
                          }
                        },
                        type: ButtonType.secondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: ElevatedButton(
                        onPressed: _isAccepting ? null : () async {
                          setState(() => _isAccepting = true);
                          try {
                            final client = Supabase.instance.client;
                            await client.from('emergencies').update({'status': 'driver_assigned'}).eq('id', emergency.id);

                            // Send WhatsApp to Patient
                            final moolre = ref.read(moolreApiServiceProvider);
                            final patientData = await client.from('users').select('phone, full_name').eq('id', emergency.patientId).maybeSingle();
                            if (patientData != null && patientData['phone'] != null) {
                              final phone = patientData['phone'] as String;
                              final driverName = client.auth.currentUser?.userMetadata?['full_name'] ?? 'A Driver';
                              await moolre.sendEmergencyWhatsApp(
                                phone: phone,
                                message: '🚑 *Ambulance Dispatched*\n\n$driverName has accepted your emergency request and is currently en route to your location. Keep your Lifeline app open for live tracking.'
                              );
                            }

                            if (mounted) {
                              context.pushReplacement('/driver/navigate/${emergency.id}');
                            }
                          } catch (e) {
                            debugPrint('Accept error: $e');
                          } finally {
                            if (mounted) setState(() => _isAccepting = false);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.successGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 8,
                          shadowColor: AppColors.successGreen.withOpacity(0.5),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: _isAccepting 
                             ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                             : const Text('ACCEPT DISPATCH', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, letterSpacing: 0.5)),
                        ),
                      ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(duration: 2.seconds, color: Colors.white30),
                    ),
                  ],
                ).animate().slideY(begin: 1, duration: 500.ms, curve: Curves.easeOutExpo),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _detailRow(IconData icon, String label, String value, Color valueColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.w600, fontSize: 15)),
            ],
          ),
        ),
      ],
    );
  }
}
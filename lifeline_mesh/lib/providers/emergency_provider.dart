import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/emergency_model.dart';
import '../models/enums/emergency_status.dart';
import '../core/services/supabase_service.dart';
import '../core/constants/api_constants.dart';
import '../core/services/notification_service.dart';

final emergencyListProvider = FutureProvider<List<EmergencyModel>>((ref) async {
  final supabase = ref.read(supabaseServiceProvider);
  final userId = supabase.currentUser?.id;
  if (userId == null) return [];

  final data = await supabase.query(ApiConstants.tableEmergencies,
      column: 'patient_id', value: userId);
  return data.map((e) => EmergencyModel.fromJson(e)).toList();
});

final activeEmergencyProvider = StreamProvider<EmergencyModel?>((ref) {
  final supabase = ref.read(supabaseServiceProvider);
  final userId = supabase.currentUser?.id;

  if (userId == null) return Stream.value(null);

  EmergencyStatus? previousStatus;

  return supabase
      .streamQuery(ApiConstants.tableEmergencies, column: 'patient_id', value: userId)
      .map((list) {
    final active = list
        .map((e) => EmergencyModel.fromJson(e))
        .where((e) => e.isActive)
        .toList();
        
    final currentEmergency = active.isNotEmpty ? active.first : null;
    
    // Check if status changed and fire notification
    if (currentEmergency != null) {
      if (previousStatus != null && previousStatus != currentEmergency.status) {
        if (currentEmergency.status == EmergencyStatus.driverArrived) {
          NotificationService().showNotification(
            id: 1,
            title: 'Ambulance Arrived 🚑',
            body: 'Your driver has arrived at your location.',
          );
        } else if (currentEmergency.status == EmergencyStatus.hospitalPrepared) {
          NotificationService().showNotification(
            id: 2,
            title: 'Hospital Prepared 🏥',
            body: 'The destination hospital has acknowledged the emergency and is ready.',
          );
        }
      }
      previousStatus = currentEmergency.status;
    }
    
    return currentEmergency;
  });
});

final emergencyDetailProvider =
    StreamProvider.family<EmergencyModel?, String>((ref, id) {
  final supabase = ref.read(supabaseServiceProvider);
  return supabase.client
      .from(ApiConstants.tableEmergencies)
      .stream(primaryKey: ['id'])
      .eq('id', id)
      .map((list) =>
          list.isNotEmpty ? EmergencyModel.fromJson(list.first) : null);
});

final driverLocationStreamProvider = StreamProvider.family<Map<String, dynamic>?, String>((ref, driverId) {
  final supabase = ref.read(supabaseServiceProvider);
  return supabase.client
      .from('driver_location_updates')
      .stream(primaryKey: ['id'])
      .eq('driver_id', driverId)
      .order('timestamp', ascending: false)
      .limit(1)
      .map((list) => list.isNotEmpty ? list.first : null);
});

final patientDetailsProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, patientId) async {
  final supabase = ref.read(supabaseServiceProvider);
  final result = await supabase.client
      .from('users')
      .select('full_name, phone')
      .eq('id', patientId)
      .maybeSingle();
  return result;
});

final communityEmergenciesProvider = StreamProvider<List<EmergencyModel>>((ref) {
  final supabase = ref.read(supabaseServiceProvider);
  return supabase.client
      .from(ApiConstants.tableEmergencies)
      .stream(primaryKey: ['id'])
      .order('created_at', ascending: false)
      .map((list) => list
          .map((e) => EmergencyModel.fromJson(e))
          .where((e) => e.status != EmergencyStatus.completed && e.status != EmergencyStatus.cancelled)
          .toList());
});

class EmergencyFundingService {
  static Future<void> contribute(String emergencyId, double amount, {String paymentMethod = 'mobile_money'}) async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;
    
    // Call the Edge Function which runs with service role to safely bypass RLS
    // and trigger the database update for raised_amount
    await client.functions.invoke('process-contribution', body: {
      'emergency_id': emergencyId,
      'contributor_id': userId,
      'amount': amount,
      'payment_method': paymentMethod,
    });
  }
}
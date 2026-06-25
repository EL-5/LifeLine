import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/emergency_model.dart';
import '../models/enums/emergency_status.dart';
import '../core/services/supabase_service.dart';
import '../core/constants/api_constants.dart';

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

  return supabase
      .streamQuery(ApiConstants.tableEmergencies, column: 'patient_id', value: userId)
      .map((list) {
    final active = list
        .map((e) => EmergencyModel.fromJson(e))
        .where((e) => e.isActive)
        .toList();
    return active.isNotEmpty ? active.first : null;
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
  static Future<void> contribute(String emergencyId, double amount) async {
    final client = Supabase.instance.client;
    final res = await client.from('emergencies').select('raised_amount').eq('id', emergencyId).single();
    final current = double.tryParse(res['raised_amount'].toString()) ?? 0.0;
    await client.from('emergencies').update({'raised_amount': current + amount}).eq('id', emergencyId);
  }
}
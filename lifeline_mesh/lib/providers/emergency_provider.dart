import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/emergency_model.dart';
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
    FutureProvider.family<EmergencyModel?, String>((ref, id) async {
  final supabase = ref.read(supabaseServiceProvider);
  final data = await supabase.querySingle(ApiConstants.tableEmergencies, 'id', id);
  return data != null ? EmergencyModel.fromJson(data) : null;
});
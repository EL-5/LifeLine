import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/driver_model.dart';
import '../models/emergency_model.dart';
import '../core/services/supabase_service.dart';
import '../core/constants/api_constants.dart';

final myDriverProfileProvider = FutureProvider<DriverModel?>((ref) async {
  final supabase = ref.read(supabaseServiceProvider);
  final userId = supabase.currentUser?.id;
  if (userId == null) return null;

  final data = await supabase.querySingle(ApiConstants.tableDrivers, 'user_id', userId);
  return data != null ? DriverModel.fromJson(data) : null;
});

final availableEmergenciesProvider = StreamProvider<List<EmergencyModel>>((ref) {
  final supabase = ref.read(supabaseServiceProvider);
  return supabase
      .streamQuery(ApiConstants.tableEmergencies)
      .map((list) => list
          .map((e) => EmergencyModel.fromJson(e))
          .where((e) => e.status.needsDriver)
          .toList());
});
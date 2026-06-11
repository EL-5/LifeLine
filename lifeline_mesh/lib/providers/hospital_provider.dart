import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/hospital_model.dart';
import '../models/emergency_model.dart';
import '../core/services/supabase_service.dart';
import '../core/constants/api_constants.dart';

final hospitalsProvider = FutureProvider<List<HospitalModel>>((ref) async {
  final supabase = ref.read(supabaseServiceProvider);
  final data = await supabase.query(ApiConstants.tableHospitals);
  return data.map((e) => HospitalModel.fromJson(e)).toList();
});

final hospitalIncomingEmergenciesProvider =
    StreamProvider<List<EmergencyModel>>((ref) {
  final supabase = ref.read(supabaseServiceProvider);
  return supabase
      .streamQuery(ApiConstants.tableEmergencies)
      .map((list) => list
          .map((e) => EmergencyModel.fromJson(e))
          .where((e) => e.status.isActive)
          .toList());
});
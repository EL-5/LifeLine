import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/contribution_model.dart';
import '../core/services/supabase_service.dart';
import '../core/constants/api_constants.dart';

final contributionsByEmergencyProvider =
    FutureProvider.family<List<ContributionModel>, String>((ref, emergencyId) async {
  final supabase = ref.read(supabaseServiceProvider);
  final data = await supabase.query(ApiConstants.tableContributions,
      column: 'emergency_id', value: emergencyId);
  return data.map((e) => ContributionModel.fromJson(e)).toList();
});

final myContributionsProvider = FutureProvider<List<ContributionModel>>((ref) async {
  final supabase = ref.read(supabaseServiceProvider);
  final userId = supabase.currentUser?.id;
  if (userId == null) return [];

  final data = await supabase.query(ApiConstants.tableContributions,
      column: 'contributor_id', value: userId);
  return data.map((e) => ContributionModel.fromJson(e)).toList();
});
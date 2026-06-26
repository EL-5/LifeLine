import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_provider.dart';
import '../core/services/supabase_service.dart';

class MedicalProfile {
  final String? id;
  final String userId;
  final String bloodGroup;
  final String genotype;
  final String allergies;
  final String chronicConditions;
  final String currentMedications;

  MedicalProfile({
    this.id,
    required this.userId,
    this.bloodGroup = '',
    this.genotype = '',
    this.allergies = '',
    this.chronicConditions = '',
    this.currentMedications = '',
  });

  factory MedicalProfile.fromJson(Map<String, dynamic> json) {
    return MedicalProfile(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      bloodGroup: json['blood_group'] as String? ?? '',
      genotype: json['genotype'] as String? ?? '',
      allergies: json['allergies'] as String? ?? '',
      chronicConditions: json['chronic_conditions'] as String? ?? '',
      currentMedications: json['current_medications'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'blood_group': bloodGroup,
      'genotype': genotype,
      'allergies': allergies,
      'chronic_conditions': chronicConditions,
      'current_medications': currentMedications,
    };
  }

  String toAiPromptFormat() {
    return '''
Patient Medical Profile:
- Blood Group: ${bloodGroup.isEmpty ? 'Unknown' : bloodGroup}
- Genotype: ${genotype.isEmpty ? 'Unknown' : genotype}
- Allergies: ${allergies.isEmpty ? 'None reported' : allergies}
- Chronic Conditions: ${chronicConditions.isEmpty ? 'None reported' : chronicConditions}
- Current Medications: ${currentMedications.isEmpty ? 'None reported' : currentMedications}
''';
  }
}

final medicalProfileProvider = FutureProvider<MedicalProfile?>((ref) async {
  final supabase = ref.read(supabaseServiceProvider);
  final user = supabase.currentUser;
  
  if (user == null) return null;

  try {
    final data = await supabase.client
        .from('medical_profiles')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();

    if (data == null) {
      return null;
    }
    
    return MedicalProfile.fromJson(data);
  } catch (e) {
    print('Error fetching medical profile: $e');
    return null;
  }
});

final updateMedicalProfileProvider = Provider((ref) {
  final supabase = ref.read(supabaseServiceProvider);
  
  return (MedicalProfile profile) async {
    final userId = supabase.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    final data = profile.toJson();
    data['updated_at'] = DateTime.now().toIso8601String();

    await supabase.client
        .from('medical_profiles')
        .upsert(data, onConflict: 'user_id');

    // Invalidate the provider so the UI updates
    ref.invalidate(medicalProfileProvider);
  };
});

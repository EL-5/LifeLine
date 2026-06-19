import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/supabase_service.dart';
import '../models/family_connection_model.dart';

// ─── Family Connections ──────────────────────────────────────────────────────

final familyConnectionsProvider =
    StreamProvider<List<FamilyConnectionModel>>((ref) {
  final supabase = ref.read(supabaseServiceProvider);
  final userId = supabase.currentUser?.id;
  if (userId == null) return Stream.value([]);

  return supabase.client
      .from('family_connections')
      .stream(primaryKey: ['id'])
      .eq('user_id', userId)
      .map((list) => list
          .map((e) =>
              FamilyConnectionModel.fromJson(e))
          .toList());
});

// ─── Invite Family Member ────────────────────────────────────────────────────

final inviteFamilyMemberProvider =
    Provider<Future<void> Function(String phone, String relationship)>((ref) {
  final supabase = ref.read(supabaseServiceProvider);

  return (String phone, String relationship) async {
    final userId = supabase.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    // Find the target user by phone
    final results = await supabase.client
        .from('users')
        .select('id')
        .eq('phone', phone)
        .limit(1);

    if ((results as List).isEmpty) {
      throw Exception(
          'No Lifeline Mesh account found for $phone. Ask them to sign up first.');
    }

    final familyMemberId = results.first['id'] as String;

    if (familyMemberId == userId) {
      throw Exception('You cannot add yourself as a family member.');
    }

    await supabase.client.from('family_connections').insert({
      'user_id': userId,
      'family_member_id': familyMemberId,
      'relationship_type': relationship,
      'status': 'invited',
    });
  };
});

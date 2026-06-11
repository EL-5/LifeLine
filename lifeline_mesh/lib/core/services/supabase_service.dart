import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

class SupabaseService {
  SupabaseService();

  SupabaseClient get client => Supabase.instance.client;

  // Supabase initialization is handled in main.dart before runApp.
  // This service provides access to the already-initialized client.
  // Auth
  Future<void> signInWithOtp(String phone) async {
    await client.auth.signInWithOtp(
      phone: phone,
    );
  }

  Future<AuthResponse> verifyOtp({
    required String phone,
    required String token,
  }) async {
    return client.auth.verifyOTP(
      phone: phone,
      token: token,
      type: OtpType.sms,
    );
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  User? get currentUser => client.auth.currentUser;
  Session? get currentSession => client.auth.currentSession;

  Stream<AuthState> get authState => client.auth.onAuthStateChange;

  // Database helpers
  Future<List<Map<String, dynamic>>> query(String table, {
    String? column,
    dynamic value,
  }) async {
    var query = client.from(table).select();
    if (column != null && value != null) {
      query = query.eq(column, value);
    }
    return query;
  }

  Future<Map<String, dynamic>?> querySingle(String table, String column, dynamic value) async {
    final results = await client.from(table).select().eq(column, value).limit(1);
    return results.isNotEmpty ? results.first as Map<String, dynamic>? : null;
  }

  Future<void> insert(String table, Map<String, dynamic> data) async {
    await client.from(table).insert(data);
  }

  Future<void> update(String table, Map<String, dynamic> data, String column, dynamic value) async {
    await client.from(table).update(data).eq(column, value);
  }

  Stream<List<Map<String, dynamic>>> streamQuery(String table, {
    String? column,
    dynamic value,
  }) {
    var query = client.from(table).stream(primaryKey: ['id']);
    if (column != null && value != null) {
      return query.eq(column, value);
    }
    return query;
  }

  // Realtime
  RealtimeChannel subscribeToChannel(String channel) {
    final sub = client.channel(channel);
    sub.subscribe();
    return sub;
  }

  // Edge Functions
  Future<dynamic> invokeFunction(String functionName, {
    Map<String, dynamic>? body,
  }) async {
    return client.functions.invoke(functionName, body: body);
  }

  // Storage
  Future<String> uploadFile(String bucket, String path, dynamic file) async {
    await client.storage.from(bucket).upload(path, file);
    return client.storage.from(bucket).getPublicUrl(path);
  }
}
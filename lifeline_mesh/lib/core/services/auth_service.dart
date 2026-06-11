import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'supabase_service.dart';
import '../../models/user_model.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.read(supabaseServiceProvider));
});

class AuthService {
  final SupabaseService _supabase;

  AuthService(this._supabase);

  Future<void> sendOtp(String phone) async {
    await _supabase.signInWithOtp(phone);
  }

  Future<UserModel?> verifyOtp({
    required String phone,
    required String token,
  }) async {
    final response = await _supabase.verifyOtp(phone: phone, token: token);
    final user = response.user;
    if (user == null) return null;

    // Check if user exists in our users table
    final existing = await _supabase.querySingle('users', 'id', user.id);
    if (existing != null) {
      return UserModel.fromJson(existing);
    }

    return UserModel(
      id: user.id,
      phone: user.phone,
    );
  }

  Future<UserModel> createUserProfile(UserModel user) async {
    await _supabase.insert('users', user.toJson());
    return user;
  }

  Future<void> updateUserProfile(UserModel user) async {
    await _supabase.update('users', user.toJson(), 'id', user.id);
  }

  Future<void> logout() async {
    await _supabase.signOut();
  }

  Future<UserModel?> getCurrentUser() async {
    final user = _supabase.currentUser;
    if (user == null) return null;

    final data = await _supabase.querySingle('users', 'id', user.id);
    if (data != null) {
      return UserModel.fromJson(data);
    }
    return null;
  }

  Stream<UserModel?> onAuthStateChanged() {
    return _supabase.authState.map((event) {
      if (event.session?.user != null) {
        // We return a minimal user; the provider will fetch full profile
        return UserModel(id: event.session!.user.id);
      }
      return null;
    });
  }
}
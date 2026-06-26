import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/supabase_service.dart';

class UserSettings {
  final String userId;
  final String language;
  final bool pushEnabled;
  final bool smsEnabled;
  final bool emailEnabled;
  final bool marketingEnabled;

  UserSettings({
    required this.userId,
    this.language = 'English',
    this.pushEnabled = true,
    this.smsEnabled = true,
    this.emailEnabled = false,
    this.marketingEnabled = false,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      userId: json['user_id'] as String,
      language: json['language'] as String? ?? 'English',
      pushEnabled: json['push_enabled'] as bool? ?? true,
      smsEnabled: json['sms_enabled'] as bool? ?? true,
      emailEnabled: json['email_enabled'] as bool? ?? false,
      marketingEnabled: json['marketing_enabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'language': language,
      'push_enabled': pushEnabled,
      'sms_enabled': smsEnabled,
      'email_enabled': emailEnabled,
      'marketing_enabled': marketingEnabled,
    };
  }

  UserSettings copyWith({
    String? language,
    bool? pushEnabled,
    bool? smsEnabled,
    bool? emailEnabled,
    bool? marketingEnabled,
  }) {
    return UserSettings(
      userId: userId,
      language: language ?? this.language,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      smsEnabled: smsEnabled ?? this.smsEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      marketingEnabled: marketingEnabled ?? this.marketingEnabled,
    );
  }
}

final settingsProvider = FutureProvider<UserSettings>((ref) async {
  final supabase = ref.read(supabaseServiceProvider).client;
  final user = supabase.auth.currentUser;
  
  if (user == null) {
    return UserSettings(userId: '');
  }

  try {
    final data = await supabase
        .from('user_settings')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();

    if (data == null) {
      // Return default settings if none exist
      return UserSettings(userId: user.id);
    }
    
    return UserSettings.fromJson(data);
  } catch (e) {
    print('Error fetching user settings: $e');
    return UserSettings(userId: user.id);
  }
});

final updateSettingsProvider = Provider((ref) {
  final supabase = ref.read(supabaseServiceProvider).client;
  
  return (UserSettings settings) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    final data = settings.toJson();
    data['updated_at'] = DateTime.now().toIso8601String();

    await supabase
        .from('user_settings')
        .upsert(data, onConflict: 'user_id');

    // Invalidate the provider so the UI updates
    ref.invalidate(settingsProvider);
  };
});

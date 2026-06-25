import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/supabase_service.dart';
import '../models/emergency_model.dart';
import '../models/audit_log_model.dart';
import '../models/user_model.dart';

// ─── Admin Stats ────────────────────────────────────────────────────────────

class AdminStats {
  final int activeEmergencies;
  final int totalUsers;
  final int totalDrivers;
  final double totalFundsRaised;
  final int emergenciesLast24h;
  final int flaggedCount;
  final double avgResponseTimeMinutes;

  const AdminStats({
    this.activeEmergencies = 0,
    this.totalUsers = 0,
    this.totalDrivers = 0,
    this.totalFundsRaised = 0,
    this.emergenciesLast24h = 0,
    this.flaggedCount = 0,
    this.avgResponseTimeMinutes = 0,
  });
}

final adminStatsProvider = FutureProvider<AdminStats>((ref) async {
  final supabase = ref.read(supabaseServiceProvider);
  try {
    final data = await supabase.client
        .from('admin_stats')
        .select()
        .single();
    return AdminStats(
      activeEmergencies: (data['active_emergencies'] as num?)?.toInt() ?? 0,
      totalUsers: (data['total_users'] as num?)?.toInt() ?? 0,
      totalDrivers: (data['total_drivers'] as num?)?.toInt() ?? 0,
      totalFundsRaised:
          (data['total_funds_raised'] as num?)?.toDouble() ?? 0.0,
      emergenciesLast24h:
          (data['emergencies_last_24h'] as num?)?.toInt() ?? 0,
      flaggedCount: (data['flagged_count'] as num?)?.toInt() ?? 0,
      avgResponseTimeMinutes:
          (data['avg_response_time_minutes'] as num?)?.toDouble() ?? 0.0,
    );
  } catch (_) {
    return const AdminStats();
  }
});

// ─── User Management ─────────────────────────────────────────────────────────

final allUsersProvider =
    FutureProvider.family<List<UserModel>, String>((ref, searchQuery) async {
  final supabase = ref.read(supabaseServiceProvider);
  try {
    var query = supabase.client
        .from('users')
        .select();

    if (searchQuery.isNotEmpty) {
      query = query.or(
          'full_name.ilike.%$searchQuery%,phone.ilike.%$searchQuery%');
    }

    final data = await query
        .order('created_at', ascending: false)
        .limit(50);
    return data
        .map((e) => UserModel.fromJson(e))
        .toList();
  } catch (_) {
    return [];
  }
});

// ─── Fraud Monitoring ────────────────────────────────────────────────────────

final flaggedEmergenciesProvider =
    StreamProvider<List<EmergencyModel>>((ref) {
  final supabase = ref.read(supabaseServiceProvider);
  return supabase.client
      .from('emergencies')
      .stream(primaryKey: ['id'])
      .eq('fraud_flag', true)
      .map((list) => list
          .map((e) => EmergencyModel.fromJson(e))
          .where((e) => e.status.isActive)
          .toList());
});

// ─── Audit Logs ──────────────────────────────────────────────────────────────

final auditLogsProvider =
    FutureProvider<List<AuditLogModel>>((ref) async {
  final supabase = ref.read(supabaseServiceProvider);
  try {
    final data = await supabase.client
        .from('audit_logs')
        .select()
        .order('created_at', ascending: false)
        .limit(50);
    return data
        .map((e) => AuditLogModel.fromJson(e))
        .toList();
  } catch (_) {
    return [];
  }
});

// ─── Driver Approvals ───────────────────────────────────────────────────────

final pendingDriversProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = ref.read(supabaseServiceProvider);
  try {
    final data = await supabase.client
        .from('drivers')
        .select('*, users(full_name, email, phone)')
        .eq('verification_status', 'pending')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  } catch (e) {
    return [];
  }
});

class AdminController {
  final Ref ref;
  AdminController(this.ref);

  Future<void> approveDriver(String driverId, String userId) async {
    final client = ref.read(supabaseServiceProvider).client;
    await client.from('drivers').update({'verification_status': 'verified'}).eq('id', driverId);
    await client.from('users').update({'role': 'driver'}).eq('id', userId);
    ref.invalidate(pendingDriversProvider);
  }

  Future<void> rejectDriver(String driverId) async {
    final client = ref.read(supabaseServiceProvider).client;
    await client.from('drivers').update({'verification_status': 'rejected'}).eq('id', driverId);
    ref.invalidate(pendingDriversProvider);
  }
}

final adminControllerProvider = Provider((ref) => AdminController(ref));

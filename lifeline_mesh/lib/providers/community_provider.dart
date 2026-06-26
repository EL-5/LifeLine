import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/supabase_service.dart';
import '../models/emergency_model.dart';
import '../models/contribution_model.dart';

// ─── Community Campaigns ─────────────────────────────────────────────────────
// Shows active emergencies that are accepting community contributions.

final communityEmergenciesProvider =
    StreamProvider<List<EmergencyModel>>((ref) {
  final supabase = ref.read(supabaseServiceProvider);
  return supabase.client
      .from('emergencies')
      .stream(primaryKey: ['id'])
      .map((list) => list
          .map((e) => EmergencyModel.fromJson(e))
          .where((e) =>
              e.isActive &&
              !e.fraudFlag &&
              e.targetAmount > 0 &&
              e.raisedAmount < e.targetAmount)
          .toList());
});

// ─── My Contributions ────────────────────────────────────────────────────────

final myContributionsProvider =
    FutureProvider<List<ContributionModel>>((ref) async {
  final supabase = ref.read(supabaseServiceProvider);
  final userId = supabase.currentUser?.id;
  if (userId == null) return [];
  try {
    final data = await supabase.client
        .from('contributions')
        .select('*, emergencies(category)')
        .eq('contributor_id', userId)
        .order('created_at', ascending: false);
    return data
        .map((e) => ContributionModel.fromJson(e))
        .toList();
  } catch (_) {
    return [];
  }
});

// ─── Wallet Summary ──────────────────────────────────────────────────────────

class WalletSummary {
  final double totalContributed;
  final double totalReceived;
  final double totalDeposited;
  final double totalSpentFromWallet;
  final int campaignsSupported;

  const WalletSummary({
    this.totalContributed = 0,
    this.totalReceived = 0,
    this.totalDeposited = 0,
    this.totalSpentFromWallet = 0,
    this.campaignsSupported = 0,
  });

  double get balance => totalReceived + totalDeposited - totalSpentFromWallet;
}

final walletSummaryProvider = FutureProvider<WalletSummary>((ref) async {
  final supabase = ref.read(supabaseServiceProvider);
  final userId = supabase.currentUser?.id;
  if (userId == null) return const WalletSummary();
  try {
    final data = await supabase.client
        .from('wallet_summary')
        .select()
        .eq('user_id', userId)
        .single();
    return WalletSummary(
      totalContributed:
          (data['total_contributed'] as num?)?.toDouble() ?? 0.0,
      totalReceived: (data['total_received'] as num?)?.toDouble() ?? 0.0,
      totalDeposited: (data['total_deposited'] as num?)?.toDouble() ?? 0.0,
      totalSpentFromWallet: (data['total_spent_from_wallet'] as num?)?.toDouble() ?? 0.0,
      campaignsSupported:
          (data['campaigns_supported'] as num?)?.toInt() ?? 0,
    );
  } catch (e) {
    print('Error loading wallet summary: $e');
    return const WalletSummary();
  }
});

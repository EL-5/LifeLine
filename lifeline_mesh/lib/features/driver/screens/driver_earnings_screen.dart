import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../providers/driver_provider.dart';

class DriverEarningsScreen extends ConsumerWidget {
  const DriverEarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driverAsync = ref.watch(myDriverProfileProvider);
    final earningsAsync = ref.watch(driverEarningsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Earnings')),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.trustBlue, Color(0xFF1976D2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.trustBlue.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Total Earnings',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  driverAsync.when(
                    data: (driver) => Text(
                      '₵${(driver?.totalEarnings ?? 0).toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    loading: () => const CircularProgressIndicator(color: Colors.white),
                    error: (_, __) => const Text('Error', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Recent Payouts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          earningsAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('Error: $e')),
            ),
            data: (payouts) => payouts.isEmpty
                ? const SliverFillRemaining(
                    child: EmptyState(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'No Payouts Yet',
                      subtitle: 'Complete emergency trips to earn payouts',
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final payout = payouts[index];
                        final emergencyCat = payout['emergencies']?['category'] ?? 'Trip';
                        final amount = payout['amount'] ?? 0;
                        final date = DateTime.parse(payout['created_at']);
                        final status = payout['status'] ?? 'pending';

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.successGreenLight,
                            child: const Icon(Icons.attach_money,
                                color: AppColors.successGreen),
                          ),
                          title: Text('Payout for $emergencyCat'),
                          subtitle: Text(DateFormat('MMM d, yyyy • h:mm a').format(date)),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '+₵${amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.successGreen,
                                ),
                              ),
                              Text(
                                status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: status == 'completed'
                                      ? AppColors.successGreen
                                      : AppColors.warningAmber,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      childCount: payouts.length,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../providers/community_provider.dart';

class TransactionHistoryScreen extends ConsumerWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(myContributionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Transaction History')),
      body: transactionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (transactions) => transactions.isEmpty
            ? const EmptyState(
                icon: Icons.receipt_long,
                title: 'No Transactions Found',
                subtitle: 'Your contribution history will appear here',
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final tx = transactions[index];
                  // The backend now joins the emergency category in the raw JSON
                  final Map<String, dynamic>? rawJson = 
                      (tx as dynamic).toJson(); // Dirty cast to access the raw data if available
                  
                  final emergencyCat = rawJson?['emergencies']?['category'] ?? 'Emergency Contribution';

                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.trustBlueLight,
                        child: const Icon(Icons.volunteer_activism,
                            color: AppColors.trustBlue),
                      ),
                      title: Text(emergencyCat.toString().replaceAll('_', ' ').toUpperCase()),
                      subtitle: Text(
                          '${tx.paymentMethod.toUpperCase()} • ${DateFormat('MMM d, yyyy h:mm a').format(tx.createdAt)}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '-₵${tx.amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            tx.paymentStatus.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: tx.paymentStatus.name == 'completed'
                                  ? AppColors.successGreen
                                  : AppColors.warningAmber,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
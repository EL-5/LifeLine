import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../providers/community_provider.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(walletSummaryProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: walletAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading wallet: $e')),
        data: (wallet) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Balance Card
              Card(
                color: AppColors.trustBlue,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Text(
                        'Total Contributed',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'GHS ${wallet.totalContributed.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Top Up via Mobile Money — coming soon'),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Top Up'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white30),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  context.push('/wallet/transactions'),
                              icon: const Icon(Icons.history),
                              label: const Text('History'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white30),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Quick Stats
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Icon(Icons.favorite,
                                color: AppColors.emergencyRed, size: 28),
                            const SizedBox(height: 8),
                            Text(
                              'GHS ${wallet.totalContributed.toStringAsFixed(0)}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const Text(
                              'Contributed',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Icon(Icons.handshake,
                                color: AppColors.successGreen, size: 28),
                            const SizedBox(height: 8),
                            Text(
                              wallet.campaignsSupported.toString(),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const Text(
                              'Campaigns',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              // Payment Methods
              Card(
                child: ListTile(
                  title: const Text('Payment Methods'),
                  subtitle: const Text('Mobile Money, Card, Wallet'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showPaymentMethodsSheet(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPaymentMethodsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161B22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Payment Methods', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 16),
                  ..._mockPaymentMethods.map((pm) {
                    return ListTile(
                      leading: Icon(pm['icon'], color: pm['color']),
                      title: Text(pm['title'], style: const TextStyle(color: Colors.white)),
                      subtitle: Text(pm['subtitle'], style: const TextStyle(color: Colors.white70)),
                      trailing: Icon(pm['isLinked'] ? Icons.check_circle : Icons.add, color: pm['isLinked'] ? Colors.green : Colors.white54),
                      onTap: () {
                        _showAddEditPaymentDialog(context, pm, () {
                          setSheetState(() {});
                        });
                      },
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                ],
              ),
            );
          }
        );
      },
    );
  }

  void _showAddEditPaymentDialog(BuildContext context, Map<String, dynamic> method, VoidCallback onSaved) {
    final isEditing = method['isLinked'];
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isEditing ? 'Edit ${method['title']}' : 'Add ${method['title']}', style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: isEditing ? 'Update Account Number' : 'Card / Account Number',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF0D1117),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                // Update the mock state
                String last4 = controller.text.length >= 4 
                    ? controller.text.substring(controller.text.length - 4) 
                    : controller.text;
                method['subtitle'] = '**** **** $last4';
                method['isLinked'] = true;
                onSaved();
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(isEditing ? '${method['title']} updated successfully!' : '${method['title']} added successfully!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.trustBlue),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// Global mock state so it persists while the app is running
List<Map<String, dynamic>> _mockPaymentMethods = [
  {
    'title': 'MTN Mobile Money',
    'subtitle': '**** **** 1234',
    'icon': Icons.phone_android,
    'color': Colors.amber,
    'isLinked': true,
  },
  {
    'title': 'Telecel Cash',
    'subtitle': 'Not linked',
    'icon': Icons.phone_android,
    'color': Colors.red,
    'isLinked': false,
  },
  {
    'title': 'Visa / Mastercard',
    'subtitle': 'Add a debit or credit card',
    'icon': Icons.credit_card,
    'color': Colors.blue,
    'isLinked': false,
  },
];
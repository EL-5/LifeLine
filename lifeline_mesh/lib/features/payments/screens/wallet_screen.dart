import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/colors.dart';
import '../../../providers/community_provider.dart';
import '../../../core/services/moolre_api_service.dart';

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
                        'Available Balance',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'GHS ${wallet.balance.toStringAsFixed(2)}',
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
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) => const _TopUpBottomSheet(),
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

class _TopUpBottomSheet extends ConsumerStatefulWidget {
  const _TopUpBottomSheet();

  @override
  ConsumerState<_TopUpBottomSheet> createState() => _TopUpBottomSheetState();
}

class _TopUpBottomSheetState extends ConsumerState<_TopUpBottomSheet> {
  double _amount = 100;
  bool _isLoading = false;
  final TextEditingController _customAmountController = TextEditingController(text: '100');
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _customAmountController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _processTopUp() async {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter Mobile Money Number')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final moolre = ref.read(moolreApiServiceProvider);
      
      // We simulate top-up with the same payment endpoint
      final success = await moolre.fundCommunityPool(
        amount: _amount,
        phone: _phoneController.text,
      );
      
      if (success) {
        final client = Supabase.instance.client;
        final userId = client.auth.currentUser?.id;
        if (userId != null) {
          // Insert top-up directly into the new wallet_deposits table
          await client.from('wallet_deposits').insert({
            'user_id': userId,
            'amount': _amount,
            'moolre_reference': 'TOPUP-${DateTime.now().millisecondsSinceEpoch}'
          });

          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('GHS ${_amount.toStringAsFixed(0)} added to wallet successfully.')));
            // Refresh wallet summary
            ref.invalidate(walletSummaryProvider);
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Top-up failed. Please try again.')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF161B22),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Top Up Wallet', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          const Text('Enter amount to add via Mobile Money', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [50.0, 100.0, 200.0].map((amt) {
              final isSelected = _amount == amt;
              return ChoiceChip(
                label: Text('GHS ${amt.toInt()}'),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _amount = amt;
                      _customAmountController.text = amt.toInt().toString();
                    });
                  }
                },
                selectedColor: AppColors.trustBlue,
                labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white70),
                backgroundColor: const Color(0xFF0D1117),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _customAmountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Custom Amount (GHS)',
              labelStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: const Color(0xFF0D1117),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              prefixText: 'GHS ',
              prefixStyle: const TextStyle(color: Colors.white70),
            ),
            onChanged: (val) {
              final parsed = double.tryParse(val);
              if (parsed != null) {
                setState(() => _amount = parsed);
              }
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Mobile Money Number',
              labelStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: const Color(0xFF0D1117),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              prefixIcon: const Icon(Icons.phone, color: Colors.white54),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _processTopUp,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.trustBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text('Top Up GHS ${_amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/services/moolre_api_service.dart';

class CampaignDetailScreen extends ConsumerStatefulWidget {
  final String emergencyId;

  const CampaignDetailScreen({super.key, required this.emergencyId});

  @override
  ConsumerState<CampaignDetailScreen> createState() => _CampaignDetailScreenState();
}

class _CampaignDetailScreenState extends ConsumerState<CampaignDetailScreen> {
  double _contributionAmount = 50;
  bool _isLoading = false;
  final TextEditingController _customAmountController = TextEditingController(text: '50');

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  void _showPaymentDialog() {
    final phoneController = TextEditingController();
    String selectedNetwork = 'MTN';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF161B22),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Complete Contribution', style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('You are about to contribute GHS ${_contributionAmount.toStringAsFixed(2)}.', style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Mobile Money Number',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: const Color(0xFF0D1117),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedNetwork,
                    dropdownColor: const Color(0xFF161B22),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Network',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: const Color(0xFF0D1117),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    ),
                    items: ['MTN', 'VODAFONE', 'AIRTELTIGO'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setDialogState(() => selectedNetwork = v!),
                  )
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (phoneController.text.isEmpty) return;
                    Navigator.pop(context);
                    _processMoolrePayment(phoneController.text, selectedNetwork);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.trustBlue),
                  child: const Text('Pay via Moolre', style: TextStyle(color: Colors.white)),
                )
              ]
            );
          }
        );
      }
    );
  }

  Future<void> _processMoolrePayment(String phone, String network) async {
    setState(() => _isLoading = true);
    try {
      final moolre = ref.read(moolreApiServiceProvider);
      
      // Use the actual Moolre API method for funding
      final success = await moolre.fundCommunityPool(
        amount: _contributionAmount,
        phone: phone,
      );
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Initiated! Please check your phone to authorize.')));
          
          // Send the Gratitude SMS via Moolre SMS API
          await moolre.sendEmergencySms(
            phone: phone,
            message: 'Thank you for your generous contribution of GHS ${_contributionAmount.toStringAsFixed(0)} to Emergency Campaign #${widget.emergencyId}! Your support is actively saving a life.',
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Error: Could not initiate payment via Moolre.')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Campaign Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.emergencyRedLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.emergency,
                            color: AppColors.emergencyRed,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Emergency Campaign', style: AppTextStyles.titleMedium),
                              const Text(
                                'Accra, Ghana',
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: 0.45,
                      backgroundColor: AppColors.divider,
                      color: AppColors.successGreen,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _statColumn('Raised', 'GHS 1,800'),
                        _statColumn('Target', 'GHS 4,000'),
                        _statColumn('Supporters', '24'),
                        _statColumn('Remaining', 'GHS 2,200'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Make a Contribution', style: AppTextStyles.titleLarge),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text('GHS ', style: AppTextStyles.headlineLarge.copyWith(color: AppColors.successGreen)),
                        IntrinsicWidth(
                          child: TextField(
                            controller: _customAmountController,
                            keyboardType: TextInputType.number,
                            style: AppTextStyles.displayMedium.copyWith(color: AppColors.successGreen),
                            decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                            onChanged: (val) {
                              final parsed = double.tryParse(val);
                              if (parsed != null) setState(() => _contributionAmount = parsed);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: [10, 25, 50, 100, 200, 500].map((amount) {
                        final isSelected = _contributionAmount == amount;
                        return ChoiceChip(
                          label: Text('GHS $amount'),
                          selected: isSelected,
                          selectedColor: AppColors.successGreenLight,
                          onSelected: (_) {
                            setState(() {
                              _contributionAmount = amount.toDouble();
                              _customAmountController.text = amount.toString();
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else
                      AppButton(
                        label: 'Contribute GHS ${_contributionAmount.toStringAsFixed(0)}',
                        onPressed: _showPaymentDialog,
                        type: ButtonType.success,
                        icon: Icons.favorite,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Transparency Dashboard', style: AppTextStyles.titleLarge),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _transparencyRow(Icons.local_hospital, 'Hospital', 'Ready'),
                    const Divider(),
                    _transparencyRow(Icons.directions_car, 'Driver', 'Assigned'),
                    const Divider(),
                    _transparencyRow(Icons.people, 'Family', 'Notified'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }

  Widget _transparencyRow(IconData icon, String label, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.successGreenLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Done',
              style: TextStyle(
                color: AppColors.successGreen,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
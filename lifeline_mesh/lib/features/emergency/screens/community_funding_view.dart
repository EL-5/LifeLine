import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../providers/emergency_provider.dart';
import '../../../core/services/moolre_api_service.dart';

class CommunityFundingView extends ConsumerWidget {
  const CommunityFundingView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emergenciesAsync = ref.watch(communityEmergenciesProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: emergenciesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading feed: $err')),
        data: (emergencies) {
          if (emergencies.isEmpty) {
            return const Center(
              child: Text(
                'No active emergencies require funding at the moment.\nThank you for being a hero!',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: emergencies.length,
            itemBuilder: (context, index) {
              final em = emergencies[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              em.category.replaceAll('_', ' ').toUpperCase(),
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.trustBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              em.status.name,
                              style: const TextStyle(color: AppColors.trustBlue, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Mock Patient Name Fetching
                      Consumer(
                        builder: (context, ref, child) {
                          final patientData = ref.watch(patientDetailsProvider(em.patientId));
                          return patientData.when(
                            data: (data) => Text(
                              'Patient: ${data?['full_name'] ?? 'Anonymous Member'}',
                              style: const TextStyle(color: AppColors.textSecondary),
                            ),
                            loading: () => const Text('Loading patient...', style: TextStyle(color: AppColors.textSecondary)),
                            error: (_, __) => const Text('Patient: Anonymous'),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: em.fundingProgress,
                        backgroundColor: AppColors.divider,
                        color: AppColors.successGreen,
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'GHS ${em.raisedAmount} raised',
                            style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.successGreen),
                          ),
                          Text(
                            'Goal: GHS ${em.targetAmount}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (em.raisedAmount >= em.targetAmount && em.targetAmount > 0)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.successGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Fully Funded! 🎉',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.successGreen, fontWeight: FontWeight.bold),
                          ),
                        )
                      else
                        AppButton(
                          label: 'Contribute Now',
                          icon: Icons.volunteer_activism,
                          onPressed: () => _showDonationModal(context, em.id, em.category),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showDonationModal(BuildContext context, String emergencyId, String category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF161B22),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => _DonationModalBottomSheet(emergencyId: emergencyId, category: category),
    );
  }
}

class _DonationModalBottomSheet extends ConsumerStatefulWidget {
  final String emergencyId;
  final String category;

  const _DonationModalBottomSheet({required this.emergencyId, required this.category});

  @override
  ConsumerState<_DonationModalBottomSheet> createState() => _DonationModalBottomSheetState();
}

class _DonationModalBottomSheetState extends ConsumerState<_DonationModalBottomSheet> {
  double _amount = 50;
  bool _isLoading = false;
  final TextEditingController _customAmountController = TextEditingController(text: '50');
  final TextEditingController _phoneController = TextEditingController();
  String _selectedNetwork = 'MTN';

  @override
  void dispose() {
    _customAmountController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter Mobile Money Number')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final moolre = ref.read(moolreApiServiceProvider);
      
      // 1. Process Moolre Payment
      final success = await moolre.fundCommunityPool(
        amount: _amount,
        phone: _phoneController.text,
      );
      
      if (success) {
        // 2. Add it up in the backend
        await EmergencyFundingService.contribute(widget.emergencyId, _amount);
        
        // 3. Send SMS
        final catName = widget.category.replaceAll('_', ' ').toUpperCase();
        await moolre.sendEmergencySms(
          phone: _phoneController.text,
          message: 'Thank you for your generous contribution of GHS ${_amount.toStringAsFixed(0)} to the $catName! Your support is actively saving a life.',
        );

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Thank you! GHS ${_amount.toStringAsFixed(0)} contributed successfully.')));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Error: Could not initiate payment via Moolre.')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to contribute: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          const Icon(Icons.favorite, color: AppColors.emergencyRed, size: 48),
          const SizedBox(height: 16),
          const Text('Support Your Community', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          const Text(
            '100% of your donation goes directly to emergency care.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 24),
          
          // Amount Input
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text('GHS ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.successGreen)),
              IntrinsicWidth(
                child: TextField(
                  controller: _customAmountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.successGreen),
                  decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                  onChanged: (val) {
                    final parsed = double.tryParse(val);
                    if (parsed != null) setState(() => _amount = parsed);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [10, 25, 50, 100, 200, 500].map((amount) {
              final isSelected = _amount == amount;
              return ChoiceChip(
                label: Text('GHS $amount'),
                selected: isSelected,
                selectedColor: AppColors.successGreenLight,
                labelStyle: TextStyle(color: isSelected ? AppColors.successGreen : Colors.white),
                backgroundColor: const Color(0xFF0D1117),
                onSelected: (_) {
                  setState(() {
                    _amount = amount.toDouble();
                    _customAmountController.text = amount.toString();
                  });
                },
              );
            }).toList(),
          ),
          
          const SizedBox(height: 24),
          // Phone Input
          TextField(
            controller: _phoneController,
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
            value: _selectedNetwork,
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
            onChanged: (v) => setState(() => _selectedNetwork = v!),
          ),

          const SizedBox(height: 24),
          if (_isLoading)
            const CircularProgressIndicator()
          else
            AppButton(
              label: 'Pay via Moolre',
              onPressed: _processPayment,
              type: ButtonType.success,
              icon: Icons.check_circle,
            ),
          const SizedBox(height: 32),
        ],
      ),
      ),
    );
  }
}

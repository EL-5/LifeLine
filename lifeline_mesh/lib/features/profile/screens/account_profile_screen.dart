import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/services/supabase_service.dart';
import 'identity_verification_screen.dart';

class AccountProfileScreen extends ConsumerStatefulWidget {
  const AccountProfileScreen({super.key});

  @override
  ConsumerState<AccountProfileScreen> createState() => _AccountProfileScreenState();
}

class _AccountProfileScreenState extends ConsumerState<AccountProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider).user;
      if (user != null) {
        _nameController.text = user.fullName ?? '';
        _phoneController.text = user.phone ?? '';
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);

    try {
      final authState = ref.read(authProvider);
      if (authState.user == null) throw Exception("User not found");

      final updatedUser = authState.user!.copyWith(
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      final supabase = ref.read(supabaseServiceProvider).client;
      await supabase.from('users').update({
        'full_name': updatedUser.fullName,
        'phone': updatedUser.phone,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', updatedUser.id);

      // Re-fetch user to update authProvider state
      await ref.read(authProvider.notifier).checkAuthStatus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e'), backgroundColor: AppColors.emergencyRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Personal Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              _buildVerificationBanner(context),
              
              const SizedBox(height: 24),
              
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Name cannot be empty' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 48),

              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: _isSaving ? 'Saving...' : 'Update Profile',
                  onPressed: _isSaving ? null : _saveProfile,
                  type: ButtonType.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationBanner(BuildContext context) {
    final user = ref.watch(authProvider).user;
    if (user == null) return const SizedBox.shrink();

    final status = user.verificationStatus;
    
    Color bgColor;
    Color textColor;
    IconData icon;
    String title;
    String subtitle;
    bool showAction = false;

    if (status == 'verified') {
      bgColor = AppColors.trustBlue.withOpacity(0.1);
      textColor = AppColors.trustBlue;
      icon = Icons.verified;
      title = 'Identity Verified';
      subtitle = 'You have full access to community features.';
    } else if (status == 'pending') {
      bgColor = Colors.orange.withOpacity(0.1);
      textColor = Colors.orange;
      icon = Icons.pending_actions;
      title = 'Verification Pending';
      subtitle = 'Your documents are currently under review.';
    } else if (status == 'suspended') {
      bgColor = AppColors.emergencyRed.withOpacity(0.1);
      textColor = AppColors.emergencyRed;
      icon = Icons.gavel;
      title = 'Account Suspended';
      subtitle = 'Please contact support for more information.';
    } else {
      // unverified
      bgColor = const Color(0xFF161B22);
      textColor = Colors.white;
      icon = Icons.warning_amber_rounded;
      title = 'Identity Unverified';
      subtitle = 'Verify your identity to unlock all features.';
      showAction = true;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 13)),
              ],
            ),
          ),
          if (showAction) ...[
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const IdentityVerificationScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.trustBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('Verify', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ]
        ],
      ),
    );
  }
}

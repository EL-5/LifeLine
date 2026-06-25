import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/app_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../providers/driver_provider.dart';
import '../../../core/services/supabase_service.dart';

class DriverApplicationScreen extends ConsumerStatefulWidget {
  const DriverApplicationScreen({super.key});

  @override
  ConsumerState<DriverApplicationScreen> createState() => _DriverApplicationScreenState();
}

class _DriverApplicationScreenState extends ConsumerState<DriverApplicationScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Controllers for vehicle info
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _plateController = TextEditingController();

  // Controllers for personal info / license
  final _licenseNumberController = TextEditingController();

  bool _backgroundCheckConsent = false;
  bool _termsAgreed = false;

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _plateController.dispose();
    _licenseNumberController.dispose();
    super.dispose();
  }

  Future<void> _submitApplication() async {
    if (_formKey.currentState!.validate() && _backgroundCheckConsent && _termsAgreed) {
      try {
        final client = ref.read(supabaseServiceProvider).client;
        final userId = client.auth.currentUser?.id;
        if (userId != null) {
          await client.from('drivers').upsert({
            'user_id': userId,
            'vehicle_type': '${_yearController.text} ${_makeController.text} ${_modelController.text}',
            'vehicle_registration': '${_plateController.text} (License: ${_licenseNumberController.text})',
            'verification_status': 'pending',
          });
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to submit application: $e')));
        }
        return;
      }

      ref.read(hasAppliedToDriveProvider.notifier).state = true;
      if (context.mounted) {
        context.go('/user/apply_driver/pending');
      }
    } else if (!_backgroundCheckConsent || !_termsAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to background check and terms.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        colorScheme: const ColorScheme.dark(
          primary: AppColors.trustBlue,
          surface: Color(0xFF161B22),
          onSurface: Colors.white,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Apply to Drive', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
      body: Form(
        key: _formKey,
        child: Stepper(
          type: StepperType.vertical,
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 2) {
              setState(() {
                _currentStep += 1;
              });
            } else {
              _submitApplication();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() {
                _currentStep -= 1;
              });
            } else {
              context.pop();
            }
          },
          controlsBuilder: (context, details) {
            final isLastStep = _currentStep == 2;
            return Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: isLastStep ? 'Submit Application' : 'Continue',
                      onPressed: details.onStepContinue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: details.onStepCancel,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Back'),
                      ),
                    ),
                ],
              ),
            );
          },
          steps: [
            Step(
              title: Text('Vehicle Information', style: AppTextStyles.titleMedium),
              content: Column(
                children: [
                  AppTextField(
                    controller: _makeController,
                    label: 'Vehicle Make (e.g., Toyota)',
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _modelController,
                    label: 'Vehicle Model (e.g., Corolla)',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _yearController,
                          label: 'Year',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AppTextField(
                          controller: _plateController,
                          label: 'License Plate',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: Text('Document Upload', style: AppTextStyles.titleMedium),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    controller: _licenseNumberController,
                    label: 'Driver\'s License Number',
                  ),
                  const SizedBox(height: 24),
                  const Text('Upload Photos (Mock)', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _UploadCard(label: 'Front of License'),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _UploadCard(label: 'Back of License'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _UploadCard(label: 'Vehicle Registration / Insurance'),
                ],
              ),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: Text('Background Check & Consent', style: AppTextStyles.titleMedium),
              content: Column(
                children: [
                  CheckboxListTile(
                    title: const Text('I consent to a background check as required by local transport regulations.'),
                    value: _backgroundCheckConsent,
                    onChanged: (val) {
                      setState(() {
                        _backgroundCheckConsent = val ?? false;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.trustBlue,
                  ),
                  CheckboxListTile(
                    title: const Text('I agree to the Lifeline Mesh Driver Terms of Service and Privacy Policy.'),
                    value: _termsAgreed,
                    onChanged: (val) {
                      setState(() {
                        _termsAgreed = val ?? false;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.trustBlue,
                  ),
                ],
              ),
              isActive: _currentStep >= 2,
            ),
          ],
        ),
      ),
    ),
    );
  }
}

class _UploadCard extends StatelessWidget {
  final String label;

  const _UploadCard({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, style: BorderStyle.solid),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_upload_outlined, color: AppColors.trustBlue),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

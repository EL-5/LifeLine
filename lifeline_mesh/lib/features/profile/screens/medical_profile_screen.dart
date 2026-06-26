import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../providers/medical_profile_provider.dart';

class MedicalProfileScreen extends ConsumerStatefulWidget {
  const MedicalProfileScreen({super.key});

  @override
  ConsumerState<MedicalProfileScreen> createState() => _MedicalProfileScreenState();
}

class _MedicalProfileScreenState extends ConsumerState<MedicalProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String _bloodGroup = '';
  String _genotype = '';
  final _allergiesController = TextEditingController();
  final _conditionsController = TextEditingController();
  final _medicationsController = TextEditingController();
  
  bool _isSaving = false;

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', 'Unknown'];
  final List<String> _genotypes = ['AA', 'AS', 'SS', 'AC', 'SC', 'Unknown'];

  @override
  void initState() {
    super.initState();
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = ref.read(medicalProfileProvider).value;
      if (profile != null) {
        setState(() {
          _bloodGroup = _bloodGroups.contains(profile.bloodGroup) ? profile.bloodGroup : 'Unknown';
          _genotype = _genotypes.contains(profile.genotype) ? profile.genotype : 'Unknown';
          _allergiesController.text = profile.allergies;
          _conditionsController.text = profile.chronicConditions;
          _medicationsController.text = profile.currentMedications;
        });
      }
    });
  }

  @override
  void dispose() {
    _allergiesController.dispose();
    _conditionsController.dispose();
    _medicationsController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    
    try {
      final updateProfile = ref.read(updateMedicalProfileProvider);
      final userId = Supabase.instance.client.auth.currentUser!.id;
      
      final profile = MedicalProfile(
        userId: userId,
        bloodGroup: _bloodGroup == 'Unknown' ? '' : _bloodGroup,
        genotype: _genotype == 'Unknown' ? '' : _genotype,
        allergies: _allergiesController.text.trim(),
        chronicConditions: _conditionsController.text.trim(),
        currentMedications: _medicationsController.text.trim(),
      );

      await updateProfile(profile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medical Profile saved successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e'), backgroundColor: AppColors.emergencyRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(medicalProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Profile'),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
        data: (_) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.trustBlueLight.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.trustBlueLight.withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.health_and_safety, color: AppColors.trustBlue),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Your medical profile is securely shared with emergency responders and the AI Health Specialist during a crisis to provide you with the best care.',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Blood Group & Genotype
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _bloodGroup.isEmpty ? 'Unknown' : _bloodGroup,
                          decoration: const InputDecoration(
                            labelText: 'Blood Group',
                            border: OutlineInputBorder(),
                          ),
                          items: _bloodGroups.map((bg) => DropdownMenuItem(value: bg, child: Text(bg))).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _bloodGroup = val);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _genotype.isEmpty ? 'Unknown' : _genotype,
                          decoration: const InputDecoration(
                            labelText: 'Genotype',
                            border: OutlineInputBorder(),
                          ),
                          items: _genotypes.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _genotype = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Allergies
                  TextFormField(
                    controller: _allergiesController,
                    decoration: const InputDecoration(
                      labelText: 'Allergies',
                      hintText: 'e.g., Penicillin, Peanuts, Latex (or leave blank)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),

                  // Chronic Conditions
                  TextFormField(
                    controller: _conditionsController,
                    decoration: const InputDecoration(
                      labelText: 'Chronic Conditions',
                      hintText: 'e.g., Asthma, Diabetes, Hypertension',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),

                  // Current Medications
                  TextFormField(
                    controller: _medicationsController,
                    decoration: const InputDecoration(
                      labelText: 'Current Medications',
                      hintText: 'e.g., Metformin 500mg, Inhaler',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 48),

                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      label: _isSaving ? 'Saving...' : 'Save Medical Profile',
                      onPressed: _isSaving ? null : _saveProfile,
                      type: ButtonType.primary,
                      icon: Icons.save,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/services/ai_service.dart';
import '../../../providers/medical_profile_provider.dart';

class AiHealthSpecialistScreen extends ConsumerStatefulWidget {
  const AiHealthSpecialistScreen({super.key});

  @override
  ConsumerState<AiHealthSpecialistScreen> createState() => _AiHealthSpecialistScreenState();
}

class _AiHealthSpecialistScreenState extends ConsumerState<AiHealthSpecialistScreen> {
  String? _selectedBloodGroup;
  String? _selectedGenotype;
  final _allergiesController = TextEditingController();
  final _conditionsController = TextEditingController();
  
  String? _wellnessPlan;
  bool _isLoading = false;
  bool _initialized = false;

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final List<String> _genotypes = ['AA', 'AS', 'AC', 'SS', 'SC', 'CC'];

  @override
  void dispose() {

    _allergiesController.dispose();
    _conditionsController.dispose();
    super.dispose();
  }

  void _generatePlan() async {
    if (_selectedBloodGroup == null || _selectedGenotype == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your Blood Group and Genotype.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _wellnessPlan = null;
    });

    final aiService = ref.read(aiServiceProvider);
    final plan = await aiService.getWellnessPlan(
      bloodGroup: _selectedBloodGroup!,
      genotype: _selectedGenotype!,
      allergies: _allergiesController.text.trim(),
      conditions: _conditionsController.text.trim(),
    );

    if (mounted) {
      setState(() {
        _wellnessPlan = plan;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(medicalProfileProvider);

    if (!_initialized && profileAsync.hasValue && profileAsync.value != null) {
      final p = profileAsync.value!;
      if (p.bloodGroup.isNotEmpty && _bloodGroups.contains(p.bloodGroup)) {
        _selectedBloodGroup = p.bloodGroup;
      }
      if (p.genotype.isNotEmpty && _genotypes.contains(p.genotype)) {
        _selectedGenotype = p.genotype;
      }
      _allergiesController.text = p.allergies;
      _conditionsController.text = p.chronicConditions;
      // Use Future.microtask or post frame callback if setState is needed, but we can just set them before build returns.
      _initialized = true;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.health_and_safety_rounded, color: AppColors.successGreen),
            SizedBox(width: 8),
            Text('AI Health Specialist', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: const Color(0xFF161B22).withOpacity(0.8)),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1117), Color(0xFF090C10)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Text(
                  'Your Biological Profile',
                  style: AppTextStyles.titleLarge,
                ).animate().fadeIn().slideX(),
                const SizedBox(height: 8),
                Text(
                  'Enter your details for a personalized preventative wellness plan.',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                ).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 24),
                
                // Form Fields
                _buildGlassCard(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildDropdown('Blood Group', _bloodGroups, _selectedBloodGroup, (v) => setState(() => _selectedBloodGroup = v))),
                          const SizedBox(width: 16),
                          Expanded(child: _buildDropdown('Genotype', _genotypes, _selectedGenotype, (v) => setState(() => _selectedGenotype = v))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(_allergiesController, 'Allergies (Optional)'),
                      const SizedBox(height: 16),
                      _buildTextField(_conditionsController, 'Chronic Conditions (Optional)'),
                    ],
                  ),
                ).animate().scale(delay: 200.ms, curve: Curves.easeOutBack),
                
                const SizedBox(height: 32),
                
                // Generate Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _generatePlan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.trustBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 8,
                    shadowColor: AppColors.trustBlue.withOpacity(0.5),
                  ),
                  child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Analyze My Health', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ).animate(target: _isLoading ? 0 : 1).shimmer(duration: 2000.ms),
                
                const SizedBox(height: 32),
                
                // Wellness Plan Result
                if (_wellnessPlan != null)
                  _buildGlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.auto_awesome, color: AppColors.trustBlue),
                            const SizedBox(width: 8),
                            Text('Your Wellness Plan', style: AppTextStyles.titleLarge),
                          ],
                        ),
                        const Divider(color: Colors.white10, height: 32),
                        MarkdownBody(
                          data: _wellnessPlan!,
                          styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                            p: const TextStyle(color: Colors.white, fontSize: 15, height: 1.6),
                            h1: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            h2: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            h3: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            listBullet: const TextStyle(color: AppColors.trustBlue),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white30),
        filled: true,
        fillColor: const Color(0xFF0D1117).withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22).withOpacity(0.6),
            border: Border.all(color: Colors.white10),
            borderRadius: BorderRadius.circular(20),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildDropdown(String hint, List<String> items, String? value, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: value,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      dropdownColor: const Color(0xFF161B22),
      style: const TextStyle(color: Colors.white, fontSize: 15),
      icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white30),
        filled: true,
        fillColor: const Color(0xFF0D1117).withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

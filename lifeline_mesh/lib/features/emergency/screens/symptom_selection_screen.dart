import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/constants/api_constants.dart';

class SymptomSelectionScreen extends ConsumerStatefulWidget {
  const SymptomSelectionScreen({super.key});

  @override
  ConsumerState<SymptomSelectionScreen> createState() =>
      _SymptomSelectionScreenState();
}

class _SymptomSelectionScreenState
    extends ConsumerState<SymptomSelectionScreen> {
  String? _selectedCategory;
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;
  
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  // Maps display name → DB enum value
  static const Map<String, String> _categoryDbMap = {
    'Accident': 'accident',
    'Stroke': 'stroke',
    'Breathing Difficulty': 'breathing_difficulty',
    'Pregnancy Emergency': 'pregnancy_emergency',
    'Child Emergency': 'child_emergency',
    'Chest Pain': 'chest_pain',
    'Violence/Injury': 'violence_injury',
    'Unknown Emergency': 'unknown',
  };

  final _categories = [
    _SymptomCategory('Accident', Icons.car_crash, AppColors.severityCritical),
    _SymptomCategory('Stroke', Icons.psychology, AppColors.severitySerious),
    _SymptomCategory(
        'Breathing Difficulty', Icons.air, AppColors.severityCritical),
    _SymptomCategory(
        'Pregnancy Emergency', Icons.child_care, AppColors.severitySerious),
    _SymptomCategory(
        'Child Emergency', Icons.child_friendly, AppColors.warningAmber),
    _SymptomCategory(
        'Chest Pain', Icons.favorite_border, AppColors.severityCritical),
    _SymptomCategory(
        'Violence/Injury', Icons.local_police, AppColors.severitySerious),
    _SymptomCategory(
        'Unknown Emergency', Icons.help_outline, AppColors.statusPending),
  ];

  @override
  void dispose() {
    _speech.cancel();
    _descriptionController.dispose();
    super.dispose();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'done') setState(() => _isListening = false);
        },
        onError: (val) => setState(() => _isListening = false),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _descriptionController.text = val.recognizedWords;
          }),
        );
      } else {
        _showError('Speech recognition not available on this device.');
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _submit() async {
    if (_selectedCategory == null || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final extra =
          GoRouterState.of(context).extra as Map<String, dynamic>? ?? {};
      final location = extra['location'] as Map<String, dynamic>?;
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;

      if (userId == null) {
        _showError('You must be logged in to trigger an emergency.');
        return;
      }

      final categoryDb =
          _categoryDbMap[_selectedCategory!] ?? 'unknown';
      final description = _descriptionController.text.trim();

      // Invoke the create-emergency edge function
      final response = await client.functions.invoke(
        ApiConstants.fnCreateEmergency,
        body: {
          'patient_id': userId,
          'category': categoryDb,
          'symptoms': description.isNotEmpty
              ? description.split(',').map((s) => s.trim()).toList()
              : <String>[],
          'location': location ??
              {'lat': 5.6037, 'lng': -0.1870, 'address': 'Accra, Ghana'},
          'description': description,
        },
      );

      if (response.status != 200) {
        _showError('Failed to create emergency. Please try again.');
        return;
      }

      final data = response.data as Map<String, dynamic>?;
      if (data == null || data['success'] != true) {
        _showError(data?['error'] ?? 'Unknown error. Please try again.');
        return;
      }

      final emergencyId = data['emergency']['id'] as String;

      if (mounted) {
        context.pushReplacement('/patient/track/$emergencyId');
      }
    } catch (e) {
      _showError('Network error. Please check your connection and try again.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.emergencyRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Describe Emergency')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What type of emergency?',
                  style: AppTextStyles.titleLarge,
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = _selectedCategory == cat.name;
                    return GestureDetector(
                      onTap: _isSubmitting
                          ? null
                          : () => setState(() => _selectedCategory = cat.name),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? cat.color.withValues(alpha: 0.15)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? cat.color : AppColors.divider,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: cat.color.withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : [],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(cat.icon, color: cat.color, size: 32),
                            const SizedBox(height: 8),
                            Text(
                              cat.name,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  enabled: !_isSubmitting,
                  decoration: InputDecoration(
                    hintText: 'Describe what happened (optional)',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        color: _isListening ? AppColors.emergencyRed : AppColors.textSecondary,
                        size: 32,
                      ),
                      onPressed: _isSubmitting ? null : _listen,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: _isSubmitting
                      ? 'Sending Alert...'
                      : 'Send Emergency Alert',
                  onPressed:
                      (_selectedCategory != null && !_isSubmitting) ? _submit : null,
                  disabled: _selectedCategory == null || _isSubmitting,
                  type: ButtonType.emergency,
                  icon: _isSubmitting ? null : Icons.warning,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
          // Full-screen loading overlay while submitting
          if (_isSubmitting)
            Container(
              color: Colors.black.withValues(alpha: 0.4),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.emergencyRed),
                    SizedBox(height: 16),
                    Text(
                      'Dispatching help...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SymptomCategory {
  final String name;
  final IconData icon;
  final Color color;

  const _SymptomCategory(this.name, this.icon, this.color);
}
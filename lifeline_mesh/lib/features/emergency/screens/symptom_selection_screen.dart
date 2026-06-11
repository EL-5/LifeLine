import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/app_button.dart';

class SymptomSelectionScreen extends StatefulWidget {
  const SymptomSelectionScreen({super.key});

  @override
  State<SymptomSelectionScreen> createState() => _SymptomSelectionScreenState();
}

class _SymptomSelectionScreenState extends State<SymptomSelectionScreen> {
  String? _selectedCategory;
  final _descriptionController = TextEditingController();

  final _categories = [
    _SymptomCategory('Accident', Icons.car_crash, AppColors.severityCritical),
    _SymptomCategory('Stroke', Icons.psychology, AppColors.severitySerious),
    _SymptomCategory('Breathing Difficulty', Icons.air, AppColors.severityCritical),
    _SymptomCategory('Pregnancy Emergency', Icons.child_care, AppColors.severitySerious),
    _SymptomCategory('Child Emergency', Icons.child_friendly, AppColors.warningAmber),
    _SymptomCategory('Chest Pain', Icons.favorite_border, AppColors.severityCritical),
    _SymptomCategory('Violence/Injury', Icons.local_police, AppColors.severitySerious),
    _SymptomCategory('Unknown Emergency', Icons.help_outline, AppColors.statusPending),
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_selectedCategory == null) return;

    final extra = GoRouterState.of(context).extra as Map<String, dynamic>? ?? {};
    extra['category'] = _selectedCategory;
    extra['description'] = _descriptionController.text;

    // TODO: Call create emergency edge function
    // For now, navigate to tracking
    context.push('/patient/track/mock-emergency-id');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Describe Emergency')),
      body: SingleChildScrollView(
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
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                  onTap: () => setState(() => _selectedCategory = cat.name),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? cat.color.withValues(alpha: 0.15)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? cat.color : AppColors.divider,
                        width: isSelected ? 2 : 1,
                      ),
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
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
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
              decoration: InputDecoration(
                hintText: 'Describe what happened (optional)',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Send Emergency Alert',
              onPressed: _selectedCategory != null ? _submit : null,
              disabled: _selectedCategory == null,
              type: ButtonType.emergency,
              icon: Icons.warning,
            ),
          ],
        ),
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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../providers/settings_provider.dart';

class LanguageScreen extends ConsumerStatefulWidget {
  const LanguageScreen({super.key});

  @override
  ConsumerState<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends ConsumerState<LanguageScreen> {
  String? _selectedLanguage;

  final List<Map<String, String>> _languages = [
    {'name': 'English', 'locale': 'en'},
    {'name': 'French', 'locale': 'fr'},
    {'name': 'Spanish', 'locale': 'es'},
    {'name': 'Swahili', 'locale': 'sw'},
    {'name': 'Arabic', 'locale': 'ar'},
  ];

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Language')),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (settings) {
          final currentLang = _selectedLanguage ?? settings.language;
          
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: _languages.length,
            itemBuilder: (context, index) {
              final lang = _languages[index]['name']!;
              final isSelected = lang == currentLang;

              return ListTile(
                title: Text(lang),
                trailing: isSelected ? const Icon(Icons.check, color: AppColors.trustBlue) : null,
                onTap: () async {
                  setState(() => _selectedLanguage = lang);
                  
                  try {
                    final updateSettings = ref.read(updateSettingsProvider);
                    await updateSettings(settings.copyWith(language: lang));
                    
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Language changed to $lang')),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error saving language: $e')),
                      );
                    }
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

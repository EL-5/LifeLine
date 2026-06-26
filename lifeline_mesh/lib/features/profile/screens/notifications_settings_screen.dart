import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../providers/settings_provider.dart';

class NotificationsSettingsScreen extends ConsumerStatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  ConsumerState<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends ConsumerState<NotificationsSettingsScreen> {
  bool? _pushEnabled;
  bool? _smsEnabled;
  bool? _emailEnabled;
  bool? _marketingEnabled;

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (settings) {
          final pushEnabled = _pushEnabled ?? settings.pushEnabled;
          final smsEnabled = _smsEnabled ?? settings.smsEnabled;
          final emailEnabled = _emailEnabled ?? settings.emailEnabled;
          final marketingEnabled = _marketingEnabled ?? settings.marketingEnabled;

          Future<void> saveSettings(UserSettings updatedSettings) async {
            try {
              final update = ref.read(updateSettingsProvider);
              await update(updatedSettings);
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error saving settings: $e')),
                );
              }
            }
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Emergency Alerts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.trustBlue)),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Push Notifications'),
                subtitle: const Text('Receive immediate alerts on this device'),
                value: pushEnabled,
                activeColor: AppColors.trustBlue,
                onChanged: (val) {
                  setState(() => _pushEnabled = val);
                  saveSettings(settings.copyWith(pushEnabled: val));
                },
              ),
              SwitchListTile(
                title: const Text('SMS Alerts'),
                subtitle: const Text('Receive text messages via Moolre SMS'),
                value: smsEnabled,
                activeColor: AppColors.trustBlue,
                onChanged: (val) {
                  setState(() => _smsEnabled = val);
                  saveSettings(settings.copyWith(smsEnabled: val));
                },
              ),
              const Divider(height: 32),
              
              const Text('General Updates', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.trustBlue)),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Email Notifications'),
                subtitle: const Text('Community updates and newsletters'),
                value: emailEnabled,
                activeColor: AppColors.trustBlue,
                onChanged: (val) {
                  setState(() => _emailEnabled = val);
                  saveSettings(settings.copyWith(emailEnabled: val));
                },
              ),
              SwitchListTile(
                title: const Text('Promotions'),
                subtitle: const Text('Special offers from partners'),
                value: marketingEnabled,
                activeColor: AppColors.trustBlue,
                onChanged: (val) {
                  setState(() => _marketingEnabled = val);
                  saveSettings(settings.copyWith(marketingEnabled: val));
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

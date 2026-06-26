import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact Support Card
            Card(
              color: const Color(0xFF161B22),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Icon(Icons.support_agent, size: 64, color: AppColors.trustBlue),
                    const SizedBox(height: 16),
                    const Text(
                      'How can we help you?',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Our support team is available 24/7 for emergency dispatch issues.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Starting Live Chat...')));
                            },
                            icon: const Icon(Icons.chat),
                            label: const Text('Live Chat'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.trustBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dialing Support...')));
                            },
                            icon: const Icon(Icons.phone),
                            label: const Text('Call Us'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white30),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16),
            
            // FAQs
            _buildFaqTile(
              'How does the SOS button work?',
              'Holding the SOS button for 3 seconds instantly triggers an emergency dispatch. It alerts nearby drivers, hospitals, and your designated family contacts with your live GPS location.',
            ),
            _buildFaqTile(
              'What happens if I lose internet connection?',
              'Lifeline Mesh uses a decentralized Bluetooth and Wi-Fi Direct mesh network. Even without mobile data, your emergency signal will hop across nearby Lifeline users until it reaches someone with internet access to contact dispatch.',
            ),
            _buildFaqTile(
              'Can the AI Health Specialist diagnose me?',
              'No. The AI provides preventative care plans and immediate triage first-aid steps to stabilize a situation. It is not a replacement for professional medical diagnosis.',
            ),
            _buildFaqTile(
              'How do I add my family members?',
              'Go to the Dashboard and tap on "Family Circle". From there, you can invite family members using their phone numbers. They will receive SMS alerts when you trigger an SOS.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqTile(String question, String answer) {
    return Card(
      color: const Color(0xFF161B22),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: AppColors.trustBlue,
          collapsedIconColor: Colors.white54,
          title: Text(question, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Text(
                answer,
                style: const TextStyle(color: Colors.white70, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

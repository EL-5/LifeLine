import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wallet')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Balance Card
            Card(
              color: AppColors.trustBlue,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      'Available Balance',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'GHS 0.00',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.add),
                            label: const Text('Top Up'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white30),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => context.push('/wallet/transactions'),
                            icon: const Icon(Icons.history),
                            label: const Text('History'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white30),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quick Stats
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(Icons.favorite,
                              color: AppColors.emergencyRed, size: 28),
                          const SizedBox(height: 8),
                          const Text('GHS 0',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                          Text('Total Contributed',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(Icons.favorite, color: AppColors.successGreen, size: 28),
                          const SizedBox(height: 8),
                          const Text('0',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                          Text('Campaigns Supported',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            // Payment Methods
            Card(
              child: ListTile(
                title: const Text('Payment Methods'),
                subtitle: const Text('Mobile Money, Card, Wallet'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
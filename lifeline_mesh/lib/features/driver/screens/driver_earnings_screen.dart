import 'package:flutter/material.dart';
import '../../../core/widgets/empty_state.dart';

class DriverEarningsScreen extends StatelessWidget {
  const DriverEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Earnings')),
      body: EmptyState(
        icon: Icons.account_balance_wallet,
        title: 'No Earnings Yet',
        subtitle: 'Complete emergency transports to start earning',
      ),
    );
  }
}
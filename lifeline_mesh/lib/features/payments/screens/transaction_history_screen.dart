import 'package:flutter/material.dart';
import '../../../core/widgets/empty_state.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction History')),
      body: const EmptyState(
        icon: Icons.receipt_long,
        title: 'No Transactions',
        subtitle: 'Your payment history will appear here',
      ),
    );
  }
}
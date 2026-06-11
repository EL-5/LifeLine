import 'package:flutter/material.dart';
import '../../../core/widgets/empty_state.dart';

class AuditLogScreen extends StatelessWidget {
  const AuditLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audit Logs')),
      body: const EmptyState(
        icon: Icons.receipt_long,
        title: 'No Audit Logs',
        subtitle: 'System activity will be logged here',
      ),
    );
  }
}
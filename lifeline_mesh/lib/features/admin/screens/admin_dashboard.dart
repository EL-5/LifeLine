import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../providers/admin_provider.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(adminStatsProvider),
          ),
        ],
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading stats: $e')),
        data: (stats) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // KPI Cards Row 1
              Row(
                children: [
                  Expanded(
                    child: _KpiCard(
                      title: 'Active Emergencies',
                      value: stats.activeEmergencies.toString(),
                      icon: Icons.emergency,
                      color: AppColors.emergencyRed,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _KpiCard(
                      title: 'Avg Response',
                      value: '${stats.avgResponseTimeMinutes.toStringAsFixed(1)} min',
                      icon: Icons.timer,
                      color: AppColors.warningAmber,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // KPI Cards Row 2
              Row(
                children: [
                  Expanded(
                    child: _KpiCard(
                      title: 'Total Users',
                      value: stats.totalUsers.toString(),
                      icon: Icons.people,
                      color: AppColors.trustBlue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _KpiCard(
                      title: 'Funds Raised',
                      value: 'GHS ${(stats.totalFundsRaised / 1000).toStringAsFixed(1)}K',
                      icon: Icons.monetization_on,
                      color: AppColors.successGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // KPI Cards Row 3
              Row(
                children: [
                  Expanded(
                    child: _KpiCard(
                      title: 'Last 24h',
                      value: stats.emergenciesLast24h.toString(),
                      icon: Icons.access_time,
                      color: AppColors.warningAmber,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _KpiCard(
                      title: 'Flagged',
                      value: stats.flaggedCount.toString(),
                      icon: Icons.flag,
                      color: stats.flaggedCount > 0
                          ? AppColors.emergencyRed
                          : AppColors.successGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Quick Actions
              Text('Quick Actions', style: AppTextStyles.titleLarge),
              const SizedBox(height: 12),
              _ActionCard(
                icon: Icons.analytics,
                title: 'Analytics',
                subtitle: 'View response times, heatmaps, trends',
                onTap: () => context.push('/admin/analytics'),
              ),
              _ActionCard(
                icon: Icons.people,
                title: 'User Management',
                subtitle: 'Manage ${stats.totalUsers} users, roles, and permissions',
                onTap: () => context.push('/admin/users'),
              ),
              _ActionCard(
                icon: Icons.warning_amber,
                title: 'Fraud Monitoring',
                subtitle: stats.flaggedCount > 0
                    ? '${stats.flaggedCount} emergencies need review'
                    : 'No flags — system is clean',
                onTap: () => context.push('/admin/fraud'),
              ),
              _ActionCard(
                icon: Icons.receipt_long,
                title: 'Audit Logs',
                subtitle: 'View system-wide activity',
                onTap: () => context.push('/admin/audit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(value,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  color: color,
                )),
            const SizedBox(height: 4),
            Text(title,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                )),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.trustBlue),
        title: Text(title),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
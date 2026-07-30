import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../../shared/widgets/omni_glass_container.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_state.dart';

class ProductHealthView extends StatelessWidget {
  const ProductHealthView({super.key});

  Widget _buildKpiCard(BuildContext context, String title, String value, String subtitle, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Expanded(
      child: OmniGlassContainer(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Icon(icon, color: colorScheme.primary, size: 24),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(BuildContext context, String title, Map<String, int> itemsByType) {
    return OmniGlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 60,
                sections: [
                  PieChartSectionData(
                    color: Colors.blue,
                    value: (itemsByType['text'] ?? 0).toDouble(),
                    title: 'Text',
                    radius: 30,
                    titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  PieChartSectionData(
                    color: Colors.red,
                    value: (itemsByType['metadata'] ?? 0).toDouble(),
                    title: 'Metadata',
                    radius: 30,
                    titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  PieChartSectionData(
                    color: Colors.green,
                    value: (itemsByType['file'] ?? 0).toDouble(),
                    title: 'Files',
                    radius: 30,
                    titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBarChart(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;
    return OmniGlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(enabled: false),
                titlesData: const FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false), // Needs proper mapping in real app
                  ),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 8, color: colorScheme.primary)]),
                  BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 10, color: colorScheme.primary)]),
                  BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 14, color: colorScheme.primary)]),
                  BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 15, color: colorScheme.primary)]),
                  BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 13, color: colorScheme.primary)]),
                  BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 10, color: colorScheme.primary)]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        if (state is AdminLoading || state is AdminInitial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AdminError) {
          return Center(child: Text("Error: ${state.message}"));
        }
        
        if (state is AdminLoaded) {
          final isMobile = MediaQuery.of(context).size.width < 600;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Product Health & Engagement',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                if (isMobile) ...[
                  _buildKpiCard(context, 'Daily Active Users', state.metrics.dailyActiveUsers.toString(), 'Current', Icons.people_alt),
                  const SizedBox(height: 16),
                  _buildKpiCard(context, 'Devices per User', state.metrics.devicesPerUser.toStringAsFixed(1), 'Healthy (> 2.0)', Icons.devices_other),
                  const SizedBox(height: 16),
                  _buildKpiCard(context, 'Total Users', state.metrics.totalUsers.toString(), 'Registered', Icons.sync_alt),
                ] else
                  Row(
                    children: [
                      _buildKpiCard(context, 'Daily Active Users', state.metrics.dailyActiveUsers.toString(), 'Current', Icons.people_alt),
                      const SizedBox(width: 16),
                      _buildKpiCard(context, 'Devices per User', state.metrics.devicesPerUser.toStringAsFixed(1), 'Healthy (> 2.0)', Icons.devices_other),
                      const SizedBox(width: 16),
                      _buildKpiCard(context, 'Total Users', state.metrics.totalUsers.toString(), 'Registered', Icons.sync_alt),
                    ],
                  ),
                const SizedBox(height: 32),
                if (isMobile) ...[
                  _buildPieChart(context, 'Items Transferred by Type', state.metrics.itemsByType),
                  const SizedBox(height: 24),
                  _buildBarChart(context, 'Action Rate per Card (Copy, Open, etc)'),
                ] else
                  Row(
                    children: [
                      Expanded(child: _buildPieChart(context, 'Items Transferred by Type', state.metrics.itemsByType)),
                      const SizedBox(width: 24),
                      Expanded(child: _buildBarChart(context, 'Action Rate per Card (Copy, Open, etc)')),
                    ],
                  ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

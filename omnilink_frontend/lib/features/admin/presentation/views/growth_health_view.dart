import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../../shared/widgets/omni_glass_container.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_state.dart';

class GrowthHealthView extends StatelessWidget {
  const GrowthHealthView({super.key});

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

  Widget _buildLineChart(BuildContext context, String title) {
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
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true, drawVerticalLine: false),
                titlesData: const FlTitlesData(
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 100),
                      FlSpot(1, 90),
                      FlSpot(2, 85),
                      FlSpot(3, 80),
                      FlSpot(4, 75),
                      FlSpot(5, 74),
                      FlSpot(6, 73),
                    ],
                    isCurved: true,
                    color: colorScheme.primary,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: colorScheme.primary.withValues(alpha: 0.1),
                    ),
                  ),
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
                  'Growth & Financial Health',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                if (isMobile) ...[
                  _buildKpiCard(context, 'New Users Today', state.metrics.newUsersToday.toString(), 'Today', Icons.person_add),
                  const SizedBox(height: 16),
                  _buildKpiCard(context, 'Retention Rate (D30)', '73%', 'Simulated', Icons.favorite),
                  const SizedBox(height: 16),
                  _buildKpiCard(context, 'Total Items Synced', state.metrics.totalItems.toString(), 'Overall', Icons.data_usage),
                ] else
                  Row(
                    children: [
                      _buildKpiCard(context, 'New Users Today', state.metrics.newUsersToday.toString(), 'Today', Icons.person_add),
                      const SizedBox(width: 16),
                      _buildKpiCard(context, 'Retention Rate (D30)', '73%', 'Simulated', Icons.favorite),
                      const SizedBox(width: 16),
                      _buildKpiCard(context, 'Total Items Synced', state.metrics.totalItems.toString(), 'Overall', Icons.data_usage),
                    ],
                  ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(child: _buildLineChart(context, 'Cohort Retention Curve')),
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

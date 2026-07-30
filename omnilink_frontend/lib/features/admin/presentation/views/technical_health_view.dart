import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../../shared/widgets/omni_glass_container.dart';

class TechnicalHealthView extends StatelessWidget {
  const TechnicalHealthView({super.key});

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
                      FlSpot(0, 30),
                      FlSpot(1, 45),
                      FlSpot(2, 35),
                      FlSpot(3, 80),
                      FlSpot(4, 55),
                      FlSpot(5, 70),
                      FlSpot(6, 60),
                    ],
                    isCurved: true,
                    color: colorScheme.primary,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Technical Health',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildKpiCard(context, 'Sync Latency', '45 ms', '↓ 12% from last week', Icons.speed),
              const SizedBox(width: 16),
              _buildKpiCard(context, 'Active SSE Connections', '1,402', '↑ 5% from last week', Icons.wifi_tethering),
              const SizedBox(width: 16),
              _buildKpiCard(context, 'DB Pool Saturation', '24%', 'Stable', Icons.storage),
              const SizedBox(width: 16),
              _buildKpiCard(context, 'API Error Rate', '0.01%', 'Target: < 0.1%', Icons.error_outline),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(child: _buildLineChart(context, 'Redis Pub/Sub Throughput (msg/min)')),
              const SizedBox(width: 24),
              Expanded(child: _buildLineChart(context, 'Metadata Processing Latency (ms)')),
            ],
          ),
        ],
      ),
    );
  }
}

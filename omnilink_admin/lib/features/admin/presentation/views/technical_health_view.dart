import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_state.dart';

class TechnicalHealthView extends StatelessWidget {
  const TechnicalHealthView({super.key});

  Widget _buildKpiCard(BuildContext context, String title, String value, String subtitle, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
        ),
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(icon, color: colorScheme.primary, size: 24),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.greenAccent,
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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
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
                      color: colorScheme.primary.withOpacity(0.1),
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
                  'System Health',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Real-time metrics for backend performance.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 32),
                if (isMobile) ...[
                  Row(children: [_buildKpiCard(context, 'Sync Latency', '${state.metrics.syncLatencyMs} ms', 'Simulated', Icons.speed)]),
                  const SizedBox(height: 16),
                  Row(children: [_buildKpiCard(context, 'Active SSE Connections', '${state.metrics.activeSseConnections}', 'Approximate', Icons.wifi_tethering)]),
                  const SizedBox(height: 16),
                  Row(children: [_buildKpiCard(context, 'DB Pool Saturation', '${state.metrics.dbPoolSaturationPercent}%', 'Simulated', Icons.storage)]),
                  const SizedBox(height: 16),
                  Row(children: [_buildKpiCard(context, 'API Error Rate', '${state.metrics.apiErrorRatePercent}%', 'Simulated', Icons.error_outline)]),
                ] else
                  Row(
                    children: [
                      _buildKpiCard(context, 'Sync Latency', '${state.metrics.syncLatencyMs} ms', 'Simulated', Icons.speed),
                      const SizedBox(width: 16),
                      _buildKpiCard(context, 'Active SSE Connections', '${state.metrics.activeSseConnections}', 'Multiplexed', Icons.wifi_tethering),
                      const SizedBox(width: 16),
                      _buildKpiCard(context, 'DB Pool Saturation', '${state.metrics.dbPoolSaturationPercent}%', 'Healthy', Icons.storage),
                      const SizedBox(width: 16),
                      _buildKpiCard(context, 'Redis Usage', '1', 'Connections', Icons.dns),
                    ],
                  ),
                const SizedBox(height: 32),
                if (isMobile) ...[
                  _buildLineChart(context, 'Redis Pub/Sub Throughput (msg/min)'),
                  const SizedBox(height: 24),
                  _buildLineChart(context, 'API Request Latency (ms)'),
                ] else
                  Row(
                    children: [
                      Expanded(child: _buildLineChart(context, 'Redis Pub/Sub Throughput (msg/min)')),
                      const SizedBox(width: 24),
                      Expanded(child: _buildLineChart(context, 'API Request Latency (ms)')),
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

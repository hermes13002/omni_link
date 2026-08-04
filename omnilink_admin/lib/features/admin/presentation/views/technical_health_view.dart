import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_state.dart';

class TechnicalHealthView extends StatelessWidget {
  const TechnicalHealthView({super.key});

  Widget _buildKpiCard(BuildContext context, String title, String value, String subtitle, IconData icon, {bool isDummy = false}) {
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
            if (isDummy)
              ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Text('999', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
              )
            else
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

  Widget _buildLineChart(BuildContext context, String title, String xTitle, String yTitle, double yInterval, {bool isDummy = false}) {
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
          Builder(
            builder: (context) {
              final chartWidget = SizedBox(
                height: 250,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: colorScheme.outlineVariant.withOpacity(0.5),
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        axisNameWidget: Text(xTitle),
                        axisNameSize: 22,
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (value, meta) => Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text('${value.toInt()}m', style: const TextStyle(fontSize: 10)),
                          ),
                        ),
                      ),
                      leftTitles: AxisTitles(
                        axisNameWidget: Text(yTitle),
                        axisNameSize: 22,
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: yInterval,
                          getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: const TextStyle(fontSize: 10)),
                        ),
                      ),
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
                          color: colorScheme.primary.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              );
              
              return isDummy 
                  ? ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: chartWidget,
                    )
                  : chartWidget;
            },
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
          final isMobile = MediaQuery.of(context).size.width < 800;
          return SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16 : 32),
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
                  Row(children: [_buildKpiCard(context, 'Sync Latency', '${state.metrics.syncLatencyMs} ms', 'Simulated', Icons.speed, isDummy: true)]),
                  const SizedBox(height: 16),
                  Row(children: [_buildKpiCard(context, 'Active SSE Connections', '${state.metrics.activeSseConnections}', 'Multiplexed', Icons.wifi_tethering)]),
                  const SizedBox(height: 16),
                  Row(children: [_buildKpiCard(context, 'DB Pool Saturation', '${state.metrics.dbPoolSaturationPercent}%', 'Simulated', Icons.storage, isDummy: true)]),
                  const SizedBox(height: 16),
                  Row(children: [_buildKpiCard(context, 'API Error Rate', '${state.metrics.apiErrorRatePercent}%', 'Simulated', Icons.error_outline, isDummy: true)]),
                ] else
                  Row(
                    children: [
                      _buildKpiCard(context, 'Sync Latency', '${state.metrics.syncLatencyMs} ms', 'Simulated', Icons.speed, isDummy: true),
                      const SizedBox(width: 16),
                      _buildKpiCard(context, 'Active SSE Connections', '${state.metrics.activeSseConnections}', 'Multiplexed', Icons.wifi_tethering),
                      const SizedBox(width: 16),
                      _buildKpiCard(context, 'DB Pool Saturation', '${state.metrics.dbPoolSaturationPercent}%', 'Healthy', Icons.storage, isDummy: true),
                      const SizedBox(width: 16),
                      _buildKpiCard(context, 'Redis Usage', '1', 'Connections', Icons.dns, isDummy: true),
                    ],
                  ),
                const SizedBox(height: 32),
                if (isMobile) ...[
                  _buildLineChart(context, 'Redis Pub/Sub Throughput', 'Time (mins ago)', 'Messages', 20, isDummy: true),
                  const SizedBox(height: 24),
                  _buildLineChart(context, 'API Request Latency', 'Time (mins ago)', 'ms', 20, isDummy: true),
                ] else
                  Row(
                    children: [
                      Expanded(child: _buildLineChart(context, 'Redis Pub/Sub Throughput', 'Time (mins ago)', 'Messages', 20, isDummy: true)),
                      const SizedBox(width: 24),
                      Expanded(child: _buildLineChart(context, 'API Request Latency', 'Time (mins ago)', 'ms', 20, isDummy: true)),
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

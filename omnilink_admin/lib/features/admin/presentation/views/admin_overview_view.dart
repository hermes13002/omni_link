import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:omnilink_admin/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:omnilink_admin/features/admin/presentation/bloc/admin_state.dart';

class AdminOverviewView extends StatelessWidget {
  const AdminOverviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        if (state is AdminLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is AdminError) {
          return Center(child: Text(state.message, style: TextStyle(color: theme.colorScheme.error)));
        } else if (state is AdminLoaded) {
          final metrics = state.metrics;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Command Center', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Overview of OmniLink system health and growth.', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 32),
                
                // Top Row: Metrics
                Row(
                  children: [
                    Expanded(child: _MetricCard(title: 'TOTAL USERS', value: metrics.totalUsers.toString(), icon: Icons.people, trend: '+12%')),
                    const SizedBox(width: 16),
                    Expanded(child: _MetricCard(title: 'ACTIVE CARDS', value: metrics.totalItems.toString(), icon: Icons.dashboard, trend: '+5%')),
                    const SizedBox(width: 16),
                    Expanded(child: _MetricCard(title: 'API REQUESTS', value: '1.2M', icon: Icons.api, trend: '+18%', isDummy: true)),
                    const SizedBox(width: 16),
                    Expanded(child: _MetricCard(title: 'SYSTEM STATUS', value: 'Healthy', icon: Icons.check_circle, isHealthy: true, isDummy: true)),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Charts Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _ChartCard(
                        title: 'User Growth (7 Days)',
                        isDummy: true,
                        child: SizedBox(
                          height: 250,
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                getDrawingHorizontalLine: (value) => FlLine(
                                  color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                                  strokeWidth: 1,
                                ),
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(
                                  axisNameWidget: const Text('Days Ago'),
                                  axisNameSize: 22,
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: 1,
                                    getTitlesWidget: (value, meta) {
                                      final days = ['6d', '5d', '4d', '3d', '2d', '1d', 'Today'];
                                      if (value.toInt() >= 0 && value.toInt() < days.length) {
                                        return Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(days[value.toInt()], style: const TextStyle(fontSize: 10)));
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  axisNameWidget: const Text('Users'),
                                  axisNameSize: 22,
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 30,
                                    interval: 2,
                                    getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: const TextStyle(fontSize: 10)),
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: const [
                                    FlSpot(0, 3),
                                    FlSpot(1, 4),
                                    FlSpot(2, 3.5),
                                    FlSpot(3, 5),
                                    FlSpot(4, 4.8),
                                    FlSpot(5, 6),
                                    FlSpot(6, 8),
                                  ],
                                  isCurved: true,
                                  color: theme.colorScheme.primary,
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                  dotData: const FlDotData(show: false),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: theme.colorScheme.primary.withOpacity(0.1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 1,
                      child: _ChartCard(
                        title: 'Server Load',
                        isDummy: true,
                        child: SizedBox(
                          height: 250,
                          child: BarChart(
                            BarChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                getDrawingHorizontalLine: (value) => FlLine(
                                  color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                                  strokeWidth: 1,
                                ),
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(
                                  axisNameWidget: const Text('Instance'),
                                  axisNameSize: 22,
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: 1,
                                    getTitlesWidget: (value, meta) => Padding(padding: const EdgeInsets.only(top: 8.0), child: Text('Node ${value.toInt()}', style: const TextStyle(fontSize: 10))),
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  axisNameWidget: const Text('Load (%)'),
                                  axisNameSize: 22,
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 30,
                                    interval: 5,
                                    getTitlesWidget: (value, meta) => Text('${value.toInt()}%', style: const TextStyle(fontSize: 10)),
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              barGroups: [
                                BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 8, color: theme.colorScheme.primary, width: 16, borderRadius: BorderRadius.circular(4))]),
                                BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 10, color: theme.colorScheme.primary, width: 16, borderRadius: BorderRadius.circular(4))]),
                                BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 14, color: theme.colorScheme.primary, width: 16, borderRadius: BorderRadius.circular(4))]),
                                BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 15, color: theme.colorScheme.primary, width: 16, borderRadius: BorderRadius.circular(4))]),
                                BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 13, color: theme.colorScheme.primary, width: 16, borderRadius: BorderRadius.circular(4))]),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
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

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final String? trend;
  final bool? isHealthy;
  final bool isDummy;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    this.trend,
    this.isHealthy,
    this.isDummy = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isDummy)
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('999', style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800)),
                ],
              ),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isHealthy == true ? Colors.green : colorScheme.onSurface,
                  ),
                ),
                if (trend != null) ...[
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      trend!,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;
  final bool isDummy;

  const _ChartCard({required this.title, required this.child, this.isDummy = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),
          if (isDummy)
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: child,
            )
          else
            child,
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import '../../data/models/admin_audit_log_item.dart';

class SecurityAlertsView extends StatelessWidget {
  const SecurityAlertsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        if (state is AdminLoading || state is AdminInitial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AdminError) {
          return Center(child: Text("Error: ${state.message}", style: TextStyle(color: colorScheme.error)));
        }
        
        if (state is AdminLoaded) {
          final isMobile = MediaQuery.of(context).size.width < 800;
          return SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16 : 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isMobile) ...[
                  Text(
                    'Security Alerts & Audit Logs',
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ] else
                  Text(
                    'Security Alerts & Audit Logs',
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(colorScheme.surfaceContainerHighest.withOpacity(0.5)),
                        dataRowMinHeight: 64,
                        dataRowMaxHeight: 64,
                        columns: const [
                          DataColumn(label: Text('Date')),
                          DataColumn(label: Text('Action / Alert Type')),
                          DataColumn(label: Text('Target Resource')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: state.auditLogs.map((log) {
                          return _buildRow(context, log);
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  DataRow _buildRow(BuildContext context, AdminAuditLogItem log) {
    final theme = Theme.of(context);
    
    final bool isCritical = log.action.startsWith('SECURITY_ALERT');
    
    return DataRow(
      cells: [
        DataCell(Text(DateFormat('MMM dd, yyyy HH:mm:ss').format(log.createdAt))),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isCritical ? Colors.red.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isCritical ? Colors.red.withOpacity(0.5) : Colors.blue.withOpacity(0.5)),
            ),
            child: Text(
              log.action,
              style: TextStyle(
                color: isCritical ? Colors.redAccent : Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        DataCell(Text('${log.resourceType}: ${log.resourceId ?? "N/A"}')),
        DataCell(
          Row(
            children: [
              if (isCritical && log.resourceType == 'USER' && log.resourceId != null)
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.block, size: 16),
                  label: const Text('Suspend User'),
                  onPressed: () {
                    context.read<AdminBloc>().add(
                      AdminToggleUserSuspensionRequested(
                        userId: log.resourceId!,
                        suspend: true,
                      ),
                    );
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('User ${log.resourceId} has been suspended.')),
                    );
                  },
                )
              else
                const Text('-', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }
}

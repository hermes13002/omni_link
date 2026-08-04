import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';

class UsersManagementView extends StatelessWidget {
  const UsersManagementView({super.key});

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
          return SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Users Directory',
                      style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.download),
                      label: const Text('Export CSV'),
                    ),
                  ],
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
                          DataColumn(label: Text('User ID / Email')),
                          DataColumn(label: Text('Join Date')),
                          DataColumn(label: Text('Devices')),
                          DataColumn(label: Text('Storage Used')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: state.users.map((user) {
                          return _buildRow(
                            context,
                            user.id,
                            user.email,
                            DateFormat('MMM dd, yyyy').format(user.createdAt),
                            user.deviceCount.toString(),
                            '${(user.storageUsedBytes / 1024 / 1024).toStringAsFixed(2)} MB',
                            user.isSuspended ? 'Suspended' : 'Active',
                          );
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

  DataRow _buildRow(BuildContext context, String userId, String email, String joinDate, String devices, String storage, String status) {
    final theme = Theme.of(context);
    final isSuspended = status == 'Suspended';
    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                child: Text(email[0].toUpperCase(), style: TextStyle(color: theme.colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Text(email, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        DataCell(Text(joinDate)),
        DataCell(Text(devices)),
        DataCell(Text(storage)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isSuspended ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSuspended ? Colors.red.withOpacity(0.5) : Colors.green.withOpacity(0.5)),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: isSuspended ? Colors.redAccent : Colors.greenAccent,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.open_in_new, size: 20),
                onPressed: () {
                  // Navigate to user details
                  // context.push('/admin/users/$userId');
                },
                tooltip: 'View Profile',
              ),
              IconButton(
                icon: Icon(
                  isSuspended ? Icons.restore : Icons.block, 
                  size: 20, 
                  color: isSuspended ? Colors.green : Colors.red,
                ),
                onPressed: () {
                  context.read<AdminBloc>().add(
                    AdminToggleUserSuspensionRequested(
                      userId: userId,
                      suspend: !isSuspended,
                    ),
                  );
                },
                tooltip: isSuspended ? 'Restore User' : 'Suspend User',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

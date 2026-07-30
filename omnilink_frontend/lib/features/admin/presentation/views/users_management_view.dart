import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../shared/widgets/omni_glass_container.dart';
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
                OmniGlassContainer(
                  padding: const EdgeInsets.all(0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
                        columns: const [
                          DataColumn(label: Text('User Email')),
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
    final isSuspended = status == 'Suspended';
    return DataRow(
      cells: [
        DataCell(Text(email)),
        DataCell(Text(joinDate)),
        DataCell(Text(devices)),
        DataCell(Text(storage)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isSuspended ? Colors.red.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: isSuspended ? Colors.red : Colors.green,
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
                icon: const Icon(Icons.remove_red_eye_outlined, size: 20),
                onPressed: () {},
                tooltip: 'View Audit Log',
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

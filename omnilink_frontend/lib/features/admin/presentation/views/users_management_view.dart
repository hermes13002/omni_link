import 'package:flutter/material.dart';
import '../../../../../shared/widgets/omni_glass_container.dart';

class UsersManagementView extends StatelessWidget {
  const UsersManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
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
            padding: const EdgeInsets.all(0), // Table manages its own padding
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
                  columns: const [
                    DataColumn(label: Text('User ID / Email (Obfuscated)')),
                    DataColumn(label: Text('Join Date')),
                    DataColumn(label: Text('Devices')),
                    DataColumn(label: Text('Storage Used')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: [
                    _buildRow(context, 'us***@example.com', 'Oct 12, 2026', '2', '1.2 GB', 'Active'),
                    _buildRow(context, 'al***@test.com', 'Oct 10, 2026', '3', '400 MB', 'Active'),
                    _buildRow(context, 'ba***@domain.com', 'Oct 05, 2026', '1', '2.1 GB', 'Suspended'),
                    _buildRow(context, 'ne***@site.org', 'Sep 28, 2026', '4', '8.5 GB', 'Active'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildRow(BuildContext context, String email, String joinDate, String devices, String storage, String status) {
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
                onPressed: () {},
                tooltip: isSuspended ? 'Restore User' : 'Suspend User',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

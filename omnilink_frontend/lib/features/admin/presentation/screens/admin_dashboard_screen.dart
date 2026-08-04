import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omnilink_frontend/features/admin/presentation/views/admin_overview_view.dart';
import 'package:omnilink_frontend/features/admin/presentation/views/technical_health_view.dart';
import 'package:omnilink_frontend/features/admin/presentation/views/users_management_view.dart';
import 'package:omnilink_frontend/features/admin/presentation/views/content_moderation_view.dart';
import 'package:omnilink_frontend/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:omnilink_frontend/features/admin/presentation/bloc/admin_event.dart';
import 'package:omnilink_frontend/features/admin/presentation/widgets/admin_side_nav.dart';
import 'package:omnilink_frontend/features/admin/presentation/widgets/admin_top_bar.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(AdminLoadDataRequested());
  }

  final List<Widget> _pages = [
    const AdminOverviewView(),
    const UsersManagementView(),
    const ContentModerationView(),
    const TechnicalHealthView(),
  ];

  final List<String> _titles = [
    'Overview',
    'Users',
    'Moderation',
    'System Health',
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    // Force Dark Theme for Admin Panel
    return Theme(
      data: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.blueAccent,
        useMaterial3: true,
      ),
      child: Builder(
        builder: (context) {
          final colorScheme = Theme.of(context).colorScheme;
          return Scaffold(
            backgroundColor: colorScheme.surface,
            body: Row(
              children: [
                if (!isMobile)
                  AdminSideNav(
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: (int index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                  ),
                Expanded(
                  child: Column(
                    children: [
                      AdminTopBar(title: _titles[_selectedIndex]),
                      Expanded(
                        child: _pages[_selectedIndex],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }
}

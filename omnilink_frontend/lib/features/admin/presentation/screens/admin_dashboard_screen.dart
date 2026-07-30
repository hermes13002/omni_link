import 'package:flutter/material.dart';
import '../../../../shared/widgets/omni_glass_container.dart';
import 'technical_health_view.dart';
import 'product_health_view.dart';
import 'growth_health_view.dart';
import 'users_management_view.dart';
import 'content_moderation_view.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const TechnicalHealthView(),
    const ProductHealthView(),
    const GrowthHealthView(),
    const UsersManagementView(),
    const ContentModerationView(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            backgroundColor: colorScheme.surfaceContainerLow,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.memory_outlined),
                selectedIcon: Icon(Icons.memory),
                label: Text('Technical'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.show_chart_outlined),
                selectedIcon: Icon(Icons.show_chart),
                label: Text('Product'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.trending_up_outlined),
                selectedIcon: Icon(Icons.trending_up),
                label: Text('Growth'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: Text('Users'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.admin_panel_settings_outlined),
                selectedIcon: Icon(Icons.admin_panel_settings),
                label: Text('Moderation'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
    );
  }
}

class UsersManagementView extends StatelessWidget {
  const UsersManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Users Table"));
  }
}

class ContentModerationView extends StatelessWidget {
  const ContentModerationView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Content Moderation Feed"));
  }
}

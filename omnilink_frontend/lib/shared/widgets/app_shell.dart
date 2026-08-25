import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'omni_bottom_nav.dart';
import 'omni_side_nav.dart';
import 'omni_faded_grid_background.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return OmniFadedGridBackground(
      child: ScreenTypeLayout.builder(
        mobile: (context) => Scaffold(
          backgroundColor: Colors.transparent,
          body: navigationShell,
          bottomNavigationBar: OmniBottomNav(navigationShell: navigationShell),
        ),
        tablet: (context) => Scaffold(
          backgroundColor: Colors.transparent,
          body: Row(
            children: [
              OmniSideNav(navigationShell: navigationShell),
              Expanded(child: navigationShell),
            ],
          ),
        ),
        desktop: (context) => Scaffold(
          backgroundColor: Colors.transparent,
          body: Row(
            children: [
              OmniSideNav(navigationShell: navigationShell),
              Expanded(child: navigationShell),
            ],
          ),
        ),
      ),
    );
  }
}

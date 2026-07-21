import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'omni_bottom_nav.dart';
import 'omni_side_nav.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (context) => Scaffold(
        body: navigationShell,
        bottomNavigationBar: OmniBottomNav(navigationShell: navigationShell),
      ),
      tablet: (context) => Scaffold(
        body: Row(
          children: [
            OmniSideNav(navigationShell: navigationShell),
            Expanded(child: navigationShell),
          ],
        ),
      ),
      desktop: (context) => Scaffold(
        body: Row(
          children: [
            OmniSideNav(navigationShell: navigationShell),
            Expanded(child: navigationShell),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'omni_glass_container.dart';

class OmniBottomNav extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const OmniBottomNav({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return OmniGlassContainer(
      borderRadius: 0,
      backgroundColor: colorScheme.surfaceContainerLowest.withAlpha(204),
      border: const Border(top: BorderSide.none),
      child: BottomNavigationBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          if (index == 0 || index == 1) {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          } else if (index == 2) {
            // Sync is currently just an icon or could trigger load, 
            // but we might want it to remain on current screen and dispatch event.
            // For now, let's keep it as is.
          } else if (index == 3) {
            context.push('/profile');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.content_paste),
            label: 'Clip',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.refresh),
            label: 'Sync',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

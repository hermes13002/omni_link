import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'omni_glass_container.dart';

class OmniBottomNav extends StatelessWidget {
  const OmniBottomNav({super.key});

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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.clipboard),
            label: 'Clip',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.folder),
            label: 'Files',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.refreshCw),
            label: 'Sync',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

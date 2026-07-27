import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OmniTopBar extends StatelessWidget implements PreferredSizeWidget {
  const OmniTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppBar(
      centerTitle: false,
      title: Text(
        'OmniLink',
        style: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
          letterSpacing: -0.5,
        ),
      ),
      actions: [

        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: IconButton(
            icon: Icon(Icons.settings_rounded, color: colorScheme.onSurfaceVariant),
            tooltip: 'Settings',
            onPressed: () {
              context.go('/settings');
            },
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

import 'package:flutter/material.dart';

class OmniTopBar extends StatelessWidget implements PreferredSizeWidget {
  const OmniTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppBar(
      title: Text(
        'Omnilink',
        style: textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.devices, color: colorScheme.onSurfaceVariant),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.refresh, color: colorScheme.onSurfaceVariant),
          onPressed: () {},
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16.0, left: 8.0),
          child: CircleAvatar(
            backgroundColor: colorScheme.primaryContainer,
            radius: 16,
            child: Text(
              'U',
              style: textTheme.labelMedium?.copyWith(color: colorScheme.onPrimaryContainer),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

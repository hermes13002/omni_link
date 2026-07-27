import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/timeline/presentation/bloc/timeline_bloc.dart';
import '../../features/timeline/presentation/bloc/timeline_event.dart';

class OmniTopBar extends StatelessWidget implements PreferredSizeWidget {
  const OmniTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppBar(
      title: Text(
        'Welcome',
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
            icon: Icon(Icons.settings, color: colorScheme.onSurfaceVariant),
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

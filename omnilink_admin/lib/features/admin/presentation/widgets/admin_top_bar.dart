import 'package:flutter/material.dart';

class AdminTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showMenuButton;

  const AdminTopBar({super.key, required this.title, this.showMenuButton = false});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      height: preferredSize.height,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          if (showMenuButton)
            IconButton(
              icon: Icon(Icons.menu, color: colorScheme.onSurface),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          if (showMenuButton) const SizedBox(width: 4),
          Expanded(
            child: Text(
              'Admin / $title',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (!isMobile) ...[
            Container(
              width: 240,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  Icon(Icons.search, size: 18, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text(
                    'Search (Cmd + K)',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
          ],
          IconButton(
            icon: Icon(Icons.notifications_none, color: colorScheme.onSurfaceVariant),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
          CircleAvatar(
            radius: 16,
            backgroundColor: colorScheme.primary,
            child: Text(
              'AD',
              style: textTheme.labelSmall?.copyWith(color: colorScheme.onPrimary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64.0);
}

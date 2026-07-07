import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

enum TimelineCardType { image, code, file }

class OmniTimelineCard extends StatelessWidget {
  final TimelineCardType type;
  final String title;
  final String subtitle;
  final String timeAgo;
  final String tag;
  final Color? tagColor;

  const OmniTimelineCard({
    super.key,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.timeAgo,
    required this.tag,
    this.tagColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (type == TimelineCardType.image)
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colorScheme.primaryContainer.withAlpha(150),
                    colorScheme.primaryContainer.withAlpha(0),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Icon(
                      LucideIcons.image,
                      size: 48,
                      color: colorScheme.onSurfaceVariant.withAlpha(51),
                    ),
                  ),
                ],
              ),
            ),
          if (type == TimelineCardType.code)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colorScheme.surfaceContainerHighest.withAlpha(128),
                    colorScheme.surfaceContainerHighest.withAlpha(0),
                  ],
                ),
              ),
              child: Text(
                'Project notes regarding the new API structure. We need to ensure that the middleware handles the authentication tokens correctly before passing the request object down to the controller layer. Also check the...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'JetBrains Mono',
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (type == TimelineCardType.file)
            Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colorScheme.surfaceContainerHighest.withAlpha(128),
                    colorScheme.surfaceContainerHighest.withAlpha(0),
                  ],
                ),
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.tertiaryContainer.withAlpha(51),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    LucideIcons.fileArchive,
                    color: colorScheme.tertiary,
                    size: 32,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          type == TimelineCardType.image
                              ? LucideIcons.smartphone
                              : LucideIcons.monitor,
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          timeAgo,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: tagColor?.withAlpha(51) ?? colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tag,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: tagColor ?? colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

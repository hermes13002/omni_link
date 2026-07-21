import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:omnilink_frontend/shared/utils/omni_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';

enum TimelineCardType { image, code, file, pdf }

class OmniTimelineCard extends StatelessWidget {
  final TimelineCardType type;
  final String title;
  final String subtitle;
  final String timeAgo;
  final String tag;
  final Color? tagColor;
  final String? body;
  final String? imageUrl;
  final bool isPinned;
  final VoidCallback? onTogglePin;
  final VoidCallback? onTap;

  const OmniTimelineCard({
    super.key,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.timeAgo,
    required this.tag,
    this.tagColor,
    this.body,
    this.imageUrl,
    this.isPinned = false,
    this.onTogglePin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
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
                  if (imageUrl != null)
                    Positioned.fill(
                      child: ShaderMask(
                        shaderCallback: (rect) {
                          return const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black, Colors.black, Colors.transparent],
                            stops: [0.0, 0.6, 1.0],
                          ).createShader(rect);
                        },
                        blendMode: BlendMode.dstIn,
                        child: CachedNetworkImage(
                          imageUrl: imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(
                              color: colorScheme.onSurfaceVariant.withAlpha(51),
                            ),
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.broken_image,
                            size: 48,
                            color: colorScheme.onSurfaceVariant.withAlpha(51),
                          ),
                        ),
                      ),
                    )
                  else
                    Positioned.fill(
                      child: Icon(
                        Icons.image,
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
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 32.0),
                    child: Text(
                      body ?? title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: 'JetBrains Mono',
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 6,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Positioned(
                    top: -12,
                    right: -12,
                    child: IconButton(
                      icon: Icon(Icons.copy, size: 16, color: colorScheme.onSurfaceVariant),
                      tooltip: 'Copy text',
                      onPressed: () {
                        final textToCopy = body ?? title;
                        if (textToCopy.isNotEmpty) {
                          Clipboard.setData(ClipboardData(text: textToCopy));
                          OmniToast.showInfo(context, 'Copied to clipboard');
                        }
                      },
                    ),
                  ),
                ],
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
                    Icons.archive,
                    color: colorScheme.tertiary,
                    size: 32,
                  ),
                ),
              ),
            ),
          if (type == TimelineCardType.pdf)
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
                    Icons.picture_as_pdf,
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (onTogglePin != null)
                      GestureDetector(
                        onTap: onTogglePin,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Icon(
                            isPinned ? Icons.star : Icons.star_outline,
                            color: isPinned ? Colors.amber : colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                        ),
                      ),
                  ],
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
                              ? Icons.smartphone
                              : Icons.monitor,
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
    ));
  }
}

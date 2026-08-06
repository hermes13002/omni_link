import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:omnilink_frontend/shared/utils/omni_toast.dart';
import 'package:omnilink_frontend/shared/widgets/web_image/omni_web_image.dart';
import 'package:any_link_preview/any_link_preview.dart';
import 'package:dio/dio.dart';
import '../../core/di/injection.dart';
import '../../features/timeline/data/models/card_model.dart';

enum TimelineCardType { image, code, file, pdf, link }

class OmniTimelineCard extends StatelessWidget {
  final TimelineCardType type;
  final String title;
  final String subtitle;
  final String timeAgo;
  final String tag;
  final Color? tagColor;
  final String? body;
  final String? imageUrl;
  final String? cardId;
  final bool isPinned;
  final CardSyncStatus syncStatus;
  final Uint8List? localBytes;
  final VoidCallback? onTogglePin;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;

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
    this.cardId,
    this.isPinned = false,
    this.syncStatus = CardSyncStatus.synced,
    this.localBytes,
    this.onTogglePin,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
  });

  Widget _buildBackground(BuildContext context, ColorScheme colorScheme) {
    if (type == TimelineCardType.image) {
      if (localBytes != null) {
        return Image.memory(
          localBytes!,
          fit: BoxFit.cover,
        );
      } else if (imageUrl != null) {
        return OmniWebImage(
          imageUrl: imageUrl!,
          cacheKey: cardId,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: colorScheme.surfaceContainerHighest.withAlpha(100),
            child: Center(
              child: CircularProgressIndicator(
                color: colorScheme.onSurfaceVariant.withAlpha(51),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: colorScheme.surfaceContainerHighest.withAlpha(100),
            child: Icon(
              Icons.broken_image_rounded,
              size: 48,
              color: colorScheme.onSurfaceVariant.withAlpha(51),
            ),
          ),
        );
      } else {
        return Container(
          color: colorScheme.surfaceContainerHighest.withAlpha(100),
          child: Center(
            child: Icon(
              Icons.image_rounded,
              size: 64,
              color: colorScheme.onSurfaceVariant.withAlpha(100),
            ),
          ),
        );
      }
    } else if (type == TimelineCardType.link) {
      final bodyText = body ?? '';
      final match = RegExp(r'https?:\/\/[^\s]+').firstMatch(bodyText);
      final url = match?.group(0) ?? '';

      if (url.isEmpty) {
        return _buildGenericLinkFallback(colorScheme);
      }

      return FutureBuilder<Metadata?>(
        key: ValueKey(url),
        future: AnyLinkPreview.getMetadata(
          link: kIsWeb ? '${getIt<Dio>().options.baseUrl}/api/v1/proxy?url=${Uri.encodeComponent(url)}' : url,
          cache: const Duration(hours: 1),
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              color: colorScheme.surfaceContainerHighest.withAlpha(100),
              child: Center(
                child: CircularProgressIndicator(color: colorScheme.onSurfaceVariant.withAlpha(51)),
              ),
            );
          }

          final metadata = snapshot.data;
          final imageUrl = metadata?.image;
          final proxiedImageUrl = (kIsWeb && imageUrl != null && imageUrl.startsWith('http'))
              ? '${getIt<Dio>().options.baseUrl}/api/v1/proxy?url=${Uri.encodeComponent(imageUrl)}'
              : imageUrl;

          if (proxiedImageUrl != null) {
            return Image.network(
              proxiedImageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildGenericLinkFallback(colorScheme),
            );
          }

          return _buildGenericLinkFallback(colorScheme);
        },
      );
    } else if (type == TimelineCardType.code) {
      return Container(
        color: colorScheme.surfaceContainerHighest.withAlpha(100),
        padding: const EdgeInsets.all(16),
        child: Text(
          body ?? title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontFamily: 'JetBrains Mono',
            color: colorScheme.onSurfaceVariant.withAlpha(180),
            height: 1.5,
          ),
          overflow: TextOverflow.clip,
        ),
      );
    } else {
      // file or pdf
      return Container(
        color: colorScheme.surfaceContainerHighest.withAlpha(100),
        child: Center(
          child: Icon(
            type == TimelineCardType.pdf ? Icons.picture_as_pdf_rounded : Icons.file_present_rounded,
            size: 64,
            color: colorScheme.onSurfaceVariant.withAlpha(100),
          ),
        ),
      );
    }
  }

  Widget _buildGenericLinkFallback(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surfaceContainerHighest.withAlpha(100),
      child: Center(
        child: Icon(
          Icons.link_rounded,
          size: 64,
          color: colorScheme.onSurfaceVariant.withAlpha(100),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ColorScheme colorScheme, ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (type == TimelineCardType.code)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  final textToCopy = body ?? title;
                  if (textToCopy.isNotEmpty) {
                    Clipboard.setData(ClipboardData(text: textToCopy));
                    OmniToast.showInfo(context, 'Copied to clipboard');
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withAlpha(150),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.copy_rounded, size: 14, color: colorScheme.onSurface),
                ),
              ),
            ],
          ),
        if (type == TimelineCardType.code) const SizedBox(height: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
            letterSpacing: -0.3,
            height: 1.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (type != TimelineCardType.image && type != TimelineCardType.code && subtitle.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: tagColor?.withAlpha(40) ?? colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tag,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: tagColor ?? colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Row(
              children: [
                Icon(
                  type == TimelineCardType.image ? Icons.smartphone_rounded : Icons.monitor_rounded,
                  size: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  timeAgo,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (syncStatus == CardSyncStatus.pending) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.access_time_rounded,
                    size: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ] else if (syncStatus == CardSyncStatus.error) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.error_outline_rounded,
                    size: 12,
                    color: colorScheme.error,
                  ),
                ],
              ],
            ),
          ],
        ),
      ],
    );
  }

  double _getCardAspectRatio() {
    if (type == TimelineCardType.image && cardId != null) {
      final hash = cardId!.hashCode.abs();
      // Range: 0.65 (taller) to 0.95 (almost square)
      return 0.65 + (hash % 4) * 0.1;
    }
    if (type == TimelineCardType.code) {
      return 1.1; // Text/Code is shorter (smaller height)
    }
    return 0.85; // Files/PDFs are shorter
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AspectRatio(
      aspectRatio: _getCardAspectRatio(), // Dynamically staggered
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(32), // Squircle vibe
          border: Border.all(
            color: isSelected 
                ? colorScheme.primary 
                : (theme.brightness == Brightness.dark 
                    ? Colors.white.withAlpha(60) 
                    : colorScheme.outlineVariant.withAlpha(100)),
            width: isSelected ? 3.0 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withAlpha(20),
              blurRadius: 24,
              spreadRadius: -4,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Background (Image, Code text, or Icon)
            _buildBackground(context, colorScheme),

            // 2. Gradient Overlay for soft glassmorphism effect (Only for image cards)
            if (type == TimelineCardType.image)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        colorScheme.surface.withAlpha(180),
                        colorScheme.surface,
                      ],
                      stops: const [0.35, 0.75, 1.0],
                    ),
                  ),
                ),
              ),

            // 3. Ripple effect on tap (layered below interactive elements so they can receive taps)
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  onLongPress: onLongPress,
                  splashColor: colorScheme.onSurface.withAlpha(20),
                  highlightColor: colorScheme.onSurface.withAlpha(10),
                ),
              ),
            ),

            // 4. Content overlay (Title, tags, meta) anchored to bottom
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: _buildContent(context, colorScheme, theme),
            ),

            // 5. Pin Button Top Right
            if (onTogglePin != null)
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: onTogglePin,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withAlpha(isPinned ? 200 : 100),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPinned ? Icons.star_rounded : Icons.star_border_rounded,
                      color: isPinned ? Colors.amber : colorScheme.onSurface,
                      size: 18,
                    ),
                  ),
                ),
              ),

            // 6. Selection Overlay Checkmark
            if (isSelected)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(40),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: colorScheme.onPrimary,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

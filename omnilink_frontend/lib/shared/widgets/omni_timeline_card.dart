import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:omnilink_frontend/shared/utils/omni_toast.dart';
import 'package:omnilink_frontend/shared/widgets/web_image/omni_web_image.dart';
import 'package:any_link_preview/any_link_preview.dart';
import 'package:url_launcher/url_launcher.dart';
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
  final int? fileSizeBytes;
  final VoidCallback? onTogglePin;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
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
    this.fileSizeBytes,
    this.onTogglePin,
    this.onEdit,
    this.onDelete,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
  });

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

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
      final match = RegExp(r'(https?:\/\/[^\s]+|(?:www\.)[^\s]+)', caseSensitive: false).firstMatch(bodyText);
      String url = match?.group(0) ?? '';
      if (url.isNotEmpty && !url.startsWith('http')) {
        url = 'https://$url';
      }

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
          overflow: TextOverflow.fade,
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
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  Container(
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
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
                  if (fileSizeBytes != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.folder_open_rounded, size: 12, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          _formatFileSize(fileSizeBytes!),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
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
    if (type == TimelineCardType.link) {
      return 0.70; // Taller for the split view
    }
    return 0.85; // Files/PDFs are shorter
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final cardStack = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (type == TimelineCardType.image)
          Flexible(
            fit: FlexFit.loose,
            child: AspectRatio(
              aspectRatio: _getCardAspectRatio(),
              child: _buildBackground(context, colorScheme),
            ),
          ),
        if (type == TimelineCardType.link)
          Flexible(
            fit: FlexFit.loose,
            child: AspectRatio(
              aspectRatio: 1.5,
              child: _buildBackground(context, colorScheme),
            ),
          ),
        if (type == TimelineCardType.file || type == TimelineCardType.pdf)
          SizedBox(
            height: 120,
            child: _buildBackground(context, colorScheme),
          ),
          
        if (type == TimelineCardType.code)
          Flexible(
            fit: FlexFit.loose,
            child: _buildBackground(context, colorScheme),
          ),
          
        if (type != TimelineCardType.link)
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildContent(context, colorScheme, theme),
          ),
          
        if (type == TimelineCardType.link)
          Flexible(
            fit: FlexFit.loose,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildLinkContentDetails(context, colorScheme, theme),
            ),
          ),
      ],
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 120,
        maxHeight: 400,
      ),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: isSelected 
                ? colorScheme.primary 
                : syncStatus == CardSyncStatus.error
                    ? colorScheme.error.withAlpha(200)
                    : (theme.brightness == Brightness.dark 
                        ? Colors.white.withAlpha(60) 
                        : colorScheme.outlineVariant.withAlpha(100)),
            width: isSelected ? 3.0 : (syncStatus == CardSyncStatus.error ? 2.0 : 1.5),
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
          children: [
            cardStack,
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
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: colorScheme.surface.withAlpha(150),
                  shape: BoxShape.circle,
                ),
                child: PopupMenuButton<String>(
                  popUpAnimationStyle: AnimationStyle(
                    curve: Curves.easeOutBack,
                    duration: const Duration(milliseconds: 300),
                  ),
                  child: Center(
                    child: Icon(Icons.more_horiz_rounded, size: 16, color: colorScheme.onSurface),
                  ),
                  padding: EdgeInsets.zero,
                  position: PopupMenuPosition.under,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onSelected: (value) {
                    if (value == 'copy') {
                      final textToCopy = body ?? title;
                      if (textToCopy.isNotEmpty) {
                        Clipboard.setData(ClipboardData(text: textToCopy));
                        OmniToast.showInfo(context, 'Copied to clipboard');
                      }
                    }
                    if (value == 'favorite') onTogglePin?.call();
                    if (value == 'edit') onEdit?.call();
                    if (value == 'delete') onDelete?.call();
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'copy',
                      child: Row(
                        children: [
                          Icon(Icons.copy_rounded, size: 20, color: colorScheme.onSurfaceVariant),
                          const SizedBox(width: 12),
                          const Text('Copy'),
                        ],
                      ),
                    ),
                    if (onTogglePin != null)
                      PopupMenuItem(
                        value: 'favorite',
                        child: Row(
                          children: [
                            Icon(isPinned ? Icons.star_rounded : Icons.star_border_rounded, size: 20, color: isPinned ? Colors.amber : colorScheme.onSurfaceVariant),
                            const SizedBox(width: 12),
                            Text(isPinned ? 'Unfavorite' : 'Favorite'),
                          ],
                        ),
                      ),
                    if (onEdit != null)
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_rounded, size: 20, color: colorScheme.onSurfaceVariant),
                            const SizedBox(width: 12),
                            const Text('Edit'),
                          ],
                        ),
                      ),
                    if (onDelete != null)
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_rounded, size: 20, color: colorScheme.error),
                            const SizedBox(width: 12),
                            Text('Delete', style: TextStyle(color: colorScheme.error)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
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

  Widget _buildLinkContentDetails(BuildContext context, ColorScheme colorScheme, ThemeData theme) {
    final bodyText = body ?? '';
    final match = RegExp(r'(https?:\/\/[^\s]+|(?:www\.)[^\s]+)', caseSensitive: false).firstMatch(bodyText);
    String extractedUrl = match?.group(0) ?? '';
    if (extractedUrl.isNotEmpty && !extractedUrl.startsWith('http')) {
      extractedUrl = 'https://$extractedUrl';
    }
    
    // Sometimes title is exactly the URL or empty, handle gracefully
    final displayUrl = extractedUrl.isNotEmpty ? extractedUrl : (title.startsWith('http') ? title : '');
    final cleanTitle = title.trim();
    final cleanSubtitle = subtitle.trim();
    final cleanUrl = displayUrl.trim();
    
    final showTitle = cleanTitle.isNotEmpty && cleanTitle != cleanUrl;
    final showSubtitle = cleanSubtitle.isNotEmpty && cleanSubtitle != cleanTitle && cleanSubtitle != cleanUrl;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (displayUrl.isNotEmpty)
          GestureDetector(
            onTap: () async {
              final uri = Uri.parse(displayUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
            child: Text(
              displayUrl,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        if (displayUrl.isNotEmpty && (showTitle || showSubtitle))
          const SizedBox(height: 8),
        if (showTitle)
          SelectableText(
            cleanTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
              letterSpacing: -0.3,
              height: 1.2,
            ),
          ),
        if (showTitle && showSubtitle)
          const SizedBox(height: 4),
        if (showSubtitle)
          SelectableText(
            cleanSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Footer (Tags, Time, Horiz icon) uses the same structure from _buildContent
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  Container(
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.monitor_rounded,
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
                  if (fileSizeBytes != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.folder_open_rounded, size: 12, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          _formatFileSize(fileSizeBytes!),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

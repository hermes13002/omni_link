import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omnilink_frontend/features/timeline/presentation/bloc/timeline_bloc.dart';
import 'package:omnilink_frontend/features/timeline/presentation/bloc/timeline_event.dart';
import 'package:omnilink_frontend/shared/utils/omni_toast.dart';
import 'package:omnilink_frontend/shared/widgets/web_image/omni_web_image.dart';
import '../../features/timeline/data/models/card_model.dart';
import '../../features/timeline/data/cards_api.dart';
import '../../features/timeline/presentation/bloc/tags_bloc.dart';
import '../../features/timeline/presentation/bloc/tags_state.dart';
import '../../features/timeline/presentation/bloc/tags_event.dart';
import '../../core/di/injection.dart';
import 'omni_glass_container.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:any_link_preview/any_link_preview.dart';

class OmniCardDetailsDialog extends StatefulWidget {
  final CardModel card;
  final bool initialEditMode;
  
  const OmniCardDetailsDialog({super.key, required this.card, this.initialEditMode = false});

  @override
  State<OmniCardDetailsDialog> createState() => _OmniCardDetailsDialogState();
}

class _OmniCardDetailsDialogState extends State<OmniCardDetailsDialog> with SingleTickerProviderStateMixin {
  bool _isEditing = false;
  bool _isSaving = false;
  late bool _isPinned;
  late TabController _tabController;
  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  late List<String> _selectedTagIds;
  Future<Metadata?>? _metadataFuture;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.initialEditMode;
    _isPinned = widget.card.pinned;
    _tabController = TabController(length: 2, vsync: this);
    _titleController = TextEditingController(text: widget.card.title ?? '');
    _bodyController = TextEditingController(text: widget.card.body ?? '');
    _selectedTagIds = widget.card.tags.map((t) => t.id).toList();
    
    if (widget.card.cardType == 'metadata') {
      final bodyText = widget.card.body ?? '';
      final match = RegExp(r'(https?:\/\/[^\s]+|(?:www\.)[^\s]+)', caseSensitive: false).firstMatch(bodyText);
      String url = match?.group(0) ?? '';
      if (url.isNotEmpty && !url.startsWith('http')) {
        url = 'https://$url';
      }
      
      if (url.isNotEmpty) {
        _metadataFuture = AnyLinkPreview.getMetadata(
          link: kIsWeb ? '${getIt<Dio>().options.baseUrl}/api/v1/proxy?url=${Uri.encodeComponent(url)}' : url,
          cache: const Duration(hours: 1),
        );
      }
    }
    
    getIt<TagsBloc>().add(TagsLoadRequested());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _togglePin() {
    setState(() {
      _isPinned = !_isPinned;
    });
    // Create a fake old card so the bloc correctly computes the new state as _isPinned
    final fakeOldCard = widget.card.copyWith(pinned: !_isPinned);
    context.read<TimelineBloc>().add(TimelineTogglePinRequested(fakeOldCard));
  }

  String _formatFileSize(int? bytes) {
    if (bytes == null) return 'Unknown size';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).round()} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _handleDownload() async {
    try {
      if (mounted) OmniToast.showInfo(context, 'Starting download...');
      final downloadUrl = await getIt<CardsApi>().getDownloadUrl(widget.card.id);
      final uri = Uri.parse(downloadUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) OmniToast.showError(context, 'Could not launch download');
      }
    } catch (e) {
      if (mounted) OmniToast.showError(context, 'Failed to download file');
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Card'),
        content: const Text('Are you sure you want to delete this card?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        context.read<TimelineBloc>().add(TimelineDeleteCardsRequested([widget.card.id]));
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          OmniToast.showError(context, 'Failed to delete: $e');
        }
      }
    }
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    try {
      await getIt<CardsApi>().updateCard(
        widget.card.id,
        title: _titleController.text.isNotEmpty ? _titleController.text : null,
        body: _bodyController.text.isNotEmpty ? _bodyController.text : null,
        tagIds: _selectedTagIds.toList(),
      );
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        OmniToast.showError(context, 'Failed to update: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    IconData headerIcon = Icons.article_rounded;
    final titleLower = widget.card.title?.toLowerCase() ?? '';
    final isImage = widget.card.mimeType?.startsWith('image/') == true || 
          titleLower.endsWith('.jpg') || titleLower.endsWith('.png') || titleLower.endsWith('.jpeg') || titleLower.endsWith('.webp');
    final isPdf = widget.card.mimeType == 'application/pdf' || titleLower.endsWith('.pdf');

    if (widget.card.cardType == 'text') headerIcon = Icons.code_rounded;
    else if (widget.card.cardType == 'metadata') headerIcon = Icons.link_rounded;
    else if (widget.card.cardType == 'file' && isImage) headerIcon = Icons.image_rounded;
    else if (widget.card.cardType == 'file' && isPdf) headerIcon = Icons.picture_as_pdf_rounded;
    else headerIcon = Icons.file_present_rounded;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
      child: Dialog(
        backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(24),
      child: Hero(
        tag: widget.card.id,
        child: Material(
          type: MaterialType.transparency,
          child: OmniGlassContainer(
            padding: const EdgeInsets.all(24.0),
            borderRadius: 24.0,
            child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height * 0.5,
            maxWidth: 600,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // Header
            Row(
              children: [
                Icon(headerIcon, color: colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: _isEditing
                      ? TextField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            hintText: 'Title',
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        )
                      : Text(
                          widget.card.title ?? widget.card.body ?? 'Untitled',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
                if (!_isEditing)
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert_rounded, color: colorScheme.onSurfaceVariant),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onSelected: (value) {
                      switch (value) {
                        case 'pin':
                          _togglePin();
                          break;
                        case 'edit':
                          setState(() => _isEditing = true);
                          break;
                        case 'download':
                          _handleDownload();
                          break;
                        case 'delete':
                          _handleDelete();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'pin',
                        child: Row(
                          children: [
                            Icon(_isPinned ? Icons.star_rounded : Icons.star_border_rounded, color: _isPinned ? Colors.amber : colorScheme.onSurfaceVariant, size: 20),
                            const SizedBox(width: 12),
                            Text(_isPinned ? 'Unpin' : 'Pin'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_rounded, color: colorScheme.onSurfaceVariant, size: 20),
                            const SizedBox(width: 12),
                            const Text('Edit'),
                          ],
                        ),
                      ),
                      if (widget.card.gcsSignedUrl != null)
                        PopupMenuItem(
                          value: 'download',
                          child: Row(
                            children: [
                              Icon(Icons.download_rounded, color: colorScheme.onSurfaceVariant, size: 20),
                              const SizedBox(width: 12),
                              const Text('Download'),
                            ],
                          ),
                        ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_rounded, color: colorScheme.error, size: 20),
                            const SizedBox(width: 12),
                            Text('Delete', style: TextStyle(color: colorScheme.error)),
                          ],
                        ),
                      ),
                    ],
                  ),
                if (_isEditing)
                  _isSaving
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                        )
                      : IconButton(
                          icon: const Icon(Icons.check_rounded),
                          onPressed: _handleSave,
                          color: colorScheme.primary,
                          tooltip: 'Save',
                        ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                child: _buildContent(context, colorScheme, isImage, isPdf),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Footer Info
            if (_isEditing)
              _buildTagEditor(context, colorScheme)
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildChip(
                    context, 
                    Icons.timer_rounded, 
                    'Updated ${widget.card.updatedAt.toLocal().toString().split('.')[0]}'
                  ),
                  if (widget.card.fileSizeBytes != null)
                    _buildChip(
                      context, 
                      Icons.storage_rounded, 
                      _formatFileSize(widget.card.fileSizeBytes)
                    ),
                  ...widget.card.tags.map((tag) => _buildChip(
                    context, 
                    Icons.local_offer_rounded, 
                    '#${tag.name}',
                    backgroundColor: colorScheme.secondaryContainer,
                    textColor: colorScheme.onSecondaryContainer,
                  )),
                ],
              ),
          ],
        ),
        ),
      ),
      ),
      ),
    ));
  }

  Widget _buildTagEditor(BuildContext context, ColorScheme colorScheme) {
    return BlocBuilder<TagsBloc, TagsState>(
      bloc: getIt<TagsBloc>(),
      builder: (context, state) {
        if (state is TagsLoaded) {
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: state.tags.map((tag) {
              final isSelected = _selectedTagIds.contains(tag.id);
              return FilterChip(
                label: Text('#${tag.name}'),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedTagIds.add(tag.id);
                    } else {
                      _selectedTagIds.remove(tag.id);
                    }
                  });
                },
                selectedColor: colorScheme.secondaryContainer,
                checkmarkColor: colorScheme.onSecondaryContainer,
                labelStyle: TextStyle(
                  color: isSelected ? colorScheme.onSecondaryContainer : colorScheme.onSurfaceVariant,
                ),
              );
            }).toList(),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildContent(BuildContext context, ColorScheme colorScheme, bool isImage, bool isPdf) {
    if (widget.card.cardType == 'text') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withAlpha(128),
          borderRadius: BorderRadius.circular(12),
        ),
        child: _isEditing
            ? TextField(
                controller: _bodyController,
                maxLines: null,
                minLines: 3,
                decoration: InputDecoration(
                  hintText: 'Body content',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.all(12),
                ),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: 'JetBrains Mono',
                  color: colorScheme.onSurfaceVariant,
                ),
              )
            : Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 32.0),
                    child: Text(
                      widget.card.body ?? '',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontFamily: 'JetBrains Mono',
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Positioned(
                    top: -12,
                    right: -12,
                    child: IconButton(
                      icon: Icon(Icons.copy_rounded, size: 16, color: colorScheme.onSurfaceVariant),
                      tooltip: 'Copy text',
                      onPressed: () {
                        final textToCopy = widget.card.body ?? '';
                        if (textToCopy.isNotEmpty) {
                          Clipboard.setData(ClipboardData(text: textToCopy));
                          OmniToast.showInfo(context, 'Copied to clipboard');
                        }
                      },
                    ),
                  ),
                ],
              ),
      );
    } else if (widget.card.cardType == 'metadata') {
      if (_isEditing) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withAlpha(128),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _bodyController,
            maxLines: null,
            minLines: 3,
            decoration: InputDecoration(
              hintText: 'Link and notes...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.all(12),
            ),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontFamily: 'JetBrains Mono',
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        );
      }

      final bodyText = widget.card.body ?? '';
      final match = RegExp(r'(https?:\/\/[^\s]+|(?:www\.)[^\s]+)', caseSensitive: false).firstMatch(bodyText);
      String url = match?.group(0) ?? '';
      if (url.isNotEmpty && !url.startsWith('http')) {
        url = 'https://$url';
      }
      final userText = bodyText.replaceFirst(url, '').trim();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withAlpha(128),
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
                child: url.isNotEmpty && _metadataFuture != null
                ? FutureBuilder<Metadata?>(
                key: ValueKey(url),
                future: _metadataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      height: 250,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(color: colorScheme.onSurfaceVariant),
                    );
                  }

                  final metadata = snapshot.data;
                  if (metadata == null) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: InkWell(
                        onTap: () async {
                          final uri = Uri.tryParse(url);
                          if (uri != null && await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          }
                        },
                        child: Text(
                          url,
                          style: TextStyle(
                            color: colorScheme.primary,
                            decoration: TextDecoration.underline,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    );
                  }

                  final imageUrl = metadata.image;
                  final proxiedImageUrl = (kIsWeb && imageUrl != null && imageUrl.startsWith('http')) 
                      ? '${getIt<Dio>().options.baseUrl}/api/v1/proxy?url=${Uri.encodeComponent(imageUrl)}' 
                      : imageUrl;

                  return InkWell(
                    onTap: () async {
                      final uri = Uri.tryParse(url);
                      if (uri != null && await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (proxiedImageUrl != null)
                          Expanded(
                            child: Image.network(
                              proxiedImageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) => const SizedBox(),
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          color: colorScheme.surfaceContainerHighest.withAlpha(50),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                            Text(
                              metadata.title ?? url,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              metadata.desc ?? metadata.url ?? '',
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            )
          : const SizedBox(height: 100),
              ),
              if (!_isEditing)
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.surface.withAlpha(150),
                    ),
                    icon: Icon(Icons.copy_rounded, size: 16, color: colorScheme.onSurface),
                    tooltip: 'Copy link & notes',
                    onPressed: () {
                      final textToCopy = widget.card.body ?? '';
                      if (textToCopy.isNotEmpty) {
                        Clipboard.setData(ClipboardData(text: textToCopy));
                        OmniToast.showInfo(context, 'Copied to clipboard');
                      }
                    },
                  ),
                ),
            ],
          ),
          if (userText.isNotEmpty) ...[
            const SizedBox(height: 16),
            SelectableText(
              userText,
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ],
        ],
      );
    } else if (widget.card.cardType == 'file' && isImage) {
      return Container(
        height: 250,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withAlpha(128),
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: widget.card.gcsSignedUrl != null 
          ? OmniWebImage(
              imageUrl: widget.card.gcsSignedUrl!, 
              fit: BoxFit.cover,
              placeholder: (context, url) => Center(
                child: CircularProgressIndicator(
                  color: colorScheme.onSurfaceVariant.withAlpha(51),
                ),
              ),
              errorWidget: (context, url, error) => Icon(
                Icons.broken_image_rounded,
                size: 64,
                color: colorScheme.onSurfaceVariant.withAlpha(100),
              ),
            )
          : Center(
              child: Icon(
                Icons.image_rounded,
                size: 64,
                color: colorScheme.onSurfaceVariant.withAlpha(100),
              ),
            ),
      );
    } else if (widget.card.cardType == 'file' && isPdf) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withAlpha(128),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.tertiaryContainer.withAlpha(51),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.picture_as_pdf_rounded,
                  size: 48,
                  color: colorScheme.tertiary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'PDF Document',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.tertiary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withAlpha(128),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.tertiaryContainer.withAlpha(51),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.archive_rounded,
                color: colorScheme.tertiary,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                final url = widget.card.gcsSignedUrl;
                if (url != null) {
                  final uri = Uri.parse(url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  } else {
                    if (context.mounted) {
                      OmniToast.showError(context, 'Could not open file URL');
                    }
                  }
                }
              },
              icon: const Icon(Icons.download_rounded),
              label: const Text('Download File'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildChip(
    BuildContext context, 
    IconData icon, 
    String label, {
    Color? backgroundColor,
    Color? textColor,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: textColor ?? colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: textColor ?? colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

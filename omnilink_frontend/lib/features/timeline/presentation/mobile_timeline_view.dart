import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:omnilink_frontend/features/timeline/data/models/card_model.dart';
import 'package:omnilink_frontend/shared/widgets/omni_timeline_card.dart';
import '../../../shared/widgets/omni_top_bar.dart';
import '../../../shared/widgets/omni_drop_zone.dart';
import '../../../shared/widgets/omni_loaders.dart';
import '../../../shared/widgets/omni_tag_filter_row.dart';
import '../../../shared/widgets/omni_card_details_dialog.dart';
import '../../../shared/widgets/omni_text_field.dart';
import 'bloc/timeline_bloc.dart';
import 'bloc/timeline_state.dart';
import 'bloc/timeline_event.dart';
import 'bloc/tags_bloc.dart';
import 'bloc/tags_event.dart';
import 'package:desktop_drop/desktop_drop.dart';
import '../../../shared/widgets/omni_empty_state.dart';

class MobileTimelineView extends StatefulWidget {
  final bool showFavorites;
  const MobileTimelineView({super.key, this.showFavorites = false});

  @override
  State<MobileTimelineView> createState() => _MobileTimelineViewState();
}

class _MobileTimelineViewState extends State<MobileTimelineView> {
  String? _activeTagId;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool _isDragging = false;
  final GlobalKey<OmniDropZoneState> _dropZoneKey = GlobalKey<OmniDropZoneState>();
  final Set<String> _selectedCardIds = {};

  @override
  void initState() {
    super.initState();
    context.read<TimelineBloc>().add(TimelineLoadRequested(pinned: widget.showFavorites ? true : null));
    context.read<TagsBloc>().add(TagsLoadRequested());
  }

  @override
  void didUpdateWidget(MobileTimelineView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showFavorites != widget.showFavorites) {
      context.read<TimelineBloc>().add(TimelineLoadRequested(
        tagId: _activeTagId,
        searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
        pinned: widget.showFavorites ? true : null,
      ));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchQuery != query) {
        setState(() => _searchQuery = query);
        context.read<TimelineBloc>().add(TimelineLoadRequested(
          tagId: _activeTagId,
          searchQuery: query.isEmpty ? null : query,
          pinned: widget.showFavorites ? true : null,
        ));
      }
    });
  }

  TimelineCardType _mapCardType(CardModel card) {
    if (card.cardType == 'text') return TimelineCardType.code;
    if (card.cardType == 'metadata') return TimelineCardType.link;
    if (card.cardType == 'file') {
      final titleLower = card.title?.toLowerCase() ?? '';
      final isImage = card.mimeType?.startsWith('image/') == true || 
          titleLower.endsWith('.jpg') || titleLower.endsWith('.png') || titleLower.endsWith('.jpeg') || titleLower.endsWith('.webp');
      if (isImage) return TimelineCardType.image;

      final isPdf = card.mimeType == 'application/pdf' || titleLower.endsWith('.pdf');
      if (isPdf) return TimelineCardType.pdf;

      return TimelineCardType.file;
    }
    return TimelineCardType.code;
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'just now';
  }


  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const OmniTopBar(),
      body: DropTarget(
        onDragEntered: (detail) => setState(() => _isDragging = true),
        onDragExited: (detail) => setState(() => _isDragging = false),
        onDragDone: (detail) {
          setState(() => _isDragging = false);
          _dropZoneKey.currentState?.handleDroppedFiles(detail.files);
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: OmniTextField.search(
              controller: _searchController,
              hintText: 'Search cards, links, or files...',
              onChanged: _onSearchChanged,
            ),
          ),
          OmniTagFilterRow(
            activeTagId: _activeTagId,
            onTagSelected: (tagId) {
              setState(() => _activeTagId = tagId);
              context.read<TimelineBloc>().add(TimelineLoadRequested(
                tagId: tagId,
                searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
                pinned: widget.showFavorites ? true : null,
              ));
            },
          ),
          Expanded(
            child: Stack(
              children: [
                BlocBuilder<TimelineBloc, TimelineState>(
                  builder: (context, state) {
                    if (state is TimelineLoading || state is TimelineInitial) {
                      return const OmniSkeletonTimeline(isMobile: true);
                    } else if (state is TimelineError) {
                      return Center(child: Text(state.message));
                    } else if (state is TimelineLoaded) {
                      if (state.cards.isEmpty) {
                        return OmniEmptyState(
                          onAction: () {
                            _dropZoneKey.currentState?.focusTextField();
                          },
                        );
                      }
                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<TimelineBloc>().add(TimelineLoadRequested(
                            tagId: _activeTagId,
                            searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
                            pinned: widget.showFavorites ? true : null,
                          ));
                          await Future.delayed(const Duration(milliseconds: 800));
                        },
                        child: MasonryGridView.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          padding: const EdgeInsets.all(16.0).copyWith(bottom: 100),
                          itemCount: state.cards.length,
                          itemBuilder: (context, index) {
                            final card = state.cards[index];
                            return Hero(
                              tag: card.id,
                              child: Material(
                                type: MaterialType.transparency,
                                child: OmniTimelineCard(
                                  type: _mapCardType(card),
                                  cardId: card.id,
                                  title: card.title ?? card.body ?? 'Untitled',
                                  subtitle: card.fileSizeBytes != null ? '${(card.fileSizeBytes! / 1024).round()} KB' : 'Unknown',
                                  timeAgo: _timeAgo(card.updatedAt),
                                  tag: card.tags.isNotEmpty ? '#${card.tags.first.name}' : '#general',
                                  tagColor: colorScheme.secondary,
                                  body: card.body,
                                  imageUrl: card.gcsSignedUrl,
                                  isPinned: card.pinned,
                                  syncStatus: card.syncStatus,
                                  localBytes: card.localBytes,
                                  isSelected: _selectedCardIds.contains(card.id),
                                  onTogglePin: () {
                                    context.read<TimelineBloc>().add(TimelineTogglePinRequested(card));
                                  },
                                  onEdit: () {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => BlocProvider.value(
                                        value: context.read<TimelineBloc>(),
                                        child: OmniCardDetailsDialog(card: card, initialEditMode: true),
                                      ),
                                    );
                                  },
                                  onDelete: () {
                                    context.read<TimelineBloc>().add(TimelineDeleteCardsRequested([card.id]));
                                  },
                                  onLongPress: () {
                                    setState(() {
                                      if (_selectedCardIds.contains(card.id)) {
                                        _selectedCardIds.remove(card.id);
                                      } else {
                                        _selectedCardIds.add(card.id);
                                      }
                                    });
                                  },
                                  onTap: () {
                                    if (_selectedCardIds.isNotEmpty) {
                                      setState(() {
                                        if (_selectedCardIds.contains(card.id)) {
                                          _selectedCardIds.remove(card.id);
                                        } else {
                                          _selectedCardIds.add(card.id);
                                        }
                                      });
                                    } else {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => BlocProvider.value(
                                          value: context.read<TimelineBloc>(),
                                          child: OmniCardDetailsDialog(card: card, initialEditMode: false),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                if (!widget.showFavorites)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: OmniDropZone(key: _dropZoneKey),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
            if (_isDragging)
              Positioned.fill(
                child: Container(
                  color: Colors.white.withOpacity(0.85),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.cloud_upload_rounded, size: 64, color: colorScheme.primary),
                        const SizedBox(height: 16),
                        Text(
                          'Drop file to attach',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
            // Selection Action Bar
            if (_selectedCardIds.isNotEmpty)
              Positioned(
                bottom: 24,
                left: 16,
                right: 16,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(50),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${_selectedCardIds.length} selected',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 24),
                        IconButton(
                          onPressed: () {
                            context.read<TimelineBloc>().add(TimelineDeleteCardsRequested(_selectedCardIds.toList()));
                            setState(() {
                              _selectedCardIds.clear();
                            });
                          },
                          icon: Icon(Icons.delete_outline_rounded, color: colorScheme.error),
                          tooltip: 'Delete Selected',
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _selectedCardIds.clear();
                            });
                          },
                          icon: Icon(Icons.close_rounded, color: colorScheme.onSurfaceVariant),
                          tooltip: 'Cancel',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

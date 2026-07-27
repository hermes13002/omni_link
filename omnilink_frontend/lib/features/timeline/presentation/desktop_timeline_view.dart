import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:omnilink_frontend/features/timeline/data/models/card_model.dart';
import '../../../shared/widgets/omni_timeline_card.dart';
import '../../../shared/widgets/omni_inspector_panel.dart';
import '../../../shared/widgets/omni_loaders.dart';
import '../../../shared/widgets/omni_tag_filter_row.dart';
import '../../../shared/widgets/omni_card_details_dialog.dart';
import '../../../shared/widgets/omni_text_field.dart';
import 'bloc/timeline_bloc.dart';
import 'bloc/timeline_state.dart';
import 'bloc/timeline_event.dart';
import 'bloc/tags_bloc.dart';
import 'bloc/tags_event.dart';

class DesktopTimelineView extends StatefulWidget {
  final bool showFavorites;
  const DesktopTimelineView({super.key, this.showFavorites = false});

  @override
  State<DesktopTimelineView> createState() => _DesktopTimelineViewState();
}

class _DesktopTimelineViewState extends State<DesktopTimelineView> {
  String? _activeTagId;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    context.read<TimelineBloc>().add(TimelineLoadRequested(pinned: widget.showFavorites ? true : null));
    context.read<TagsBloc>().add(TagsLoadRequested());
  }

  @override
  void didUpdateWidget(DesktopTimelineView oldWidget) {
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
    if (card.cardType == 'metadata') return TimelineCardType.image;
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
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 24.0, top: 24.0, right: 24.0, bottom: 8.0),
                  child: Row(
                    children: [
                      Text(
                        'Timeline',
                        style: Theme.of(context).textTheme.displayLarge
                            ?.copyWith(
                              fontSize: 32,
                              color: colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: OmniTextField.search(
                          controller: _searchController,
                          hintText: 'Search cards, links, or files...',
                          onChanged: _onSearchChanged,
                        ),
                      ),

                    ],
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
                  child: BlocBuilder<TimelineBloc, TimelineState>(
                    builder: (context, state) {
                      if (state is TimelineLoading || state is TimelineInitial) {
                        return const Center(child: OmniDotsLoader());
                      } else if (state is TimelineError) {
                        return Center(child: Text(state.message));
                      } else if (state is TimelineLoaded) {
                        if (state.cards.isEmpty) {
                          return const Center(child: Text("No cards found"));
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
                            crossAxisCount: 3,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            padding: const EdgeInsets.all(24.0),
                            itemCount: state.cards.length,
                            itemBuilder: (context, index) {
                              final card = state.cards[index];
                              return OmniTimelineCard(
                                type: _mapCardType(card),
                                cardId: card.id,
                                title: card.title ?? card.body ?? 'Untitled',
                                subtitle: card.fileSizeBytes != null ? '${(card.fileSizeBytes! / 1024).round()} KB' : 'Unknown',
                                timeAgo: _timeAgo(card.createdAt),
                                tag: card.tags.isNotEmpty ? '#${card.tags.first.name}' : '#general',
                                tagColor: colorScheme.secondary,
                                body: card.body,
                                imageUrl: card.gcsSignedUrl,
                                isPinned: card.pinned,
                                onTogglePin: () {
                                  context.read<TimelineBloc>().add(TimelineTogglePinRequested(card));
                                },
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => OmniCardDetailsDialog(card: card),
                                  );
                                },
                              );
                            },
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
          Flexible(flex: 1, child: OmniInspectorPanel(showFavorites: widget.showFavorites)),
        ],
      ),
    );
  }
}

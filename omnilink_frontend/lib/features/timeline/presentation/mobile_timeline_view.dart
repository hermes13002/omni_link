import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../shared/widgets/omni_top_bar.dart';
import '../../../shared/widgets/omni_bottom_nav.dart';
import '../../../shared/widgets/omni_filter_chip.dart';
import '../../../shared/widgets/omni_timeline_card.dart';
import '../../../shared/widgets/omni_drop_zone.dart';
import 'bloc/timeline_bloc.dart';
import 'bloc/timeline_state.dart';
import 'bloc/timeline_event.dart';

class MobileTimelineView extends StatefulWidget {
  const MobileTimelineView({super.key});

  @override
  State<MobileTimelineView> createState() => _MobileTimelineViewState();
}

class _MobileTimelineViewState extends State<MobileTimelineView> {
  @override
  void initState() {
    super.initState();
    context.read<TimelineBloc>().add(const TimelineLoadRequested());
  }

  TimelineCardType _mapCardType(String cardType) {
    if (cardType == 'text') return TimelineCardType.code;
    if (cardType == 'metadata') return TimelineCardType.image;
    return TimelineCardType.file;
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
      appBar: const OmniTopBar(),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                OmniFilterChip(
                  label: 'All Stream',
                  isActive: true,
                  onTap: () {},
                ),
                const SizedBox(width: 8),
                OmniFilterChip(
                  label: '#work',
                  onTap: () {},
                ),
                const SizedBox(width: 8),
                OmniFilterChip(
                  label: '#personal',
                  onTap: () {},
                ),
                const SizedBox(width: 8),
                OmniFilterChip(
                  label: 'MacBook Pro',
                  icon: Icons.laptop,
                  onTap: () {},
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                BlocBuilder<TimelineBloc, TimelineState>(
                  builder: (context, state) {
                    if (state is TimelineLoading || state is TimelineInitial) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is TimelineError) {
                      return Center(child: Text(state.message));
                    } else if (state is TimelineLoaded) {
                      if (state.cards.isEmpty) {
                        return const Center(child: Text("No cards found"));
                      }
                      return MasonryGridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        padding: const EdgeInsets.all(16.0).copyWith(bottom: 100),
                        itemCount: state.cards.length,
                        itemBuilder: (context, index) {
                          final card = state.cards[index];
                          return OmniTimelineCard(
                            type: _mapCardType(card.cardType),
                            title: card.title ?? card.body ?? 'Untitled',
                            subtitle: card.fileSizeBytes != null ? '${(card.fileSizeBytes! / 1024).round()} KB' : 'Unknown',
                            timeAgo: _timeAgo(card.createdAt),
                            tag: card.tags.isNotEmpty ? '#${card.tags.first.name}' : '#general',
                            tagColor: colorScheme.secondary,
                          );
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: OmniDropZone(),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const OmniBottomNav(),
    );
  }
}

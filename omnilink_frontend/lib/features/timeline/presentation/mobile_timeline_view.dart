import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../shared/widgets/omni_top_bar.dart';
import '../../../shared/widgets/omni_bottom_nav.dart';
import '../../../shared/widgets/omni_filter_chip.dart';
import '../../../shared/widgets/omni_timeline_card.dart';
import '../../../shared/widgets/omni_drop_zone.dart';

class MobileTimelineView extends StatelessWidget {
  const MobileTimelineView({super.key});

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
                  icon: LucideIcons.laptop,
                  onTap: () {},
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                MasonryGridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  padding: const EdgeInsets.all(16.0).copyWith(bottom: 100),
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return OmniTimelineCard(
                        type: TimelineCardType.code,
                        title: 'API_Notes.txt',
                        subtitle: '12.4 KB',
                        timeAgo: '2m ago',
                        tag: '#work',
                        tagColor: colorScheme.secondary,
                      );
                    } else if (index == 1) {
                      return OmniTimelineCard(
                        type: TimelineCardType.image,
                        title: 'Database_Schema_v2.png',
                        subtitle: '4.2 MB',
                        timeAgo: '15m ago',
                        tag: '#design',
                        tagColor: colorScheme.tertiary,
                      );
                    } else if (index == 2) {
                      return OmniTimelineCard(
                        type: TimelineCardType.file,
                        title: 'release-v2.1.apk',
                        subtitle: '45.2 MB',
                        timeAgo: '3h ago',
                        tag: '#build',
                        tagColor: colorScheme.tertiary,
                      );
                    } else {
                      return OmniTimelineCard(
                        type: TimelineCardType.image,
                        title: 'abstract_bg_v2.png',
                        subtitle: '1.2 MB',
                        timeAgo: '1d ago',
                        tag: '#design',
                      );
                    }
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

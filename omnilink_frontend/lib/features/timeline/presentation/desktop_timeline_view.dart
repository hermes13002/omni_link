import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../shared/widgets/omni_side_nav.dart';
import '../../../shared/widgets/omni_timeline_card.dart';
import '../../../shared/widgets/omni_inspector_panel.dart';

class DesktopTimelineView extends StatelessWidget {
  const DesktopTimelineView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Row(
        children: [
          const OmniSideNav(),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
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
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          LucideIcons.filter,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          LucideIcons.layoutGrid,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: MasonryGridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 8.0,
                    ),
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
                ),
              ],
            ),
          ),
          const Flexible(flex: 1, child: OmniInspectorPanel()),
        ],
      ),
    );
  }
}

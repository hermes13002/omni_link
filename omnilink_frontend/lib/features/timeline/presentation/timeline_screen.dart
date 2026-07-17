import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'desktop_timeline_view.dart';
import 'mobile_timeline_view.dart';

class TimelineScreen extends StatelessWidget {
  final bool showFavorites;
  const TimelineScreen({super.key, this.showFavorites = false});

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (BuildContext context) => MobileTimelineView(showFavorites: showFavorites),
      tablet: (BuildContext context) => DesktopTimelineView(showFavorites: showFavorites),
      desktop: (BuildContext context) => DesktopTimelineView(showFavorites: showFavorites),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'desktop_timeline_view.dart';
import 'mobile_timeline_view.dart';

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (BuildContext context) => const MobileTimelineView(),
      tablet: (BuildContext context) => const DesktopTimelineView(),
      desktop: (BuildContext context) => const DesktopTimelineView(),
    );
  }
}

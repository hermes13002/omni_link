import 'package:go_router/go_router.dart';
import '../../features/timeline/presentation/timeline_screen.dart';

final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const TimelineScreen(),
    ),
  ],
);

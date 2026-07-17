import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/timeline/presentation/timeline_screen.dart';
import '../../features/timeline/presentation/bloc/timeline_bloc.dart';
import '../../features/timeline/presentation/bloc/tags_bloc.dart';
import '../../features/device/presentation/bloc/device_bloc.dart';
import '../../features/device/presentation/bloc/device_event.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../network/sse_client.dart';
import '../di/injection.dart';
import 'go_router_refresh_stream.dart';

GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state;
      final isGoingToAuth = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      if (authState is AuthInitial) {
        if (state.matchedLocation == '/splash') return null;
        return '/splash';
      }

      if (authState is AuthLoading) {
        // do not redirect on loading so inline loaders (like OmniButton's) can be seen.
        return null;
      }

      if (authState is AuthUnauthenticated || authState is AuthError) {
        if (!isGoingToAuth) return '/login';
        return null;
      }

      if (authState is AuthAuthenticated) {
        if (isGoingToAuth || state.matchedLocation == '/splash') return '/';
        return null;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) {
          final deviceBloc = getIt<DeviceBloc>();
          // Only trigger auto-register once.
          deviceBloc.add(DeviceAutoRegisterRequested());
          
          // Connect to SSE stream
          getIt<SseClient>().connect();
          
          return MultiBlocProvider(
            providers: [
              BlocProvider.value(value: getIt<TimelineBloc>()),
              BlocProvider.value(value: getIt<TagsBloc>()),
              BlocProvider.value(value: deviceBloc),
            ],
            child: const TimelineScreen(showFavorites: false),
          );
        },
      ),
      GoRoute(
        path: '/favorites',
        builder: (context, state) {
          final deviceBloc = getIt<DeviceBloc>();
          // Connect to SSE stream
          getIt<SseClient>().connect();
          
          return MultiBlocProvider(
            providers: [
              BlocProvider.value(value: getIt<TimelineBloc>()),
              BlocProvider.value(value: getIt<TagsBloc>()),
              BlocProvider.value(value: deviceBloc),
            ],
            child: const TimelineScreen(showFavorites: true),
          );
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: getIt<DeviceBloc>()),
            BlocProvider.value(value: getIt<TagsBloc>()),
          ],
          child: const SettingsScreen(),
        ),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: getIt<DeviceBloc>()),
            BlocProvider.value(value: getIt<TimelineBloc>()),
          ],
          child: const ProfileScreen(),
        ),
      ),
    ],
  );
}

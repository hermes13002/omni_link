import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/screens/admin_login_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/presentation/bloc/admin_bloc.dart';
import '../di/injection.dart';
import 'go_router_refresh_stream.dart';

import '../globals.dart';

GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/admin-portal',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state;
      final isGoingToAdminPortal = state.matchedLocation == '/admin-portal';

      if (authState is AuthInitial || authState is AuthLoading) {
        return null;
      }

      if (authState is AuthUnauthenticated || authState is AuthError) {
        if (!isGoingToAdminPortal) return '/admin-portal';
        return null;
      }

      if (authState is AuthAuthenticated) {
        if (isGoingToAdminPortal) return '/admin/dashboard';
        return null;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/admin-portal',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<AdminBloc>(),
          child: const AdminDashboardScreen(),
        ),
      ),
    ],
  );
}

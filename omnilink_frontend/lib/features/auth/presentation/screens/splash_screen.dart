import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:omnilink_frontend/core/di/injection.dart';
import 'package:omnilink_frontend/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:omnilink_frontend/features/auth/presentation/bloc/auth_state.dart';
import 'package:omnilink_frontend/features/device/presentation/bloc/device_bloc.dart';
import 'package:omnilink_frontend/features/device/presentation/bloc/device_event.dart';
import 'package:omnilink_frontend/features/timeline/presentation/bloc/tags_bloc.dart';
import 'package:omnilink_frontend/features/timeline/presentation/bloc/tags_event.dart';
import 'package:omnilink_frontend/features/timeline/presentation/bloc/timeline_bloc.dart';
import 'package:omnilink_frontend/features/timeline/presentation/bloc/timeline_event.dart';
import 'package:omnilink_frontend/features/timeline/presentation/bloc/timeline_state.dart';
import 'package:omnilink_frontend/shared/widgets/omni_loaders.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isFetchingData = false;

  void _handleAuth(AuthState state) async {
    if (state is AuthAuthenticated && !_isFetchingData) {
      setState(() => _isFetchingData = true);
      
      final timelineBloc = getIt<TimelineBloc>();
      timelineBloc.add(const TimelineLoadRequested());
      getIt<TagsBloc>().add(TagsLoadRequested());
      getIt<DeviceBloc>().add(DevicesLoadRequested());
      
      await timelineBloc.stream.firstWhere((s) => s is TimelineLoaded || s is TimelineError);
      
      if (mounted) {
        context.go('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) => _handleAuth(state),
      child: const Scaffold(
        body: Center(
          child: OmniLogoLoader(size: 120),
        ),
      ),
    );
  }
}

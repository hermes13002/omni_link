import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omnilink_frontend/core/globals.dart';
import 'core/di/injection.dart';
import 'core/routing/router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import 'features/auth/data/auth_api.dart';
import 'core/globals.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await configureDependencies();
  
  runApp(const OmniLinkApp());
}

class OmniLinkApp extends StatefulWidget {
  const OmniLinkApp({super.key});

  @override
  State<OmniLinkApp> createState() => _OmniLinkAppState();
}

class _OmniLinkAppState extends State<OmniLinkApp> {
  late final AuthBloc _authBloc;
  late final ThemeCubit _themeCubit;
  late final RouterConfig<Object> _router;

  @override
  void initState() {
    super.initState();
    _authBloc = getIt<AuthBloc>()..add(AuthCheckRequested());
    _themeCubit = getIt<ThemeCubit>();
    _router = createRouter(_authBloc);

    _runSecurityChecks();
  }

  Future<void> _runSecurityChecks() async {
    if (kIsWeb) return;
    
    bool jailbroken = false;
    try {
      jailbroken = await FlutterJailbreakDetection.jailbroken;
    } catch (e) {
      // ignore
    }
    
    if (jailbroken) {
      try {
        final authApi = getIt<AuthApi>();
        await authApi.securityAlert(
          'JAILBREAK_DETECTED', 
          'User device is jailbroken or rooted.',
          null,
        );
      } catch (e) {
        // Ignore if user is not logged in yet or offline
      }
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final context = navigatorKey.currentContext;
        if (context != null) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Security Warning'),
              content: const Text('Your device appears to be rooted or jailbroken. This activity has been reported to the administrator.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Dismiss'),
                ),
              ],
            ),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _authBloc.close();
    _themeCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        BlocProvider.value(value: _themeCubit),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            title: 'OmniLink',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            scaffoldMessengerKey: scaffoldMessengerKey,
            routerConfig: _router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

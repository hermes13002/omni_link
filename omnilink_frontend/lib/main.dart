import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection.dart';
import 'core/routing/router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';

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
  late final RouterConfig<Object> _router;

  @override
  void initState() {
    super.initState();
    _authBloc = getIt<AuthBloc>()..add(AuthCheckRequested());
    _router = createRouter(_authBloc);
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
      ],
      child: MaterialApp.router(
        title: 'OmniLink',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        scaffoldMessengerKey: scaffoldMessengerKey,
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

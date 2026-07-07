import 'package:flutter/material.dart';
import 'core/di/injection.dart';
import 'core/routing/router.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  runApp(const OmniLinkApp());
}

class OmniLinkApp extends StatelessWidget {
  const OmniLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'OmniLink',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Keep dark mode as default
      routerConfig: goRouter,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:qurban_kit/core/services/service_locator.dart';
import 'core/configs/theme/app_theme.dart';
import 'presentation/splash/pages/splash.dart';
import 'presentation/auth/pages/auth.dart';
import 'presentation/home/pages/home.dart';

void main() {
  setupServiceLocator();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashPage(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/auth':
            return MaterialPageRoute(
              builder: (context) => const AuthPage(),
              settings: settings,
            );
          case '/home':
            return MaterialPageRoute(
              builder: (context) => const HomePage(),
              settings: settings,
            );
          default:
            return null;
        }
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:qurban_kit/core/services/service_locator.dart';
import 'package:qurban_kit/presentation/mosque_registration/pages/mosque_registration_page.dart';
import 'package:qurban_kit/presentation/mosque_dashboard/pages/mosque_waiting_dashboard.dart';
import 'package:qurban_kit/presentation/admin_dashboard/pages/verification_list_page.dart';
import 'package:qurban_kit/presentation/admin_dashboard/pages/verification_detail_page.dart';
import 'package:qurban_kit/presentation/admin_dashboard/pages/takedown_page.dart';
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
          case '/mosque-registration':
            return MaterialPageRoute(
              builder: (context) => const MosqueRegistrationPage(),
              settings: settings,
            );
          case '/mosque-dashboard-waiting':
            return MaterialPageRoute(
              builder: (context) => const MosqueWaitingDashboard(),
              settings: settings,
            );
          case '/admin-dashboard':
            return MaterialPageRoute(
              builder: (context) => const VerificationListPage(),
              settings: settings,
            );
          case '/admin-detail':
            return MaterialPageRoute(
              builder: (context) => const VerificationDetailPage(),
              settings: settings,
            );
          case '/admin-takedown':
            return MaterialPageRoute(
              builder: (context) => const TakedownPage(),
              settings: settings,
            );
          default:
            return null;
        }
      },
    );
  }
}

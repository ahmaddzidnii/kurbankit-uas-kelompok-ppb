import 'package:flutter/material.dart';
import 'package:qurban_kit/app_router.dart';
import 'package:qurban_kit/core/services/service_locator.dart';
import 'core/configs/theme/app_theme.dart';

void main() {
  setupServiceLocator();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}

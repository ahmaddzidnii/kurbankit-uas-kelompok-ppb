// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:qurban_kit/presentation/onboarding/pages/onboarding.dart';
import 'package:qurban_kit/presentation/auth/pages/auth.dart';
import 'package:qurban_kit/core/configs/theme/theme.dart';
import 'package:qurban_kit/core/services/onboarding_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
    _redirectToNextPage(context);
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = 'Version ${packageInfo.version}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Spacer atas
              const Spacer(flex: 2),

              // Logo di tengah
              Image.asset('assets/images/logo.png', width: 256, height: 256),

              // Spacer bawah
              const Spacer(flex: 3),

              // Version dan Deskripsi di bawah
              Column(
                children: [
                  // Version
                  Text(
                    _version,
                    style: const TextStyle(
                      fontSize: AppTypography.bodyMedium,
                      fontWeight: AppTypography.bold,
                      color: AppColors.textBase,
                    ),
                  ),

                  AppSpacing.vSpaceXs,

                  // Deskripsi
                  const Text(
                    'Hitung dan kelola pembagian qurban dengan\nmudah.',
                    style: TextStyle(
                      fontSize: AppTypography.bodyMedium,
                      color: AppColors.textSubdued,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  AppSpacing.vSpaceMd,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Determine next page based on onboarding and login status
/// - New user → Onboarding
/// - Not new & logged in → Home (TODO: navigate to home page)
/// - Not new & not logged in → Auth
Future<void> _redirectToNextPage(BuildContext context) async {
  await Future.delayed(const Duration(seconds: 4)); // Splash duration

  final isNewUser = await OnboardingService.isNewUser();
  final isLoggedIn = await OnboardingService.isUserLoggedIn();

  Widget nextPage;

  if (isNewUser) {
    // Show onboarding for new users
    nextPage = const OnboardingPage();
  } else {
    // User has completed onboarding
    if (isLoggedIn) {
      // TODO: Replace dengan route ke home page sesuai struktur app Anda
      // nextPage = const HomePage();
      nextPage = const AuthPage(); // Temporary, replace with HomePage
    } else {
      // Show auth page if not logged in
      nextPage = const AuthPage();
    }
  }

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => nextPage),
  );
}

// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:qurban_kit/presentation/onboarding/pages/onboarding.dart';
import 'package:qurban_kit/core/configs/theme/theme.dart';
import 'package:qurban_kit/core/services/onboarding_service.dart';
import 'package:qurban_kit/core/services/service_locator.dart';
import 'package:qurban_kit/core/services/user_role_service.dart';

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

              // Loading Indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.essentialBrightAccent,
                ),
                strokeWidth: 3,
              ),

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
/// - Not new & logged in → Role-based routing:
///   - SUPER_ADMIN → Admin Dashboard (verification)
///   - ADMIN_MASJID (not registered) → Mosque Registration Form
///   - ADMIN_MASJID (registered) → Mosque Waiting Dashboard
/// - Not new & not logged in → Auth
Future<void> _redirectToNextPage(BuildContext context) async {
  await Future.delayed(const Duration(seconds: 4)); // Splash duration

  final isNewUser = await OnboardingService.isNewUser();
  final isLoggedIn = await OnboardingService.isUserLoggedIn();

  String? nextRoute;

  if (isNewUser) {
    // Show onboarding for new users
    nextRoute = '/onboarding';
  } else {
    // User has completed onboarding
    if (isLoggedIn) {
      // Try to restore token from secure storage
      final tokenRestored = await authRepository.restoreToken();

      if (tokenRestored) {
        // Token restored, try to fetch profile
        try {
          final user = await authRepository.getProfile();

          if (user != null) {
            // Save role for future reference
            if (user.role != null) {
              await UserRoleService.setUserRole(user.role!);
            }

            // Route based on role
            final userRole = await UserRoleService.getUserRole();

            if (userRole == 'SUPER_ADMIN') {
              nextRoute = '/admin-dashboard';
            } else if (userRole == 'ADMIN_MASJID') {
              final isMosqueRegistered =
                  await UserRoleService.isMosqueRegistered();
              if (isMosqueRegistered) {
                nextRoute = '/mosque-dashboard-waiting';
              } else {
                nextRoute = '/mosque-registration';
              }
            } else {
              // Default to home if role is unknown
              nextRoute = '/home';
            }
          } else {
            // Profile fetch returned null, show auth page
            await authRepository.clearTokens();
            await OnboardingService.setLoginStatus(false);
            nextRoute = '/auth';
          }
        } catch (e) {
          print('Error fetching profile: $e');
          // Token invalid, show auth page
          await authRepository.clearTokens();
          await OnboardingService.setLoginStatus(false);
          nextRoute = '/auth';
        }
      } else {
        // No token found, show auth page
        await OnboardingService.setLoginStatus(false);
        nextRoute = '/auth';
      }
    } else {
      // Show auth page if not logged in
      nextRoute = '/auth';
    }
  }

  if (context.mounted && nextRoute != null) {
    if (nextRoute == '/onboarding') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingPage()),
      );
    } else {
      Navigator.pushReplacementNamed(context, nextRoute);
    }
  }
}

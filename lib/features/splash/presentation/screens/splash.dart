// Removed use_build_context_synchronously by ensuring navigation checks `mounted`.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:qurban_kit/core/services/post_login_route_service.dart';
import 'package:qurban_kit/features/auth/data/models/auth_models.dart';
import 'package:qurban_kit/core/configs/theme/theme.dart';
import 'package:qurban_kit/core/services/onboarding_service.dart';
import 'package:qurban_kit/core/services/service_locator.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _redirectToNextPage();
    });
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = 'Version ${packageInfo.version}';
    });
  }

  Future<void> _redirectToNextPage() async {
    await Future.delayed(const Duration(seconds: 4)); // Splash duration

    final isNewUser = await OnboardingService.isNewUser();
    final isLoggedIn = await OnboardingService.isUserLoggedIn();

    String? nextRoute;
    UserData? profileUser;

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
              profileUser = user;
              await PostLoginRouteService.syncUserState(user);
              nextRoute = PostLoginRouteService.resolveRoute(user);
            } else {
              // Profile fetch returned null, show auth page
              await authRepository.clearTokens();
              await OnboardingService.setLoginStatus(false);
              nextRoute = '/auth';
            }
          } catch (e) {
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

    if (!mounted) return;
    if (nextRoute != null) {
      if (nextRoute == '/mosque-registration-rejected' &&
          profileUser?.masjid != null) {
        context.go(nextRoute, extra: profileUser!.masjid);
        return;
      }

      context.go(nextRoute);
    }
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

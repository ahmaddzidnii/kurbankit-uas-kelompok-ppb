// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:qurban_kit/presentation/onboarding/pages/onboarding.dart';
import 'package:qurban_kit/core/configs/theme/theme.dart';

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
    redirectToHome(context);
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

Future<void> redirectToHome(BuildContext context) async {
  await Future.delayed(const Duration(seconds: 4)); // Simulasi loading
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const OnboardingPage()),
  );
}

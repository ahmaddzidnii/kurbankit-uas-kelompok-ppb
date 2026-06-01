import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qurban_kit/core/configs/theme/theme.dart';
import 'package:qurban_kit/core/services/service_locator.dart';
import 'package:qurban_kit/core/services/user_role_service.dart';

class MosqueAccountSuspendedPage extends StatelessWidget {
  const MosqueAccountSuspendedPage({super.key});

  Future<void> _logout(BuildContext context) async {
    await authRepository.logout();
    await UserRoleService.clearUserRoleData();

    if (context.mounted) {
      context.go('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBase,
      appBar: AppBar(
        backgroundColor: AppColors.essentialBrightAccent,
        foregroundColor: Colors.white,
        title: const Text('Akun Ditangguhkan'),
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.backgroundElevatedBase,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.backgroundHighlight),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.block, size: 44, color: Colors.red),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Text(
                    'Akun Anda Ditangguhkan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppTypography.headingMedium,
                      fontWeight: AppTypography.semiBold,
                      color: AppColors.textBase,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'Akses admin masjid Anda sementara dinonaktifkan. Silakan hubungi tim Super Admin untuk mengetahui detail dan langkah selanjutnya.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppTypography.bodyMedium,
                      color: AppColors.textSubdued,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => _logout(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.essentialBrightAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                      ),
                      child: const Text('Keluar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

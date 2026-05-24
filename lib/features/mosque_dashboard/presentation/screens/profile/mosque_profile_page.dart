import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qurban_kit/core/configs/theme/theme.dart';
import 'package:qurban_kit/core/services/service_locator.dart';
import 'package:qurban_kit/core/services/user_role_service.dart';
import 'package:qurban_kit/features/auth/data/models/auth_models.dart';

class MosqueProfilePage extends StatelessWidget {
  final UserData? user;

  const MosqueProfilePage({super.key, this.user});

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            child: const Text('Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await authRepository.logout();
      await UserRoleService.clearUserRoleData();
      if (context.mounted) {
        context.go('/auth');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = user?.name ?? 'Ahmad Suherman';
    final displayEmail = user?.email ?? 'ahmad.suherman@masjidalihsan.org';
    final role = user?.role == 'ADMIN_MASJID' ? 'Mosque Admin' : 'User';

    return Scaffold(
      backgroundColor: AppColors.backgroundBase,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundBase,
        elevation: 0,

        title: const Text(
          'Informasi Profil',
          style: TextStyle(
            color: AppColors.textBase,
            fontSize: AppTypography.headingMedium,
            fontWeight: AppTypography.semiBold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppSpacing.md),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 128,
                    height: 128,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.backgroundElevatedBase,
                        width: 4,
                      ),
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.essentialBrightAccent,
                          Color(0xFF0C6F67),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        displayName.isNotEmpty
                            ? displayName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: AppTypography.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                displayName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: AppTypography.displaySmall,
                  fontWeight: AppTypography.bold,
                  color: AppColors.textBase,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.essentialBrightAccent.withValues(
                    alpha: 0.12,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Text(
                  role,
                  style: const TextStyle(
                    color: AppColors.essentialBrightAccent,
                    fontWeight: AppTypography.medium,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _buildInfoCard(
                icon: Icons.person_rounded,
                title: 'Informasi Pribadi',
                children: [
                  _buildInfoRow('Nama', displayName),
                  const SizedBox(height: AppSpacing.md),
                  _buildInfoRow('Email', displayEmail),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildInfoCard(
                icon: Icons.mosque_rounded,
                title: 'Informasi Masjid',
                children: [
                  _buildInfoRow('Nama', 'Masjid Al-Ihsan'),
                  const SizedBox(height: AppSpacing.md),
                  _buildInfoRow('Alamat', 'Jl. Merdeka No.123, Jakarta'),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _logout(context),
                  icon: const Icon(Icons.logout_rounded, color: Colors.red),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: AppTypography.bodyLarge,
                      fontWeight: AppTypography.semiBold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFE3E3),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.backgroundElevatedBase,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.decorativeSubdued),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Icon(
                  icon,
                  size: 20,
                  color: AppColors.essentialBrightAccent,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: const TextStyle(
                  fontSize: AppTypography.headingSmall,
                  fontWeight: AppTypography.semiBold,
                  color: AppColors.textBase,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: AppTypography.labelSmall,
            letterSpacing: 1,
            color: AppColors.textSubdued,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: const TextStyle(
            fontSize: AppTypography.bodyMedium,
            fontWeight: AppTypography.semiBold,
            color: AppColors.textBase,
          ),
        ),
      ],
    );
  }
}

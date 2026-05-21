import 'package:flutter/material.dart';
import 'package:qurban_kit/core/configs/theme/theme.dart';
import 'package:qurban_kit/features/auth/data/models/auth_models.dart';

class AdminProfileTab extends StatelessWidget {
  final Future<UserData?> profileFuture;
  final VoidCallback onLogout;

  const AdminProfileTab({
    super.key,
    required this.profileFuture,
    required this.onLogout,
  });

  String _formatRole(String? role) {
    switch (role?.toUpperCase()) {
      case 'SUPER_ADMIN':
        return 'Platform Moderator';
      default:
        return role?.replaceAll('_', ' ') ?? 'Platform Moderator';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserData?>(
      future: profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _EmptyState(
            icon: Icons.error_outline,
            title: 'Gagal memuat profil',
            subtitle: snapshot.error.toString(),
          );
        }

        final user = snapshot.data;
        final displayName = user?.name.isNotEmpty == true
            ? user!.name
            : 'Super Admin';
        final displayEmail = user?.email.isNotEmpty == true ? user!.email : '-';
        final displayRole = _formatRole(user?.role);

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.essentialBrightAccent,
                        AppColors.essentialBrightAccent.withOpacity(0.75),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.essentialBrightAccent.withOpacity(
                          0.18,
                        ),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      displayName.isNotEmpty
                          ? displayName[0].toUpperCase()
                          : 'S',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: AppTypography.bold,
                      ),
                    ),
                  ),
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
                    displayRole,
                    style: const TextStyle(
                      color: AppColors.essentialBrightAccent,
                      fontWeight: AppTypography.medium,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                _ProfileInfoCard(
                  icon: Icons.person_outline_rounded,
                  title: 'Informasi Akun',
                  children: [
                    _ProfileInfoRow(label: 'Nama', value: displayName),
                    const SizedBox(height: AppSpacing.md),
                    _ProfileInfoRow(label: 'Email', value: displayEmail),
                    const SizedBox(height: AppSpacing.md),
                    _ProfileInfoRow(label: 'Role', value: displayRole),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onLogout,
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
        );
      },
    );
  }
}

class _ProfileInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _ProfileInfoCard({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
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
              Icon(icon, color: AppColors.essentialBrightAccent),
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
}

class _ProfileInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
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
            fontWeight: AppTypography.medium,
            color: AppColors.textBase,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.textSubdued.withOpacity(0.45),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: AppTypography.bodyLarge,
                fontWeight: AppTypography.semiBold,
                color: AppColors.textBase,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: AppTypography.bodySmall,
                color: AppColors.textSubdued,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

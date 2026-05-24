import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qurban_kit/core/configs/theme/theme.dart';
import 'package:qurban_kit/core/services/service_locator.dart';
import 'package:qurban_kit/core/services/user_role_service.dart';
import 'package:qurban_kit/features/auth/data/models/auth_models.dart';
import 'package:qurban_kit/features/mosque_dashboard/presentation/screens/profile/mosque_profile_page.dart';

class AdminHomePage extends StatefulWidget {
  final UserData? user;

  const AdminHomePage({super.key, this.user});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  late UserData? _user;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  Future<void> _logout() async {
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
      if (mounted) {
        await authRepository.logout();
        await UserRoleService.clearUserRoleData();
        context.go('/auth');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBase,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with greeting and profile
                _buildHeader(),
                const SizedBox(height: AppSpacing.xl),

                // Active period card
                _buildActivePeriodCard(),
                const SizedBox(height: AppSpacing.xl),

                // Statistics cards
                _buildStatisticsSection(),
                const SizedBox(height: AppSpacing.xl),

                // Quick actions
                _buildQuickActionsSection(),
                const SizedBox(height: AppSpacing.xl),

                // Recent activity
                _buildRecentActivitySection(),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat Pagi,',
                style: TextStyle(
                  fontSize: AppTypography.bodySmall,
                  color: AppColors.textSubdued,
                  fontWeight: AppTypography.regular,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                _user?.name ?? 'Admin Masjid',
                style: const TextStyle(
                  fontSize: AppTypography.headingLarge,
                  fontWeight: AppTypography.bold,
                  color: AppColors.textBase,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            // Profile avatar
            GestureDetector(
              onTap: () {
                context.push('/mosque-profile', extra: _user);
              },
              onLongPress: _logout,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.essentialBrightAccent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.essentialBrightAccent.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    (_user?.name ?? 'A')[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: AppTypography.bold,
                      fontSize: AppTypography.headingSmall,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivePeriodCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.essentialBrightAccent,
            AppColors.essentialBrightAccent.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.essentialBrightAccent.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with period label
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Text(
                  'Periode Aktif',
                  style: TextStyle(
                    fontSize: AppTypography.labelSmall,
                    fontWeight: AppTypography.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Icon(Icons.calendar_today_rounded, color: Colors.white, size: 20),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Period name
          const Text(
            'Idul Adha 1447 H',
            style: TextStyle(
              fontSize: AppTypography.displaySmall,
              fontWeight: AppTypography.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Progress section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Progress: 325/500 Mustahiq',
                    style: TextStyle(
                      fontSize: AppTypography.bodyMedium,
                      fontWeight: AppTypography.medium,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    '65%',
                    style: TextStyle(
                      fontSize: AppTypography.bodyMedium,
                      fontWeight: AppTypography.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: LinearProgressIndicator(
                  value: 0.65,
                  minHeight: 8,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Days remaining
          Row(
            children: [
              const Text(
                '27 Mei 2024 - 1447 H',
                style: TextStyle(
                  fontSize: AppTypography.bodyMedium,
                  fontWeight: AppTypography.medium,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return _buildCompactStatisticCard(
      icon: Icons.people_rounded,
      title: 'Total recipients',
      value: '1,248',
      subtitle: 'Seluruh mustahiq terdaftar',
      backgroundColor: AppColors.essentialBrightAccent.withOpacity(0.1),
      iconColor: AppColors.essentialBrightAccent,
    );
  }

  Widget _buildCompactStatisticCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.backgroundElevatedBase,
        border: Border.all(color: AppColors.decorativeSubdued, width: 1),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: AppTypography.labelMedium,
                    fontWeight: AppTypography.semiBold,
                    color: AppColors.textSubdued,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: AppTypography.bodySmall,
                    color: AppColors.textSubdued,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            value,
            style: const TextStyle(
              fontSize: AppTypography.headingLarge,
              fontWeight: AppTypography.bold,
              color: AppColors.textBase,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticCard({
    required IconData icon,
    required String title,
    required String value,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.backgroundElevatedBase,
        border: Border.all(color: AppColors.decorativeSubdued, width: 1),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: TextStyle(
              fontSize: AppTypography.labelSmall,
              fontWeight: AppTypography.semiBold,
              color: AppColors.textSubdued,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: const TextStyle(
              fontSize: AppTypography.displaySmall,
              fontWeight: AppTypography.bold,
              color: AppColors.textBase,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: AppTypography.headingMedium,
            fontWeight: AppTypography.semiBold,
            color: AppColors.textBase,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Column(
          children: [
            _buildActionButton(
              icon: Icons.person_add_rounded,
              label: 'Add Recipient',
              description: 'Masukkan mustahiq baru ke data distribusi',
              onTap: () {
                context.push('/mosque-recipient-form');
              },
            ),
            const SizedBox(height: AppSpacing.md),
            _buildActionButton(
              icon: Icons.calculate_rounded,
              label: 'Calculate Qurban',
              description: 'Hitung kebutuhan qurban dengan cepat',
              onTap: () {
                context.push('/calculator-template-selection');
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.backgroundElevatedBase,
          border: Border.all(color: AppColors.decorativeSubdued, width: 1),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.essentialBrightAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                icon,
                color: AppColors.essentialBrightAccent,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: AppTypography.bodyLarge,
                      fontWeight: AppTypography.semiBold,
                      color: AppColors.textBase,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: AppTypography.bodySmall,
                      color: AppColors.textSubdued,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSubdued.withOpacity(0.75),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Riwayat Aktivitas',
              style: TextStyle(
                fontSize: AppTypography.headingMedium,
                fontWeight: AppTypography.semiBold,
                color: AppColors.textBase,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _buildActivityItem(
          icon: Icons.verified_rounded,
          iconColor: AppColors.essentialPositive,
          title: 'Masjid Al-Barkah verified',
          subtitle: 'Approved for Period 1447 H',
          timestamp: '2m ago',
        ),
        const SizedBox(height: AppSpacing.md),
        _buildActivityItem(
          icon: Icons.person_add_rounded,
          iconColor: AppColors.essentialBrightAccent,
          title: 'New recipient added',
          subtitle: 'Fatimah Zahra • Mustahiq',
          timestamp: '1h ago',
        ),
        const SizedBox(height: AppSpacing.md),
        _buildActivityItem(
          icon: Icons.warning_rounded,
          iconColor: const Color(0xFFED2C3F),
          title: 'Data mismatch alert',
          subtitle: 'Check Mosque Al-Ikhlas documents',
          timestamp: '5h ago',
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String timestamp,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.backgroundElevatedBase,
        border: Border.all(color: AppColors.decorativeSubdued, width: 1),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: AppTypography.bodyMedium,
                    fontWeight: AppTypography.semiBold,
                    color: AppColors.textBase,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: AppTypography.bodySmall,
                    color: AppColors.textSubdued,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            timestamp,
            style: TextStyle(
              fontSize: AppTypography.bodySmall,
              color: AppColors.textSubdued,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qurban_kit/core/configs/theme/theme.dart';
import 'package:qurban_kit/features/auth/data/models/auth_models.dart';

class AdminHomePage extends StatefulWidget {
  final UserData? user;

  const AdminHomePage({super.key, this.user});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  @override
  void initState() {
    super.initState();
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
                // Active period card
                _buildActivePeriodCard(),
                const SizedBox(height: AppSpacing.xl),

                // Statistics cards
                _buildStatisticsSection(),
                const SizedBox(height: AppSpacing.xl),

                // Quick actions
                _buildQuickActionsSection(),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
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
      title: 'Total Mustahiq',
      value: '0',
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
              label: 'Tambah Mustahiq',
              description: 'Masukkan mustahiq baru ke data distribusi',
              onTap: () {
                context.push('/mosque-recipient-form');
              },
            ),
            const SizedBox(height: AppSpacing.md),
            _buildActionButton(
              icon: Icons.calculate_rounded,
              label: 'Kalkulator Qurban',
              description:
                  'Hitung pembagian berat berdasarkan jumlah daging dan mustahiq',
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
                      fontSize: AppTypography.bodyMedium,
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
}

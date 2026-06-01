import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qurban_kit/core/configs/theme/theme.dart';
import 'package:qurban_kit/features/auth/data/models/auth_models.dart';
import 'package:qurban_kit/features/mosque_dashboard/data/models/period_model.dart';
import 'package:qurban_kit/core/services/service_locator.dart';

class AdminHomePage extends StatefulWidget {
  final UserData? user;

  const AdminHomePage({super.key, this.user});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  PeriodModel? _activePeriod;
  bool _isLoadingPeriod = true;

  @override
  void initState() {
    super.initState();
    _loadActivePeriod();
  }

  Future<void> _loadActivePeriod() async {
    setState(() => _isLoadingPeriod = true);
    try {
      final periods = await periodDataSource.getPeriods();
      final actives = periods.where((p) => p.isActive).toList();
      if (!mounted) return;
      setState(() => _activePeriod = actives.isNotEmpty ? actives.first : null);
    } catch (_) {
      // keep existing UI if fetching fails
    } finally {
      if (!mounted) return;
      setState(() => _isLoadingPeriod = false);
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
                // 1. Card Periode Aktif
                _buildActivePeriodCard(),
                const SizedBox(height: AppSpacing.xl),

                // 2. Main Hero Card Kalkulator (Ukuran Besar & Penuh)
                _buildHeroCalculatorCard(),
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
              const Icon(
                Icons.calendar_today_rounded,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_isLoadingPeriod) ...[
            const Row(
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Text(
                  'Memuat periode...',
                  style: TextStyle(
                    fontSize: AppTypography.bodyMedium,
                    fontWeight: AppTypography.medium,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ] else if (_activePeriod == null) ...[
            const Text(
              'Belum ada periode aktif',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: AppTypography.displaySmall,
                fontWeight: AppTypography.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Aktifkan periode di menu Periode',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: AppTypography.bodyMedium,
                fontWeight: AppTypography.medium,
                color: Colors.white,
              ),
            ),
          ] else ...[
            Text(
              _activePeriod!.displayTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: AppTypography.displaySmall,
                fontWeight: AppTypography.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Text(
                  _activePeriod!.displaySubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: AppTypography.bodyMedium,
                    fontWeight: AppTypography.medium,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // HERO CARD: Unit utama kalkulator yang dibuat sangat dominan
  Widget _buildHeroCalculatorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: 32,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundElevatedBase,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.decorativeSubdued, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.essentialBrightAccent.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calculate_rounded,
              color: AppColors.essentialBrightAccent,
              size: 48,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'Kalkulator Distribusi Qurban',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppTypography.headingLarge,
              fontWeight: AppTypography.bold,
              color: AppColors.textBase,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Solusi cerdas untuk menghitung dan membagi proporsi bobot daging secara otomatis, adil, dan presisi dalam hitungan detik.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppTypography.bodyMedium,
              color: AppColors.textSubdued,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                context.push('/calculator-template-selection');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.essentialBrightAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Buka Kalkulator',
                    style: TextStyle(
                      fontWeight: AppTypography.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // HIGHLIGHT KEUNGGULAN: Pengisi layout bawah biar seimbang dan penuh
  // Widget _buildCalculatorFeaturesSection() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Text(
  //         'Keunggulan Sistem',
  //         style: TextStyle(
  //           fontSize: AppTypography.headingMedium,
  //           fontWeight: AppTypography.semiBold,
  //           color: AppColors.textBase,
  //         ),
  //       ),
  //       const SizedBox(height: AppSpacing.md),
  //       Row(
  //         children: [
  //           Expanded(
  //             child: _buildFeatureGridItem(
  //               icon: Icons.shutter_speed_rounded,
  //               title: 'Hitung Instan',
  //               desc: 'Tanpa rumus manual.',
  //             ),
  //           ),
  //           const SizedBox(width: AppSpacing.md),
  //           Expanded(
  //             child: _buildFeatureGridItem(
  //               icon: Icons.shutter_speed_rounded, // Pakai Icons.scale_rounded jika error
  //               title: 'Alokasi Adil',
  //               desc: 'Rasio pembagian pas.',
  //             ),
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildFeatureGridItem({
  //   required IconData icon,
  //   required String title,
  //   required String desc,
  // }) {
  //   return Container(
  //     padding: const EdgeInsets.all(AppSpacing.md),
  //     decoration: BoxDecoration(
  //       color: AppColors.backgroundElevatedBase,
  //       border: Border.all(color: AppColors.decorativeSubdued, width: 1),
  //       borderRadius: BorderRadius.circular(AppRadius.md),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Icon(icon, color: AppColors.essentialBrightAccent, size: 24),
  //         const SizedBox(height: AppSpacing.sm),
  //         Text(
  //           title,
  //           style: const TextStyle(
  //             fontSize: AppTypography.bodyMedium,
  //             fontWeight: AppTypography.semiBold,
  //             color: AppColors.textBase,
  //           ),
  //         ),
  //         const SizedBox(height: AppSpacing.xs),
  //         Text(
  //           desc,
  //           style: TextStyle(
  //             fontSize: AppTypography.bodySmall,
  //             color: AppColors.textSubdued,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}

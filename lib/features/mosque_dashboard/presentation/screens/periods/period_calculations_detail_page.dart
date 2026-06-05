import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qurban_kit/core/configs/theme/theme.dart';
import 'package:qurban_kit/core/services/calculator_service.dart';
import 'package:qurban_kit/features/qurban_distribution/data/models/calculator_models.dart';

class PeriodCalculationsDetailPage extends StatelessWidget {
  final String itemId;
  final String itemTitle;
  final String animalType;

  const PeriodCalculationsDetailPage({
    super.key,
    required this.itemId,
    required this.itemTitle,
    required this.animalType,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Ganti dummyResult ini dengan data asli yang di-fetch berdasarkan itemId
    final dummyResult = CalculatorResult(
      animals: [],
      totalWeight: 150.0,
      totalBags: 100,
      allocations: {'Shohibul Qurban': 50.0, 'Masyarakat Sekitar': 100.0},
      recipientCounts: {'Shohibul Qurban': 5, 'Masyarakat Sekitar': 95},
      perBagWeight: {'Shohibul Qurban': 10.0, 'Masyarakat Sekitar': 1.05},
      templateId: 'template_b',
    );

    final String titleDisplay = animalType.toLowerCase() == 'sapi'
        ? 'Hasil Sapi'
        : 'Hasil Kambing';

    return Scaffold(
      backgroundColor: AppColors.backgroundBase,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundBase,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textBase),
          onPressed: () => context.pop(),
        ),
        // 1. Title AppBar Dibuat Statis
        title: const Text(
          "Detail Perhitungan",
          style: TextStyle(
            color: AppColors.textBase,
            fontSize: AppTypography.headingMedium,
            fontWeight: AppTypography.semiBold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 2. Judul Item (itemTitle) diletakkan di body agar bebas dari overflow
            if (itemTitle.isNotEmpty) ...[
              Text(
                itemTitle,
                style: const TextStyle(
                  fontSize:
                      24, // Sesuaikan dengan ukuran typography terbesarmu (misal: AppTypography.headingLarge)
                  fontWeight: AppTypography.bold,
                  color: AppColors.textBase,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // Header Card (Gradient)
            _buildHeaderCard(titleDisplay, dummyResult),
            const SizedBox(height: AppSpacing.xl),

            // Judul Section Detail Pembagian
            const Text(
              'Detail Pembagian',
              style: TextStyle(
                fontSize: AppTypography.headingMedium,
                fontWeight: AppTypography.semiBold,
                color: AppColors.textBase,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // List Item Detail
            ...dummyResult.allocations.entries.map((entry) {
              final categoryName = entry.key;
              final allocation = entry.value;
              final recipientCount =
                  dummyResult.recipientCounts[categoryName] ?? 0;
              final perBagWeight = dummyResult.perBagWeight[categoryName] ?? 0;

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: _buildDetailItem(
                  categoryName: categoryName,
                  recipientCount: recipientCount,
                  totalAllocation: allocation,
                  perBagWeight: perBagWeight,
                ),
              );
            }),

            // Progress Bar Multi-warna (Ringkasan Distribusi)
            _buildAllocationProgress(dummyResult),
            const SizedBox(height: AppSpacing.xl),

            // Catatan Perhitungan
            _buildNoteCard(dummyResult),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(String title, CalculatorResult result) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.essentialBrightAccent, Color(0xFF005E53)],
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: AppTypography.bodyMedium,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${CalculatorService.formatWeight(result.totalWeight)} Kg',
                style: const TextStyle(
                  fontSize: AppTypography.displayMedium,
                  fontWeight: AppTypography.bold,
                  color: Colors.white,
                ),
              ),
              Icon(
                Icons.shopping_bag_rounded,
                color: Colors.white.withValues(alpha: 0.8),
                size: 28,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.shopping_basket_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Dibagi ke ${result.totalBags} plastik',
                  style: const TextStyle(
                    fontSize: AppTypography.bodySmall,
                    fontWeight: AppTypography.semiBold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required String categoryName,
    required int recipientCount,
    required double totalAllocation,
    required double perBagWeight,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.backgroundElevatedBase,
        border: Border.all(color: AppColors.decorativeSubdued),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoryName,
                      style: const TextStyle(
                        fontSize: AppTypography.bodyLarge,
                        fontWeight: AppTypography.semiBold,
                        color: AppColors.textBase,
                      ),
                    ),
                    Text(
                      '$recipientCount Penerima Manfaat',
                      style: const TextStyle(
                        fontSize: AppTypography.bodySmall,
                        color: AppColors.textSubdued,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.essentialBrightAccent.withValues(
                    alpha: 0.15,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: Text(
                  '${CalculatorService.formatWeight(perBagWeight)} kg/plastik',
                  style: const TextStyle(
                    fontSize: AppTypography.labelSmall,
                    fontWeight: AppTypography.semiBold,
                    color: AppColors.essentialBrightAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TOTAL ALOKASI',
                style: TextStyle(
                  fontSize: AppTypography.labelSmall,
                  fontWeight: AppTypography.semiBold,
                  color: AppColors.textSubdued,
                ),
              ),
              Text(
                '${CalculatorService.formatWeight(totalAllocation)} kg',
                style: const TextStyle(
                  fontSize: AppTypography.bodyMedium,
                  fontWeight: AppTypography.semiBold,
                  color: AppColors.essentialBrightAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAllocationProgress(CalculatorResult result) {
    final allocationEntries = result.allocations.entries.toList();
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.essentialBrightAccent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Distribusi',
            style: TextStyle(
              fontSize: AppTypography.bodyMedium,
              fontWeight: AppTypography.semiBold,
              color: AppColors.textBase,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xs),
            child: _buildMultiColorProgressBar(allocationEntries, result),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: allocationEntries.asMap().entries.map((entry) {
              final index = entry.key;
              final categoryEntry = entry.value;
              final percentage = result.totalWeight <= 0
                  ? 0
                  : (categoryEntry.value / result.totalWeight * 100)
                        .toStringAsFixed(0);
              final color = _getCategoryColor(index);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${categoryEntry.key} $percentage%',
                    style: const TextStyle(
                      fontSize: AppTypography.labelSmall,
                      color: AppColors.textSubdued,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiColorProgressBar(
    List<MapEntry<String, double>> allocationEntries,
    CalculatorResult result,
  ) {
    return SizedBox(
      height: 8,
      child: Row(
        children: allocationEntries.asMap().entries.map((entry) {
          final index = entry.key;
          final categoryEntry = entry.value;
          final percentage = result.totalWeight <= 0
              ? 0.0
              : categoryEntry.value / result.totalWeight;
          final color = _getCategoryColor(index);

          return Expanded(
            flex: (percentage * 100).toInt().clamp(0, 100),
            child: Container(color: color),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNoteCard(CalculatorResult result) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.essentialBrightAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.info_rounded,
                color: AppColors.essentialBrightAccent,
                size: 20,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Catatan Perhitungan',
                style: TextStyle(
                  fontSize: AppTypography.bodyMedium,
                  fontWeight: AppTypography.semiBold,
                  color: AppColors.essentialBrightAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _buildCalculationNote(result.templateId),
            style: const TextStyle(
              fontSize: AppTypography.bodySmall,
              color: AppColors.textBase,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(int index) {
    const colors = [
      Color(0xFF00A896), // Teal
      Color(0xFF005E53), // Dark Teal
      Color(0xFFD4A574), // Tan
      Color(0xFFA8DADC), // Light Blue
      Color(0xFFF1FAEE), // Very Light
      Color(0xFFE63946), // Red
      Color(0xFFFF9F1C), // Orange
      Color(0xFF7209B7), // Purple
    ];
    return colors[index % colors.length];
  }

  String _buildCalculationNote(String templateId) {
    switch (templateId) {
      case 'template_b':
        return 'Data riwayat ini dihitung berdasarkan bobot yang dibagi menjadi 1/3 untuk Shohibul dan 2/3 untuk Masyarakat.';
      case 'template_c':
        return 'Data riwayat ini dihitung berdasarkan persentase musyawarah (total 100%).';
      default:
        return 'Data riwayat ini dihitung berdasarkan bobot yang dimasukkan secara terpisah.';
    }
  }
}

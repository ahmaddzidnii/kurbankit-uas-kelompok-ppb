import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qurban_kit/core/configs/theme/theme.dart';
import 'package:qurban_kit/core/services/calculator_service.dart';
import 'package:qurban_kit/features/qurban_distribution/data/models/calculator_models.dart';

class CalculatorResultPage extends StatefulWidget {
  final CalculatorComparisonResult comparisonResult;

  const CalculatorResultPage({super.key, required this.comparisonResult});

  @override
  State<CalculatorResultPage> createState() => _CalculatorResultPageState();
}

class _CalculatorResultPageState extends State<CalculatorResultPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBase,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundBase,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textBase),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.comparisonResult.kelompokName != null &&
                  widget.comparisonResult.kelompokName!.isNotEmpty
              ? '${widget.comparisonResult.kelompokName}'
              : 'Hasil Perhitungan',
          style: const TextStyle(
            color: AppColors.textBase,
            fontSize: AppTypography.headingMedium,
            fontWeight: AppTypography.semiBold,
          ),
        ),
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: AppColors.essentialBrightAccent,
            unselectedLabelColor: AppColors.textSubdued,
            indicatorColor: AppColors.essentialBrightAccent,
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: const [
              Tab(text: 'Sapi'),
              Tab(text: 'Kambing'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildResultTab(
                  title: 'Hasil Sapi',
                  result: widget.comparisonResult.sapiResult,
                  emptyMessage: 'Tidak ada input sapi pada sesi ini.',
                ),
                _buildResultTab(
                  title: 'Hasil Kambing',
                  result: widget.comparisonResult.kambingResult,
                  emptyMessage: 'Tidak ada input kambing pada sesi ini.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultTab({
    required String title,
    required CalculatorResult? result,
    required String emptyMessage,
  }) {
    if (result == null) {
      return _buildEmptyState(title: title, message: emptyMessage);
    }

    final totalWeight = result.totalWeight;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressIndicator(result),
          const SizedBox(height: AppSpacing.xl),
          Container(
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
                      '${CalculatorService.formatWeight(totalWeight)} Kg',
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
                        'Siap untuk dibagi ke ${result.totalBags} plastik',
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
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Detail Pembagian',
                style: TextStyle(
                  fontSize: AppTypography.headingMedium,
                  fontWeight: AppTypography.semiBold,
                  color: AppColors.textBase,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...result.allocations.entries.map((entry) {
            final categoryName = entry.key;
            final allocation = entry.value;
            final recipientCount = result.recipientCounts[categoryName] ?? 0;
            final perBagWeight = result.perBagWeight[categoryName] ?? 0;

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
          _buildAllocationProgress(result),
          const SizedBox(height: AppSpacing.xl),
          _buildNoteCard(result),
          const SizedBox(height: AppSpacing.xl),
          _buildActionButtons(),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildEmptyState({required String title, required String message}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.backgroundElevatedBase,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.decorativeSubdued),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.inbox_rounded,
                size: 56,
                color: AppColors.essentialBrightAccent,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                style: TextStyle(
                  fontSize: AppTypography.headingMedium,
                  fontWeight: AppTypography.semiBold,
                  color: AppColors.textBase,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppTypography.bodyMedium,
                  color: AppColors.textSubdued,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(CalculatorResult result) {
    final percentage = result.allocations.isEmpty
        ? 0.0
        : result.allocations.values.fold<double>(
                0,
                (sum, value) => sum + value,
              ) /
              result.totalWeight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Langhkah 4 dari 4',
              style: TextStyle(
                fontSize: AppTypography.bodySmall,
                color: AppColors.textSubdued,
                fontWeight: AppTypography.semiBold,
              ),
            ),
            Text(
              '${(percentage * 100).toStringAsFixed(0)}% Complete',
              style: TextStyle(
                fontSize: AppTypography.bodySmall,
                fontWeight: AppTypography.semiBold,
                color: AppColors.essentialBrightAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xs),
          child: LinearProgressIndicator(
            value: 1.0,
            minHeight: 6,
            backgroundColor: AppColors.backgroundElevatedBase,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.essentialBrightAccent,
            ),
          ),
        ),
      ],
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
          Row(
            children: [
              const Icon(
                Icons.info_rounded,
                color: AppColors.essentialBrightAccent,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
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
            style: TextStyle(
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

  Widget _buildAllocationProgress(CalculatorResult result) {
    final allocationEntries = result.allocations.entries.toList();
    final totalAllocated = result.allocations.values.fold<double>(
      0,
      (sum, value) => sum + value,
    );
    final ratio = result.totalWeight <= 0
        ? 0.0
        : totalAllocated / result.totalWeight;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.essentialBrightAccent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ringkasan Distribusi',
                style: TextStyle(
                  fontSize: AppTypography.bodyMedium,
                  fontWeight: AppTypography.semiBold,
                  color: AppColors.textBase,
                ),
              ),
              // Text(
              //   'TOTAL PERSENTASE: ${(ratio * 100).toStringAsFixed(0)}%',
              //   style: TextStyle(
              //     fontSize: AppTypography.labelSmall,
              //     fontWeight: AppTypography.semiBold,
              //     color: AppColors.essentialBrightAccent,
              //   ),
              // ),
            ],
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
                    style: TextStyle(
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
    final totalAllocated = result.allocations.values.fold<double>(
      0,
      (sum, value) => sum + value,
    );

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

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Hasil telah disimpan')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.essentialBrightAccent,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.save_rounded, color: Colors.white),
                SizedBox(width: AppSpacing.sm),
                Text(
                  'Simpan Data',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppTypography.bodyMedium,
                    fontWeight: AppTypography.semiBold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }

  String _buildCalculationNote(String templateId) {
    switch (templateId) {
      case 'template_b':
        return 'Perhitungan pada tab ini mengikuti bobot yang dimasukkan untuk sapi atau kambing secara terpisah, lalu dibagi menjadi 1/3 untuk Shohibul dan 2/3 untuk Masyarakat.';
      case 'template_c':
        return 'Perhitungan pada tab ini mengikuti bobot yang dimasukkan untuk sapi atau kambing secara terpisah dan persentase musyawarah harus total 100%.';
      default:
        return 'Perhitungan pada tab ini mengikuti bobot yang dimasukkan secara terpisah.';
    }
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
                      style: TextStyle(
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
              Text(
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
}

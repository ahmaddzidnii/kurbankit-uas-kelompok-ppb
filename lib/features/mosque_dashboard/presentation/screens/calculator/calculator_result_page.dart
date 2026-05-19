import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qurban_kit/core/configs/theme/theme.dart';
import 'package:qurban_kit/core/services/calculator_service.dart';
import 'package:qurban_kit/features/qurban_distribution/data/models/calculator_models.dart';

class CalculatorResultPage extends StatefulWidget {
  final CalculatorResult result;

  const CalculatorResultPage({super.key, required this.result});

  @override
  State<CalculatorResultPage> createState() => _CalculatorResultPageState();
}

class _CalculatorResultPageState extends State<CalculatorResultPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
        title: const Text(
          'Hasil Perhitungan',
          style: TextStyle(
            color: AppColors.textBase,
            fontSize: AppTypography.headingMedium,
            fontWeight: AppTypography.semiBold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Tab bar
          TabBar(
            controller: _tabController,
            labelColor: AppColors.essentialBrightAccent,
            unselectedLabelColor: AppColors.textSubdued,
            indicatorColor: AppColors.essentialBrightAccent,
            tabs: const [
              Tab(text: 'Sapi'),
              Tab(text: 'Kambing'),
            ],
          ),

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildResultTab(), _buildResultTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultTab() {
    final totalWeight = widget.result.totalWeight;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress
          _buildProgressIndicator(),
          const SizedBox(height: AppSpacing.xl),

          // Main result card
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
                  'Total Estimasi Daging',
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
                        'Ready to distribute in ${widget.result.totalBags} bags',
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

          // Detail pembagian
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
              GestureDetector(
                onTap: () {
                  // Show filter/sort options
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Filter option - Coming Soon'),
                    ),
                  );
                },
                child: const Icon(
                  Icons.tune_rounded,
                  color: AppColors.essentialBrightAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Detail items
          ...widget.result.allocations.entries.map((entry) {
            final categoryName = entry.key;
            final allocation = entry.value;
            final recipientCount =
                widget.result.recipientCounts[categoryName] ?? 0;
            final perBagWeight = widget.result.perBagWeight[categoryName] ?? 0;

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

          // Allocation progress
          _buildAllocationProgress(),
          const SizedBox(height: AppSpacing.xl),

          // Catatan Perhitungan
          Container(
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
                  'Estimasi karkas dihitung berdasarkan 50% dari berat hidup rata-rata. Pembagian sudah menyertakan alokasi 1/3 bagian untuk Shohibul.',
                  style: TextStyle(
                    fontSize: AppTypography.bodySmall,
                    color: AppColors.textBase,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Action buttons
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Hasil telah disimpan')),
                );
                context.pop();
                context.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.essentialBrightAccent,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
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

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Hasil dibagikan')),
                );
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                side: const BorderSide(
                  color: AppColors.essentialBrightAccent,
                  width: 2,
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.share_rounded,
                    color: AppColors.essentialBrightAccent,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Bagikan Hasil',
                    style: TextStyle(
                      color: AppColors.essentialBrightAccent,
                      fontSize: AppTypography.bodyMedium,
                      fontWeight: AppTypography.semiBold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
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
          // Category header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.essentialBrightAccent.withValues(
                    alpha: 0.15,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Center(
                  child: Text('👥', style: const TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
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
                  '${CalculatorService.formatWeight(perBagWeight)} kg/bag',
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

          // Total allocation
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

  Widget _buildAllocationProgress() {
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
                'Allocation Progress',
                style: TextStyle(
                  fontSize: AppTypography.bodyMedium,
                  fontWeight: AppTypography.semiBold,
                  color: AppColors.textBase,
                ),
              ),
              Text(
                'TOTAL PERSENTASE: ${widget.result.allocations.values.fold<double>(0, (sum, val) => sum + (val / widget.result.totalWeight * 100)).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: AppTypography.labelSmall,
                  fontWeight: AppTypography.semiBold,
                  color: AppColors.essentialBrightAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xs),
            child: LinearProgressIndicator(
              value: 1.0,
              minHeight: 8,
              backgroundColor: AppColors.decorativeSubdued,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.essentialBrightAccent,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Legend
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: widget.result.allocations.entries.map((entry) {
              final percentage = (entry.value / widget.result.totalWeight * 100)
                  .toStringAsFixed(0);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.essentialBrightAccent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '${entry.key} ($percentage%)',
                    style: TextStyle(
                      fontSize: AppTypography.labelSmall,
                      color: AppColors.textBase,
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

  Widget _buildProgressIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Langkah Terakhir',
              style: TextStyle(
                fontSize: AppTypography.bodySmall,
                color: AppColors.textSubdued,
              ),
            ),
            Text(
              '4/4',
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
          child: const LinearProgressIndicator(
            value: 1.0,
            minHeight: 6,
            backgroundColor: AppColors.backgroundElevatedBase,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.essentialBrightAccent,
            ),
          ),
        ),
      ],
    );
  }
}

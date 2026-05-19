import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qurban_kit/core/configs/theme/theme.dart';

class PeriodsPage extends StatefulWidget {
  const PeriodsPage({super.key});

  @override
  State<PeriodsPage> createState() => _PeriodsPageState();
}

class _PeriodsPageState extends State<PeriodsPage> {
  // Sample data - will be replaced with API calls
  final List<Map<String, dynamic>> _periods = [
    {
      'name': 'Idul Adha 1447 H',
      'date': 'Idul Adha, 27 Mei 2026',
      'status': 'active',
      'progress': 65,
    },
    {
      'name': 'Idul Adha 1447 H',
      'date': 'Idul Adha, 27 Mei 2026',
      'status': 'pending',
      'progress': 45,
    },
    {
      'name': 'Idul Adha 1447 H',
      'date': 'Idul Adha, 27 Mei 2026',
      'status': 'completed',
      'progress': 100,
    },
    {
      'name': 'Idul Adha 1446 H',
      'date': 'Idul Adha, 27 Mei 2025',
      'status': 'completed',
      'progress': 100,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBase,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halaman Periode Kurban',
                  style: TextStyle(
                    fontSize: AppTypography.displaySmall,
                    fontWeight: AppTypography.bold,
                    color: AppColors.textBase,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Kelola semua periode kurban dan pantau perkembangan setiap periode',
                  style: TextStyle(
                    fontSize: AppTypography.bodyMedium,
                    color: AppColors.textSubdued,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _periods.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _buildPeriodCard(_periods[index], index),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.essentialBrightAccent,
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tambah Periode - Coming Soon')),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.backgroundBase,
      elevation: 0,
      title: const Text(
        'Periode',
        style: TextStyle(
          fontSize: AppTypography.headingLarge,
          fontWeight: AppTypography.bold,
          color: AppColors.textBase,
        ),
      ),
    );
  }

  Widget _buildPeriodCard(Map<String, dynamic> period, int index) {
    final isActive = period['status'] == 'active';
    final isPending = period['status'] == 'pending';
    final isCompleted = period['status'] == 'completed';

    Color statusColor;
    String statusLabel;
    Color statusBgColor;

    if (isActive) {
      statusColor = Colors.white;
      statusLabel = 'ACTIVE';
      statusBgColor = AppColors.essentialBrightAccent;
    } else if (isPending) {
      statusColor = Colors.white;
      statusLabel = 'PENDING';
      statusBgColor = const Color(0xFFFFA42B);
    } else {
      statusColor = Colors.white;
      statusLabel = 'COMPLETED';
      statusBgColor = AppColors.essentialPositive.withOpacity(0.7);
    }

    return GestureDetector(
      onTap: () {
        _showPeriodDetail(period);
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.backgroundElevatedBase,
          border: Border.all(
            color: isActive
                ? AppColors.essentialBrightAccent.withOpacity(0.3)
                : AppColors.decorativeSubdued,
            width: isActive ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        period['name'],
                        style: const TextStyle(
                          fontSize: AppTypography.headingSmall,
                          fontWeight: AppTypography.bold,
                          color: AppColors.textBase,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        period['date'],
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
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: AppTypography.labelSmall,
                      fontWeight: AppTypography.bold,
                      color: statusColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Progress',
                  style: TextStyle(
                    fontSize: AppTypography.bodyMedium,
                    fontWeight: AppTypography.medium,
                    color: AppColors.textBase,
                  ),
                ),
                Text(
                  '${period['progress']}%',
                  style: const TextStyle(
                    fontSize: AppTypography.bodyMedium,
                    fontWeight: AppTypography.bold,
                    color: AppColors.textBase,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: LinearProgressIndicator(
                value: period['progress'] / 100,
                minHeight: 6,
                backgroundColor: AppColors.decorativeSubdued,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isCompleted ? statusBgColor : statusBgColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPeriodDetail(Map<String, dynamic> period) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundElevatedBase,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppRadius.lg),
            topRight: Radius.circular(AppRadius.lg),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Detail Periode',
                    style: TextStyle(
                      fontSize: AppTypography.headingMedium,
                      fontWeight: AppTypography.bold,
                      color: AppColors.textBase,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Icon(Icons.close_rounded, color: AppColors.textBase),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildDetailRow('Nama Periode', period['name']),
              const SizedBox(height: AppSpacing.md),
              _buildDetailRow('Tanggal', period['date']),
              const SizedBox(height: AppSpacing.md),
              _buildDetailRow('Status', period['status'].toUpperCase()),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.essentialBrightAccent,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                  ),
                  onPressed: () {
                    context.pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('View Details - Coming Soon'),
                      ),
                    );
                  },
                  child: const Text(
                    'Lihat Detail Lengkap',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: AppTypography.bold,
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

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: AppTypography.bodyMedium,
            color: AppColors.textSubdued,
            fontWeight: AppTypography.medium,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: AppTypography.bodyMedium,
            fontWeight: AppTypography.bold,
            color: AppColors.textBase,
          ),
        ),
      ],
    );
  }
}

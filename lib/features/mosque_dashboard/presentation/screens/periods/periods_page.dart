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
      'isActive': true,
    },
    {
      'name': 'Idul Adha 1447 H',
      'date': 'Idul Adha, 27 Mei 2026',
      'isActive': false,
    },
    {
      'name': 'Idul Adha 1447 H',
      'date': 'Idul Adha, 27 Mei 2026',
      'isActive': false,
    },
    {
      'name': 'Idul Adha 1446 H',
      'date': 'Idul Adha, 27 Mei 2025',
      'isActive': false,
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
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
          fontWeight: AppTypography.semiBold,
          color: AppColors.textBase,
        ),
      ),
    );
  }

  Widget _buildPeriodCard(Map<String, dynamic> period, int index) {
    final isActive = period['isActive'] as bool;

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
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPeriodDetail(Map<String, dynamic> period) {
    bool isEnabled = period['isActive'] as bool;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
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
                      child: Icon(
                        Icons.close_rounded,
                        color: AppColors.textBase,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildDetailRow('Nama Periode', period['name']),
                const SizedBox(height: AppSpacing.md),
                _buildDetailRow('Tanggal', period['date']),
                const SizedBox(height: AppSpacing.md),
                _buildActivationRow(isEnabled, (value) {
                  setModalState(() {
                    isEnabled = value;
                    period['status'] = value ? 'active' : 'pending';
                  });
                  setState(() {});
                }),
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
      ),
    );
  }

  Widget _buildActivationRow(bool isEnabled, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Aktifkan',
          style: TextStyle(
            fontSize: AppTypography.bodyMedium,
            color: AppColors.textSubdued,
            fontWeight: AppTypography.medium,
          ),
        ),
        Switch(
          value: isEnabled,
          onChanged: onChanged,
          activeColor: Colors.white,
          activeTrackColor: AppColors.essentialBrightAccent,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: AppColors.decorativeSubdued,
        ),
      ],
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

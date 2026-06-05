import 'package:flutter/material.dart';
import 'package:qurban_kit/core/configs/theme/theme.dart';

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
    return Scaffold(
      backgroundColor: AppColors.backgroundBase,
      appBar: AppBar(
        title: Text(itemTitle),
        backgroundColor: AppColors.backgroundBase,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detail Perhitungan ${animalType == 'sapi' ? 'Sapi' : 'Kambing'}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('ID Data: $itemId'),
              const SizedBox(height: AppSpacing.sm),
              const Expanded(
                child: Center(
                  child: Text(
                    'Konten detail perhitungan/list isi taruh di sini.',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qurban_kit/core/configs/theme/theme.dart';
import 'package:qurban_kit/core/services/calculator_service.dart';

class CalculatorTemplateSelectionPage extends StatefulWidget {
  const CalculatorTemplateSelectionPage({super.key});

  @override
  State<CalculatorTemplateSelectionPage> createState() =>
      _CalculatorTemplateSelectionPageState();
}

class _CalculatorTemplateSelectionPageState
    extends State<CalculatorTemplateSelectionPage> {
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
          'Pilih Template Pembagian',
          style: TextStyle(
            color: AppColors.textBase,
            fontSize: AppTypography.headingMedium,
            fontWeight: AppTypography.semiBold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress indicator
              _buildProgressIndicator(),
              const SizedBox(height: AppSpacing.xl),

              // Title
              Text(
                'Metode Distribusi Qurban',
                style: TextStyle(
                  fontSize: AppTypography.headingLarge,
                  fontWeight: AppTypography.bold,
                  color: AppColors.textBase,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Description
              Text(
                'Pilih format pembagian daging yang sesuai dengan tradisi atau kebutuhan lingkungan Anda.',
                style: TextStyle(
                  fontSize: AppTypography.bodyMedium,
                  color: AppColors.textSubdued,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Templates
              ...CalculatorService.templates.map((template) {
                final isFirst =
                    template.id == CalculatorService.templates.first.id;
                return Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 200,
                      child: GestureDetector(
                        onTap: () {
                          context.push('/calculator-input/${template.id}');
                        },
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundElevatedBase,
                            border: Border.all(
                              color: isFirst
                                  ? AppColors.essentialBrightAccent
                                  : AppColors.decorativeSubdued,
                              width: isFirst ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title
                              Text(
                                template.name,
                                style: TextStyle(
                                  fontSize: AppTypography.headingMedium,
                                  fontWeight: AppTypography.bold,
                                  color: AppColors.textBase,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),

                              // Description
                              Expanded(
                                child: Text(
                                  template.description,
                                  style: TextStyle(
                                    fontSize: AppTypography.bodySmall,
                                    color: AppColors.textSubdued,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),

                              // Categories tag
                              if (template.categories.isNotEmpty)
                                Wrap(
                                  spacing: AppSpacing.sm,
                                  children: template.categories
                                      .map(
                                        (category) => Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: AppSpacing.sm,
                                            vertical: AppSpacing.xs,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors
                                                .essentialBrightAccent
                                                .withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(
                                              AppRadius.xs,
                                            ),
                                          ),
                                          child: Text(
                                            category,
                                            style: const TextStyle(
                                              fontSize:
                                                  AppTypography.labelSmall,
                                              fontWeight: AppTypography.medium,
                                              color: AppColors
                                                  .essentialBrightAccent,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (template.id != CalculatorService.templates.last.id)
                      const SizedBox(height: AppSpacing.md),
                  ],
                );
              }),
            ],
          ),
        ),
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
            Text(
              'Langkah 1 dari 4',
              style: TextStyle(
                fontSize: AppTypography.bodySmall,
                color: AppColors.textSubdued,
              ),
            ),
            Text(
              '25% Selesai',
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
            value: 0.25,
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
}

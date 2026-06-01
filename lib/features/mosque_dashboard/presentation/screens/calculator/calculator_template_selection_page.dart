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
            fontSize: AppTypography.headingSmall,
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
                'Pilih cara pembagian daging yang sesuai dengan tradisi atau alur kerja di lingkungan Anda.',
                style: TextStyle(
                  fontSize: AppTypography.bodyMedium,
                  color: AppColors.textSubdued,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Templates
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: CalculatorService.templates.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  final template = CalculatorService.templates[index];

                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.backgroundElevatedBase,
                      border: Border.all(
                        color: AppColors.decorativeSubdued,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      onTap: () {
                        context.push('/calculator-input/${template.id}');
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header: Judul Template
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    template.name,
                                    style: const TextStyle(
                                      fontSize: AppTypography.headingMedium,
                                      fontWeight: AppTypography.bold,
                                      color: AppColors.textBase,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),

                            // Deskripsi
                            Text(
                              template.description,
                              style: TextStyle(
                                fontSize: AppTypography.bodySmall,
                                color: AppColors.textSubdued,
                                height: 1.4,
                              ),
                            ),

                            // Render list formula jika tidak kosong
                            if (template.formulas.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.md),
                              const Divider(
                                height: 1,
                                color: AppColors.decorativeSubdued,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: template.formulas.map((formula) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: AppSpacing.xs,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Simbol Bullet
                                        Text(
                                          '• ',
                                          style: TextStyle(
                                            fontSize: AppTypography.bodySmall,
                                            color: AppColors.textSubdued,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        // Teks Formula
                                        Expanded(
                                          child: Text(
                                            formula,
                                            style: TextStyle(
                                              fontSize: AppTypography.bodySmall,
                                              color: AppColors.textSubdued,
                                              height: 1.4,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
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

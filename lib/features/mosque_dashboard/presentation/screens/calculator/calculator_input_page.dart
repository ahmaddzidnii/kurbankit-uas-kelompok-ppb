import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qurban_kit/core/configs/theme/theme.dart';
import 'package:qurban_kit/core/services/calculator_service.dart';
import 'package:qurban_kit/features/qurban_distribution/data/models/calculator_models.dart';

class CalculatorInputPage extends StatefulWidget {
  final String templateId;

  const CalculatorInputPage({super.key, required this.templateId});

  @override
  State<CalculatorInputPage> createState() => _CalculatorInputPageState();
}

class _CalculatorInputPageState extends State<CalculatorInputPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final sapiWeightController = TextEditingController();
  final kambingWeightController = TextEditingController();

  late List<RecipientCategory> categories;

  late Map<String, int> sapiRecipientCounts;
  late Map<String, int> kambingRecipientCounts;
  late Map<String, TextEditingController> sapiCategoryControllers;
  late Map<String, TextEditingController> kambingCategoryControllers;
  late Map<String, double> sapiCustomPercentages;
  late Map<String, double> kambingCustomPercentages;
  late Map<String, TextEditingController> sapiPercentageControllers;
  late Map<String, TextEditingController> kambingPercentageControllers;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    categories = CalculatorService.getDefaultCategories(widget.templateId);

    sapiRecipientCounts = {};
    kambingRecipientCounts = {};
    sapiCategoryControllers = {};
    kambingCategoryControllers = {};
    sapiCustomPercentages = {};
    kambingCustomPercentages = {};
    sapiPercentageControllers = {};
    kambingPercentageControllers = {};

    _initializeSpeciesState();
  }

  void _initializeSpeciesState() {
    for (final category in categories) {
      sapiRecipientCounts[category.name] = 0;
      kambingRecipientCounts[category.name] = 0;
      sapiCategoryControllers[category.name] = TextEditingController();
      kambingCategoryControllers[category.name] = TextEditingController();
      sapiCustomPercentages[category.name] = 0;
      kambingCustomPercentages[category.name] = 0;
      sapiPercentageControllers[category.name] = TextEditingController();
      kambingPercentageControllers[category.name] = TextEditingController();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    sapiWeightController.dispose();
    kambingWeightController.dispose();
    for (final controller in sapiCategoryControllers.values) {
      controller.dispose();
    }
    for (final controller in kambingCategoryControllers.values) {
      controller.dispose();
    }
    for (final controller in sapiPercentageControllers.values) {
      controller.dispose();
    }
    for (final controller in kambingPercentageControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addCategoryForTemplateC() {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Membuat bottom sheet mengikuti tinggi konten & keyboard
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ), // Membuat sudut atas melengkung
      ),
      builder: (sheetContext) {
        final nameController = TextEditingController();

        return Padding(
          // Padding bottom otomatis menyesuaikan tinggi keyboard yang muncul
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize:
                  MainAxisSize.min, // Agar tinggi sheet sesuai jumlah konten
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Tambah Kategori',
                  style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  autofocus:
                      true, // Otomatis fokus dan membuka keyboard saat sheet muncul
                  decoration: const InputDecoration(
                    labelText: 'Nama Kategori',
                    hintText: 'Cth: Pendatang, Warga Tetap, Mustahik',
                    border:
                        OutlineInputBorder(), // Tampilan border lebih rapi di bottom sheet
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => sheetContext.pop(),
                      child: const Text('Batal'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        final categoryName = nameController.text.trim();
                        if (categoryName.isEmpty ||
                            categories.any(
                              (item) => item.name == categoryName,
                            )) {
                          return;
                        }

                        setState(() {
                          categories = [
                            ...categories,
                            RecipientCategory(
                              name: categoryName,
                              description: '',
                              count: 0,
                            ),
                          ];

                          sapiRecipientCounts[categoryName] = 0;
                          kambingRecipientCounts[categoryName] = 0;
                          sapiCategoryControllers[categoryName] =
                              TextEditingController();
                          kambingCategoryControllers[categoryName] =
                              TextEditingController();
                          sapiCustomPercentages[categoryName] = 0;
                          kambingCustomPercentages[categoryName] = 0;
                          sapiPercentageControllers[categoryName] =
                              TextEditingController();
                          kambingPercentageControllers[categoryName] =
                              TextEditingController();
                        });

                        sheetContext.pop();
                      },
                      child: const Text('Tambah'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _removeCategory(String categoryName) {
    setState(() {
      categories.removeWhere((category) => category.name == categoryName);
      sapiCategoryControllers[categoryName]?.dispose();
      kambingCategoryControllers[categoryName]?.dispose();
      sapiPercentageControllers[categoryName]?.dispose();
      kambingPercentageControllers[categoryName]?.dispose();
      sapiCategoryControllers.remove(categoryName);
      kambingCategoryControllers.remove(categoryName);
      sapiPercentageControllers.remove(categoryName);
      kambingPercentageControllers.remove(categoryName);
      sapiRecipientCounts.remove(categoryName);
      kambingRecipientCounts.remove(categoryName);
      sapiCustomPercentages.remove(categoryName);
      kambingCustomPercentages.remove(categoryName);
    });
  }

  void _saveSpeciesValues() {
    for (final entry in sapiCategoryControllers.entries) {
      if (entry.value != null) {
        sapiRecipientCounts[entry.key] = int.tryParse(entry.value.text) ?? 0;
      }
    }

    for (final entry in kambingCategoryControllers.entries) {
      if (entry.value != null) {
        kambingRecipientCounts[entry.key] = int.tryParse(entry.value.text) ?? 0;
      }
    }

    for (final entry in sapiPercentageControllers.entries) {
      if (entry.value != null) {
        sapiCustomPercentages[entry.key] =
            double.tryParse(entry.value.text) ?? 0;
      }
    }

    for (final entry in kambingPercentageControllers.entries) {
      if (entry.value != null) {
        kambingCustomPercentages[entry.key] =
            double.tryParse(entry.value.text) ?? 0;
      }
    }
  }

  bool _hasAnyRecipientValue(Map<String, int> counts) {
    return counts.values.any((count) => count > 0);
  }

  void _proceedToResult() {
    _saveSpeciesValues();

    final sapiWeight = double.tryParse(sapiWeightController.text.trim()) ?? 0;
    final kambingWeight =
        double.tryParse(kambingWeightController.text.trim()) ?? 0;

    final hasSapiInput = sapiWeight > 0;
    final hasKambingInput = kambingWeight > 0;

    if (!hasSapiInput && !hasKambingInput) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan minimal bobot daging sapi atau kambing'),
        ),
      );
      return;
    }

    if (hasSapiInput && !_hasAnyRecipientValue(sapiRecipientCounts)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tab sapi memerlukan minimal 1 penerima manfaat'),
        ),
      );
      return;
    }

    if (hasKambingInput && !_hasAnyRecipientValue(kambingRecipientCounts)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tab kambing memerlukan minimal 1 penerima manfaat'),
        ),
      );
      return;
    }

    try {
      final comparisonResult = CalculatorService.calculateComparison(
        templateId: widget.templateId,
        sapiWeight: sapiWeight,
        kambingWeight: kambingWeight,
        sapiRecipientCounts: sapiRecipientCounts,
        kambingRecipientCounts: kambingRecipientCounts,
        sapiCustomPercentages: sapiCustomPercentages,
        kambingCustomPercentages: kambingCustomPercentages,
      );

      context.push('/calculator-result', extra: comparisonResult);
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final template = CalculatorService.getTemplate(widget.templateId);

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
          template?.name ?? 'Calculator',
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
                _buildSpeciesTab(
                  speciesLabel: 'Sapi',
                  weightController: sapiWeightController,
                  recipientCounts: sapiRecipientCounts,
                  categoryControllers: sapiCategoryControllers,
                  customPercentages: sapiCustomPercentages,
                  percentageControllers: sapiPercentageControllers,
                ),
                _buildSpeciesTab(
                  speciesLabel: 'Kambing',
                  weightController: kambingWeightController,
                  recipientCounts: kambingRecipientCounts,
                  categoryControllers: kambingCategoryControllers,
                  customPercentages: kambingCustomPercentages,
                  percentageControllers: kambingPercentageControllers,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _proceedToResult,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.essentialBrightAccent,
                ),
                child: Text(
                  'Hitung dan Lihat Hasil',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeciesTab({
    required String speciesLabel,
    required TextEditingController weightController,
    required Map<String, int> recipientCounts,
    required Map<String, TextEditingController> categoryControllers,
    required Map<String, double> customPercentages,
    required Map<String, TextEditingController> percentageControllers,
  }) {
    final hasCustomCategories = widget.templateId == 'template_c';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressIndicator(),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Input Bobot $speciesLabel',
            style: TextStyle(
              fontSize: AppTypography.headingLarge,
              fontWeight: AppTypography.bold,
              color: AppColors.textBase,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Tab ini khusus untuk qurban $speciesLabel. Bobot kosong diperbolehkan.',
            style: TextStyle(
              fontSize: AppTypography.bodyMedium,
              color: AppColors.textSubdued,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          _buildWeightCard(
            title: speciesLabel,
            helperText:
                'Masukkan total bobot daging $speciesLabel dalam kilogram',
            controller: weightController,
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Input Penerima $speciesLabel',
            style: TextStyle(
              fontSize: AppTypography.headingMedium,
              fontWeight: AppTypography.semiBold,
              color: AppColors.textBase,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Masukkan jumlah penerima yang khusus berlaku untuk qurban $speciesLabel.',
            style: TextStyle(
              fontSize: AppTypography.bodyMedium,
              color: AppColors.textSubdued,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          ...categories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: _buildRecipientInput(
                category: category,
                recipientCounts: recipientCounts,
                categoryControllers: categoryControllers,
                customPercentages: customPercentages,
                percentageControllers: percentageControllers,
              ),
            );
          }),
          if (hasCustomCategories) ...[
            GestureDetector(
              onTap: _addCategoryForTemplateC,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.lg,
                  horizontal: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.decorativeSubdued,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.add,
                        color: AppColors.essentialBrightAccent,
                        size: 24,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Tambah Kategori',
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
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
          _buildInfoNote(
            message: speciesLabel == 'Sapi'
                ? 'Tab sapi menghitung hasil berdasarkan bobot dan penerima yang diinput khusus untuk sapi.'
                : 'Tab kambing menghitung hasil berdasarkan bobot dan penerima yang diinput khusus untuk kambing.',
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildWeightCard({
    required String title,
    required String helperText,
    required TextEditingController controller,
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
          Text(
            title,
            style: TextStyle(
              fontSize: AppTypography.bodyLarge,
              fontWeight: AppTypography.semiBold,
              color: AppColors.textBase,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            helperText,
            style: TextStyle(
              fontSize: AppTypography.bodySmall,
              color: AppColors.textSubdued,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: '0',
              suffixText: 'kg',
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: const BorderSide(
                  color: AppColors.decorativeSubdued,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: const BorderSide(
                  color: AppColors.decorativeSubdued,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipientInput({
    required RecipientCategory category,
    required Map<String, int> recipientCounts,
    required Map<String, TextEditingController> categoryControllers,
    required Map<String, double> customPercentages,
    required Map<String, TextEditingController> percentageControllers,
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
                      category.name,
                      style: const TextStyle(
                        fontSize: AppTypography.bodyLarge,
                        fontWeight: AppTypography.semiBold,
                        color: AppColors.textBase,
                      ),
                    ),
                    Text(
                      category.description,
                      style: TextStyle(
                        fontSize: AppTypography.bodySmall,
                        color: AppColors.textSubdued,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.templateId == 'template_c')
                IconButton(
                  icon: const Icon(Icons.delete_rounded, color: Colors.red),
                  onPressed: () => _removeCategory(category.name),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (widget.templateId == 'template_c') ...[
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Persentase (%)',
                    style: TextStyle(
                      fontSize: AppTypography.bodySmall,
                      fontWeight: AppTypography.semiBold,
                      color: AppColors.textBase,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller:
                        percentageControllers[category.name] ??
                        TextEditingController(),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (value) {
                      setState(() {
                        customPercentages[category.name] =
                            double.tryParse(value) ?? 0;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: '0',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.md,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        borderSide: const BorderSide(
                          color: AppColors.decorativeSubdued,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        borderSide: const BorderSide(
                          color: AppColors.decorativeSubdued,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Jumlah ${category.name}',
                style: TextStyle(
                  fontSize: AppTypography.bodySmall,
                  fontWeight: AppTypography.semiBold,
                  color: AppColors.textBase,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller:
                    categoryControllers[category.name] ??
                    TextEditingController(),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    recipientCounts[category.name] = int.tryParse(value) ?? 0;
                  });
                },
                decoration: InputDecoration(
                  hintText: category.name == 'Shohibul'
                      ? 'Jumlah shohibul'
                      : 'Jumlah KK',
                  suffixText: category.name == 'Shohibul' ? 'orang' : 'KK',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    borderSide: const BorderSide(
                      color: AppColors.decorativeSubdued,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    borderSide: const BorderSide(
                      color: AppColors.decorativeSubdued,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoNote({required String message}) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.essentialBrightAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info, color: AppColors.essentialBrightAccent),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: AppTypography.bodySmall,
                color: AppColors.textBase,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final currentProgress = widget.templateId == 'template_c' ? 3 : 2;
    final progressValue = currentProgress / 4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Langkah $currentProgress dari 4',
              style: TextStyle(
                fontSize: AppTypography.bodySmall,
                color: AppColors.textSubdued,
                fontWeight: AppTypography.semiBold,
              ),
            ),
            Text(
              '${(progressValue * 100).toStringAsFixed(0)}% Complete',
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
            value: progressValue,
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

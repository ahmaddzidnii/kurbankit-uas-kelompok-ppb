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
  late TabController _tabController;

  // Animal data
  late List<AnimalData> animals;
  final sapiController = TextEditingController();
  final kambingController = TextEditingController();

  // Recipient counts
  late Map<String, int> recipientCounts;
  late List<RecipientCategory> categories;
  late Map<String, TextEditingController> categoryControllers;

  // Custom template percentages
  late Map<String, double> customPercentages;
  late Map<String, TextEditingController> percentageControllers;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initialize animals
    animals = [
      AnimalData(type: 'Sapi', weight: 300),
      AnimalData(type: 'Kambing', weight: 50),
    ];

    // Initialize categories based on template
    categories = CalculatorService.getDefaultCategories(widget.templateId);
    categoryControllers = {};
    recipientCounts = {};

    for (var category in categories) {
      categoryControllers[category.name] = TextEditingController();
      recipientCounts[category.name] = 0;
    }

    // Initialize custom percentages for template C
    customPercentages = {};
    percentageControllers = {};
  }

  @override
  void dispose() {
    _tabController.dispose();
    sapiController.dispose();
    kambingController.dispose();
    categoryControllers.forEach((_, controller) => controller.dispose());
    percentageControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _addCategoryForTemplateC() {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        return AlertDialog(
          title: const Text('Tambah Kategori'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Nama Kategori',
              hintText: 'Cth: Panitia, Warga RT 01',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  setState(() {
                    final newCategory = RecipientCategory(
                      name: nameController.text,
                      icon: '👥',
                      description: '',
                      count: 0,
                      percentage: 0,
                    );
                    categories.add(newCategory);
                    categoryControllers[newCategory.name] =
                        TextEditingController();
                    recipientCounts[newCategory.name] = 0;
                    customPercentages[newCategory.name] = 0;
                    percentageControllers[newCategory.name] =
                        TextEditingController();
                  });
                  context.pop();
                }
              },
              child: const Text('Tambah'),
            ),
          ],
        );
      },
    );
  }

  void _removeCategory(String categoryName) {
    setState(() {
      categories.removeWhere((c) => c.name == categoryName);
      categoryControllers[categoryName]?.dispose();
      categoryControllers.remove(categoryName);
      recipientCounts.remove(categoryName);
      customPercentages.remove(categoryName);
      percentageControllers[categoryName]?.dispose();
      percentageControllers.remove(categoryName);
    });
  }

  void _proceedToResult() {
    // Validate inputs
    bool hasValidRecipients = recipientCounts.values.any((count) => count > 0);
    if (!hasValidRecipients) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan minimal 1 penerima di setiap kategori'),
        ),
      );
      return;
    }

    // Calculate result
    try {
      final result = CalculatorService.calculate(
        templateId: widget.templateId,
        animals: animals,
        recipientCounts: recipientCounts,
        customPercentages: customPercentages,
      );

      context.push('/calculator-result', extra: result);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
          // Tab bar untuk Sapi dan Kambing
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
              children: [
                // Tab 1: Input data dan penerima
                _buildInputTab(),

                // Tab 2: Input data dan penerima untuk kambing
                _buildInputTab(),
              ],
            ),
          ),

          // Action button
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _proceedToResult,
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
                    Icon(Icons.done, color: Colors.white),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'Hitung',
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
          ),
        ],
      ),
    );
  }

  Widget _buildInputTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress
          _buildProgressIndicator(),
          const SizedBox(height: AppSpacing.xl),

          // Title
          Text(
            'Input Alokasi Daging',
            style: TextStyle(
              fontSize: AppTypography.headingLarge,
              fontWeight: AppTypography.bold,
              color: AppColors.textBase,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          Text(
            'Masukkan estimasi jumlah penerima manfaat untuk kalkulasi porsi distribusi yang presisi.',
            style: TextStyle(
              fontSize: AppTypography.bodyMedium,
              color: AppColors.textSubdued,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Recipient inputs
          ...categories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: _buildRecipientInput(category),
            );
          }),

          // For template C: Add category button
          if (widget.templateId == 'template_c') ...[
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
          ],

          // Info note
          if (widget.templateId == 'template_a')
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.lg),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.essentialBrightAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info,
                      color: AppColors.essentialBrightAccent,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        'Template A menggunakan rasio 1/3 : 1/3 : 1/3 secara default untuk alokasi Shohibul, Mustahik, dan Hadiah.',
                        style: TextStyle(
                          fontSize: AppTypography.bodySmall,
                          color: AppColors.textBase,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (widget.templateId == 'template_b')
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.lg),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.essentialBrightAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info,
                      color: AppColors.essentialBrightAccent,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        'Template B menggunakan rasio Shohibul dan Masyarakat untuk pembagian daging yang lebih proporsional.',
                        style: TextStyle(
                          fontSize: AppTypography.bodySmall,
                          color: AppColors.textBase,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildRecipientInput(RecipientCategory category) {
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
                  child: Text(
                    category.icon,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
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

          // Input fields
          if (widget.templateId == 'template_c') ...[
            // Percentage input for template C
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
                    controller: percentageControllers[category.name],
                    keyboardType: TextInputType.number,
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

          // Recipient count input
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
                controller: categoryControllers[category.name],
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    recipientCounts[category.name] = int.tryParse(value) ?? 0;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Masukkan jumlah orang',
                  suffixText: 'PERSONS',
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

  Widget _buildProgressIndicator() {
    int currentProgress = 2; // Step 2
    if (widget.templateId == 'template_c') {
      currentProgress = 3; // Step 3 for template C
    }
    double progressValue = currentProgress / 4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'STEP $currentProgress OF 4',
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

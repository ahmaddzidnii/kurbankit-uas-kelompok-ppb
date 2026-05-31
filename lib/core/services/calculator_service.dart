// Service untuk logika kalkulator pembagian daging qurban

import 'package:qurban_kit/features/qurban_distribution/data/models/calculator_models.dart';

class CalculatorService {
  // Template definitions
  static final List<CalculatorTemplate> templates = [
    CalculatorTemplate(
      id: 'template_b',
      name: 'Sederhana',
      description: 'Sederhana (1/3 Shohibul, 2/3 Masyarakat)',
      icon: '👥',
      categories: ['Shohibul', 'Masyarakat'],
    ),
    CalculatorTemplate(
      id: 'template_c',
      name: 'Kustom',
      description:
          'Kustom sesuai musyawarah, total 100%, tanpa melebihi total qurban',
      icon: '⚙️',
      categories: [],
    ),
  ];

  // Get template by ID
  static CalculatorTemplate? getTemplate(String templateId) {
    try {
      return templates.firstWhere((t) => t.id == templateId);
    } catch (e) {
      return null;
    }
  }

  // Get default recipient categories for template
  static List<RecipientCategory> getDefaultCategories(String templateId) {
    switch (templateId) {
      case 'template_b':
        return [
          RecipientCategory(
            name: 'Shohibul',
            icon: '🙎',
            description: 'Penerima dari pihak berkurban',
            count: 0,
          ),
          RecipientCategory(
            name: 'Masyarakat',
            icon: '👥',
            description: 'Penerima dari warga sekitar',
            count: 0,
          ),
        ];
      case 'template_c':
        return [];
      default:
        return [];
    }
  }

  // Calculate distribution based on template
  static CalculatorResult calculate({
    required String templateId,
    required List<AnimalData> animals,
    required Map<String, int> recipientCounts,
    required Map<String, double> customPercentages,
  }) {
    final template = getTemplate(templateId);
    if (template == null) {
      throw Exception('Template tidak ditemukan');
    }

    final totalWeight = animals.fold<double>(
      0,
      (sum, animal) => sum + (animal.weight * animal.count),
    );

    if (totalWeight <= 0) {
      throw Exception('Total berat qurban harus lebih dari 0');
    }

    Map<String, double> allocations = {};
    Map<String, double> perBagWeight = {};

    switch (templateId) {
      case 'template_b':
        // Alokasi: 1/3 Shohibul, 2/3 Masyarakat
        allocations['Shohibul'] = totalWeight / 3;
        allocations['Masyarakat'] = (totalWeight * 2) / 3;

        perBagWeight['Shohibul'] =
            recipientCounts['Shohibul'] != null &&
                recipientCounts['Shohibul']! > 0
            ? allocations['Shohibul']! / recipientCounts['Shohibul']!
            : 0;
        perBagWeight['Masyarakat'] =
            recipientCounts['Masyarakat'] != null &&
                recipientCounts['Masyarakat']! > 0
            ? allocations['Masyarakat']! / recipientCounts['Masyarakat']!
            : 0;
        break;

      case 'template_c':
        if (customPercentages.isEmpty) {
          throw Exception('Template kustom membutuhkan minimal 1 kategori');
        }

        final totalPercentage = customPercentages.values.fold<double>(
          0,
          (sum, percentage) => sum + percentage,
        );
        if ((totalPercentage - 100).abs() > 0.01) {
          throw Exception('Total persentase template kustom harus 100%');
        }

        // Alokasi berdasarkan persentase yang disepakati musyawarah,
        // dengan total tetap 100% agar sesuai kaidah pembagian.
        customPercentages.forEach((category, percentage) {
          if (percentage < 0) {
            throw Exception('Persentase tidak boleh negatif');
          }
          allocations[category] = (totalWeight * percentage) / 100;
          perBagWeight[category] =
              recipientCounts[category] != null &&
                  recipientCounts[category]! > 0
              ? allocations[category]! / recipientCounts[category]!
              : 0;
        });
        break;
    }

    // Calculate total bags (assuming 1 bag per recipient)
    int totalBags = recipientCounts.values.fold(0, (sum, count) => sum + count);

    return CalculatorResult(
      templateId: templateId,
      animals: animals,
      recipientCounts: recipientCounts,
      allocations: allocations,
      totalBags: totalBags,
      totalWeight: totalWeight,
      perBagWeight: perBagWeight,
    );
  }

  static CalculatorResult calculateForSingleAnimal({
    required String templateId,
    required String animalType,
    required double animalWeight,
    required Map<String, int> recipientCounts,
    required Map<String, double> customPercentages,
  }) {
    return calculate(
      templateId: templateId,
      animals: [AnimalData(type: animalType, weight: animalWeight, count: 1)],
      recipientCounts: recipientCounts,
      customPercentages: customPercentages,
    );
  }

  static CalculatorComparisonResult calculateComparison({
    required String templateId,
    required double sapiWeight,
    required double kambingWeight,
    required Map<String, int> sapiRecipientCounts,
    required Map<String, int> kambingRecipientCounts,
    required Map<String, double> sapiCustomPercentages,
    required Map<String, double> kambingCustomPercentages,
  }) {
    final sapiResult = sapiWeight > 0
        ? calculateForSingleAnimal(
            templateId: templateId,
            animalType: 'Sapi',
            animalWeight: sapiWeight,
            recipientCounts: sapiRecipientCounts,
            customPercentages: sapiCustomPercentages,
          )
        : null;

    final kambingResult = kambingWeight > 0
        ? calculateForSingleAnimal(
            templateId: templateId,
            animalType: 'Kambing',
            animalWeight: kambingWeight,
            recipientCounts: kambingRecipientCounts,
            customPercentages: kambingCustomPercentages,
          )
        : null;

    return CalculatorComparisonResult(
      sapiResult: sapiResult,
      kambingResult: kambingResult,
    );
  }

  // Format weight untuk display
  static String formatWeight(double weight) {
    return weight.toStringAsFixed(2);
  }

  // Validate input
  static String? validateRecipientCount(int? count) {
    if (count == null || count < 0) {
      return 'Jumlah harus lebih dari 0';
    }
    return null;
  }

  static String? validatePercentage(double? percentage) {
    if (percentage == null || percentage < 0 || percentage > 100) {
      return 'Persentase harus antara 0-100%';
    }
    return null;
  }
}

// Service untuk logika kalkulator pembagian daging qurban

import 'package:qurban_kit/data/models/calculator_models.dart';

class CalculatorService {
  // Template definitions
  static final List<CalculatorTemplate> templates = [
    CalculatorTemplate(
      id: 'template_a',
      name: 'Template A: Standar',
      description: 'Standar (Shohibul, Fakir Miskin, Warga Umum)',
      icon: '🏛️',
      categories: ['Shohibul', 'Fakir Miskin', 'Warga Umum'],
    ),
    CalculatorTemplate(
      id: 'template_b',
      name: 'Template B: Sederhana',
      description: 'Sederhana (Shohibul, Masyarakat)',
      icon: '👥',
      categories: ['Shohibul', 'Masyarakat'],
    ),
    CalculatorTemplate(
      id: 'template_c',
      name: 'Template C: Kustom',
      description: 'Kustom (Atur Persentase & Kategori Sendiri)',
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
      case 'template_a':
        return [
          RecipientCategory(
            name: 'Shohibul',
            icon: '🙏',
            description: 'Pekurban yang berhak menerima 1/3 bagian',
            count: 0,
          ),
          RecipientCategory(
            name: 'Fakir Miskin',
            icon: '🙎',
            description: 'Penerima prioritas mustahik zakat',
            count: 0,
          ),
          RecipientCategory(
            name: 'Warga Umum',
            icon: '👨‍👩‍👧‍👦',
            description: 'Masyarakat umum di lingkungan sekitar',
            count: 0,
          ),
        ];
      case 'template_b':
        return [
          RecipientCategory(
            name: 'Shohibul',
            icon: '🙏',
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

    double totalWeight = animals.fold(
      0,
      (sum, animal) => sum + (animal.weight * animal.count),
    );

    Map<String, double> allocations = {};
    Map<String, double> perBagWeight = {};

    switch (templateId) {
      case 'template_a':
        // Alokasi: 1/3 Shohibul, 1/3 Fakir Miskin, 1/3 Warga Umum
        allocations['Shohibul'] = totalWeight / 3;
        allocations['Fakir Miskin'] = totalWeight / 3;
        allocations['Warga Umum'] = totalWeight / 3;

        // Per bag weight
        perBagWeight['Shohibul'] =
            recipientCounts['Shohibul'] != null &&
                recipientCounts['Shohibul']! > 0
            ? allocations['Shohibul']! / recipientCounts['Shohibul']!
            : 0;
        perBagWeight['Fakir Miskin'] =
            recipientCounts['Fakir Miskin'] != null &&
                recipientCounts['Fakir Miskin']! > 0
            ? allocations['Fakir Miskin']! / recipientCounts['Fakir Miskin']!
            : 0;
        perBagWeight['Warga Umum'] =
            recipientCounts['Warga Umum'] != null &&
                recipientCounts['Warga Umum']! > 0
            ? allocations['Warga Umum']! / recipientCounts['Warga Umum']!
            : 0;
        break;

      case 'template_b':
        // Alokasi: 50% Shohibul, 50% Masyarakat
        allocations['Shohibul'] = totalWeight / 2;
        allocations['Masyarakat'] = totalWeight / 2;

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
        // Alokasi berdasarkan custom percentages
        customPercentages.forEach((category, percentage) {
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

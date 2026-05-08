// Model untuk calculator pembagian daging qurban

class CalculatorTemplate {
  final String id;
  final String name;
  final String description;
  final String icon;
  final List<String> categories;

  CalculatorTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.categories,
  });
}

class AnimalData {
  final String type; // sapi, kambing
  final double weight; // berat dalam kg
  int count; // jumlah hewan

  AnimalData({required this.type, required this.weight, this.count = 1});
}

class RecipientCategory {
  final String name;
  final String icon;
  final String description;
  int? count; // jumlah penerima
  double? percentage; // persentase untuk template custom

  RecipientCategory({
    required this.name,
    required this.icon,
    required this.description,
    this.count,
    this.percentage,
  });
}

class AllocationRule {
  final String categoryName;
  double percentage;
  int totalPersons;

  AllocationRule({
    required this.categoryName,
    required this.percentage,
    required this.totalPersons,
  });
}

class CalculatorResult {
  final String templateId;
  final List<AnimalData> animals;
  final Map<String, int> recipientCounts; // category -> count
  final Map<String, double> allocations; // category -> kg
  final int totalBags;
  final double totalWeight;
  final Map<String, double> perBagWeight; // category -> kg per bag

  CalculatorResult({
    required this.templateId,
    required this.animals,
    required this.recipientCounts,
    required this.allocations,
    required this.totalBags,
    required this.totalWeight,
    required this.perBagWeight,
  });
}

class CalculatorHistory {
  final String id;
  final String templateId;
  final String templateName;
  final DateTime createdAt;
  final CalculatorResult result;

  CalculatorHistory({
    required this.id,
    required this.templateId,
    required this.templateName,
    required this.createdAt,
    required this.result,
  });
}

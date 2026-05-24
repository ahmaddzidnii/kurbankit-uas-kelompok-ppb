class WilayahOption {
  final String id;
  final String nama;

  const WilayahOption({required this.id, required this.nama});

  factory WilayahOption.fromJson(Map<String, dynamic> json) {
    return WilayahOption(
      id: json['id']?.toString() ?? '',
      nama: json['nama']?.toString() ?? '',
    );
  }
}

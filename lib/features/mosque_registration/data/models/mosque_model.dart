enum MosqueStatus {
  pending,
  approved,
  rejected,
  active,
  takenDown;

  String toJson() => name;
  static MosqueStatus fromJson(String value) {
    return MosqueStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MosqueStatus.pending,
    );
  }
}

class MosqueModel {
  final String id;
  final String name;
  final String? operationalNumber;
  final String address;
  final String province;
  final String city;
  final String? photoUrl;
  final String adminName;
  final String adminPhone;
  final MosqueStatus status;
  final DateTime registeredAt;
  final DateTime? verifiedAt;

  MosqueModel({
    required this.id,
    required this.name,
    this.operationalNumber,
    required this.address,
    required this.province,
    required this.city,
    this.photoUrl,
    required this.adminName,
    required this.adminPhone,
    required this.status,
    required this.registeredAt,
    this.verifiedAt,
  });

  factory MosqueModel.fromJson(Map<String, dynamic> json) {
    return MosqueModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      operationalNumber: json['operationalNumber'],
      address: json['address'] ?? '',
      province: json['province'] ?? '',
      city: json['city'] ?? '',
      photoUrl: json['photoUrl'],
      adminName: json['adminName'] ?? '',
      adminPhone: json['adminPhone'] ?? '',
      status: MosqueStatus.fromJson(json['status'] ?? 'pending'),
      registeredAt:
          DateTime.tryParse(json['registeredAt'] ?? '') ?? DateTime.now(),
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.tryParse(json['verifiedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'operationalNumber': operationalNumber,
      'address': address,
      'province': province,
      'city': city,
      'photoUrl': photoUrl,
      'adminName': adminName,
      'adminPhone': adminPhone,
      'status': status.toJson(),
      'registeredAt': registeredAt.toIso8601String(),
      'verifiedAt': verifiedAt?.toIso8601String(),
    };
  }

  MosqueModel copyWith({
    String? id,
    String? name,
    String? operationalNumber,
    String? address,
    String? province,
    String? city,
    String? photoUrl,
    String? adminName,
    String? adminPhone,
    MosqueStatus? status,
    DateTime? registeredAt,
    DateTime? verifiedAt,
  }) {
    return MosqueModel(
      id: id ?? this.id,
      name: name ?? this.name,
      operationalNumber: operationalNumber ?? this.operationalNumber,
      address: address ?? this.address,
      province: province ?? this.province,
      city: city ?? this.city,
      photoUrl: photoUrl ?? this.photoUrl,
      adminName: adminName ?? this.adminName,
      adminPhone: adminPhone ?? this.adminPhone,
      status: status ?? this.status,
      registeredAt: registeredAt ?? this.registeredAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
    );
  }
}

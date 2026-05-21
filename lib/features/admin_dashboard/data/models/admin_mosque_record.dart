class AdminMosqueDetailWilayah {
  final String? kodePos;
  final String? desa;
  final String? kecamatan;
  final String? kabupaten;
  final String? provinsi;

  const AdminMosqueDetailWilayah({
    this.kodePos,
    this.desa,
    this.kecamatan,
    this.kabupaten,
    this.provinsi,
  });

  factory AdminMosqueDetailWilayah.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      return const AdminMosqueDetailWilayah();
    }

    return AdminMosqueDetailWilayah(
      kodePos: json['kodePos']?.toString(),
      desa: json['desa']?.toString(),
      kecamatan: json['kecamatan']?.toString(),
      kabupaten: json['kabupaten']?.toString(),
      provinsi: json['provinsi']?.toString(),
    );
  }

  String get formattedAddress {
    final parts = <String>[
      if (desa != null && desa!.isNotEmpty) desa!,
      if (kecamatan != null && kecamatan!.isNotEmpty) kecamatan!,
      if (kabupaten != null && kabupaten!.isNotEmpty) kabupaten!,
      if (provinsi != null && provinsi!.isNotEmpty) provinsi!,
    ];

    return parts.join(', ');
  }
}

class ObjectPengaju {
  final String? id;
  final String? name;
  final String? email;

  const ObjectPengaju({this.id, this.name, this.email});

  factory ObjectPengaju.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      return const ObjectPengaju();
    }

    return ObjectPengaju(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
    );
  }

  String get displayNameWithEmail {
    final nameValue = name?.trim();
    final emailValue = email?.trim();

    if (nameValue != null &&
        nameValue.isNotEmpty &&
        emailValue != null &&
        emailValue.isNotEmpty) {
      return '$nameValue ($emailValue)';
    }

    if (nameValue != null && nameValue.isNotEmpty) {
      return nameValue;
    }

    if (emailValue != null && emailValue.isNotEmpty) {
      return emailValue;
    }

    return '-';
  }
}

class AdminMosqueRecord {
  final String id;
  final String nama;
  final String? nomorSK;
  final String alamat;
  final String status;
  final String? gambarMasjidUrl;
  final String? dokumenSKUrl;
  final DateTime? createdAt;
  final AdminMosqueDetailWilayah detailWilayah;
  final ObjectPengaju pengaju;

  const AdminMosqueRecord({
    required this.id,
    required this.nama,
    this.nomorSK,
    required this.alamat,
    required this.status,
    this.gambarMasjidUrl,
    this.dokumenSKUrl,
    this.createdAt,
    required this.detailWilayah,
    required this.pengaju,
  });

  factory AdminMosqueRecord.fromJson(Map<String, dynamic> json) {
    return AdminMosqueRecord(
      id: json['id']?.toString() ?? '',
      nama: _readString(json, const ['nama', 'name']) ?? '',
      nomorSK: _readString(json, const [
        'nomorSK',
        'nomorSk',
        'operationalNumber',
      ]),
      alamat: _readString(json, const ['alamat', 'address']) ?? '',
      status: _readString(json, const ['status']) ?? 'UNKNOWN',
      gambarMasjidUrl: _readString(json, const ['gambarMasjidUrl', 'photoUrl']),
      dokumenSKUrl: _readString(json, const ['dokumenSKUrl', 'dokumenUrl']),
      createdAt: _parseDate(json['createdAt'] ?? json['registeredAt']),
      detailWilayah: AdminMosqueDetailWilayah.fromJson(json['detailWilayah']),
      pengaju: ObjectPengaju.fromJson(json['pemohon']),
    );
  }

  bool get isPending => status.toUpperCase() == 'PENDING';

  bool get isActive {
    final upper = status.toUpperCase();
    return upper == 'ACTIVE' || upper == 'AKTIF' || upper == 'APPROVED';
  }

  bool get isBlocked {
    final upper = status.toUpperCase();
    return upper == 'BLOCKED' || upper == 'BLOKIR' || upper == 'TAKEDOWN';
  }

  static String? _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null && value.toString().isNotEmpty) {
        return value.toString();
      }
    }
    return null;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }
}

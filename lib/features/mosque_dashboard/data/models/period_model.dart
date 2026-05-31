class PeriodModel {
  final String id;
  final String nama;
  final int tahunHijriah;
  final int tahunMasehi;
  final bool isActive;

  const PeriodModel({
    required this.id,
    required this.nama,
    required this.tahunHijriah,
    required this.tahunMasehi,
    required this.isActive,
  });

  factory PeriodModel.fromJson(Map<String, dynamic> json) {
    return PeriodModel(
      id: _readString(json, const ['id', '_id']) ?? '',
      nama: _readString(json, const ['nama', 'name', 'judul']) ?? '',
      tahunHijriah:
          _readInt(json, const [
            'tahun_hijriah',
            'tahunHijriah',
            'hijriah_year',
          ]) ??
          0,
      tahunMasehi:
          _readInt(json, const [
            'tahun_masehi',
            'tahunMasehi',
            'masehi_year',
          ]) ??
          0,
      isActive:
          _readBool(json, const ['is_active', 'isActive', 'active']) ?? false,
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'nama': nama,
      'tahun_hijriah': tahunHijriah,
      'tahun_masehi': tahunMasehi,
    };
  }

  Map<String, dynamic> toUpdateJson({bool includeActive = true}) {
    return {
      'nama': nama,
      'tahun_hijriah': tahunHijriah,
      'tahun_masehi': tahunMasehi,
      if (includeActive) 'is_active': isActive,
    };
  }

  PeriodModel copyWith({
    String? id,
    String? nama,
    int? tahunHijriah,
    int? tahunMasehi,
    bool? isActive,
  }) {
    return PeriodModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      tahunHijriah: tahunHijriah ?? this.tahunHijriah,
      tahunMasehi: tahunMasehi ?? this.tahunMasehi,
      isActive: isActive ?? this.isActive,
    );
  }

  String get displayTitle => nama.isEmpty ? 'Periode Tanpa Nama' : nama;

  String get displaySubtitle => 'Hijriah $tahunHijriah • Masehi $tahunMasehi';

  static String? _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
      if (value != null) {
        final text = value.toString().trim();
        if (text.isNotEmpty) {
          return text;
        }
      }
    }

    return null;
  }

  static int? _readInt(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is int) {
        return value;
      }
      if (value is String) {
        final parsed = int.tryParse(value.trim());
        if (parsed != null) {
          return parsed;
        }
      }
      if (value is num) {
        return value.toInt();
      }
    }

    return null;
  }

  static bool? _readBool(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is bool) {
        return value;
      }
      if (value is num) {
        return value != 0;
      }
      if (value is String) {
        final normalized = value.trim().toLowerCase();
        if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
          return true;
        }
        if (normalized == 'false' || normalized == '0' || normalized == 'no') {
          return false;
        }
      }
    }

    return null;
  }
}

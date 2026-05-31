import 'package:qurban_kit/core/configs/exceptions.dart';
import 'package:qurban_kit/core/services/api_client.dart';
import 'package:qurban_kit/features/mosque_dashboard/data/models/period_model.dart';

abstract class PeriodDataSource {
  Future<List<PeriodModel>> getPeriods();
  Future<PeriodModel> getPeriodById(String id);
  Future<PeriodModel?> createPeriod({
    required String nama,
    required int tahunHijriah,
    required int tahunMasehi,
  });
  Future<PeriodModel?> updatePeriod(
    String id, {
    String? nama,
    int? tahunHijriah,
    int? tahunMasehi,
    bool? isActive,
  });
  Future<void> deletePeriod(String id);
  Future<PeriodModel?> activatePeriod(String id);
}

class PeriodDataSourceImpl implements PeriodDataSource {
  final ApiClient _apiClient;

  static const String _baseEndpoint = '/periode';

  const PeriodDataSourceImpl(this._apiClient);

  @override
  Future<List<PeriodModel>> getPeriods() async {
    try {
      final response = await _apiClient.get(_baseEndpoint);
      final items = _asList(response);
      return items
          .whereType<Map<String, dynamic>>()
          .map(PeriodModel.fromJson)
          .toList();
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ServerException(
        message: 'Gagal mengambil daftar periode: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<PeriodModel> getPeriodById(String id) async {
    try {
      final response = await _apiClient.get('$_baseEndpoint/$id');
      final data = _asMap(response);
      return PeriodModel.fromJson(data);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ServerException(
        message: 'Gagal mengambil detail periode: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<PeriodModel?> createPeriod({
    required String nama,
    required int tahunHijriah,
    required int tahunMasehi,
  }) async {
    try {
      final response = await _postWithValidationFallback([
        {
          'nama': nama,
          'tahun_hijriah': tahunHijriah.toString(),
          'tahun_masehi': tahunMasehi.toString(),
        },
        {
          'nama': nama,
          'tahun_hijriyah': tahunHijriah.toString(),
          'tahun_masehi': tahunMasehi.toString(),
        },
      ]);
      final data = _extractPeriodData(response);
      return data == null ? null : PeriodModel.fromJson(data);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ServerException(
        message: 'Gagal menambah periode: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<PeriodModel?> updatePeriod(
    String id, {
    String? nama,
    int? tahunHijriah,
    int? tahunMasehi,
    bool? isActive,
  }) async {
    try {
      final basePayload = <String, dynamic>{
        if (nama != null) 'nama': nama,
        if (tahunHijriah != null) 'tahun_hijriah': tahunHijriah.toString(),
        if (tahunMasehi != null) 'tahun_masehi': tahunMasehi.toString(),
        if (isActive != null) 'is_active': isActive,
      };

      final altHijriyahPayload = <String, dynamic>{
        ...basePayload,
        if (basePayload.containsKey('tahun_hijriah'))
          'tahun_hijriyah': basePayload['tahun_hijriah'],
      };

      final stringYearPayload = <String, dynamic>{
        ...basePayload,
        if (tahunHijriah != null) 'tahun_hijriah': tahunHijriah,
        if (tahunMasehi != null) 'tahun_masehi': tahunMasehi,
      };

      final response = await _putWithValidationFallback(id, [
        basePayload,
        altHijriyahPayload,
        stringYearPayload,
      ]);
      final data = _extractPeriodData(response);
      return data == null ? null : PeriodModel.fromJson(data);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ServerException(
        message: 'Gagal memperbarui periode: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> deletePeriod(String id) async {
    try {
      await _apiClient.delete('$_baseEndpoint/$id');
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ServerException(
        message: 'Gagal menghapus periode: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<PeriodModel?> activatePeriod(String id) async {
    try {
      final response = await _apiClient.post(
        '$_baseEndpoint/$id/activate',
        data: const {},
      );
      final data = _extractPeriodData(response);
      return data == null ? null : PeriodModel.fromJson(data);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ServerException(
        message: 'Gagal mengaktifkan periode: $e',
        statusCode: 500,
      );
    }
  }

  List<dynamic> _asList(dynamic response) {
    if (response is List<dynamic>) {
      return response;
    }

    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is List<dynamic>) {
        return data;
      }
    }

    return const [];
  }

  Map<String, dynamic> _asMap(dynamic response) {
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
      return response;
    }

    return <String, dynamic>{};
  }

  Map<String, dynamic>? _extractPeriodData(dynamic response) {
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
      return response;
    }

    return null;
  }

  Future<dynamic> _postWithValidationFallback(
    List<Map<String, dynamic>> payloads,
  ) async {
    ValidationException? lastValidationError;

    for (var i = 0; i < payloads.length; i++) {
      try {
        return await _apiClient.post(_baseEndpoint, data: payloads[i]);
      } on ValidationException catch (e) {
        lastValidationError = e;
        if (i == payloads.length - 1) {
          rethrow;
        }
      }
    }

    if (lastValidationError != null) {
      throw lastValidationError;
    }

    throw ServerException(
      message: 'Gagal membuat periode karena payload tidak valid',
      statusCode: 500,
    );
  }

  Future<dynamic> _putWithValidationFallback(
    String id,
    List<Map<String, dynamic>> payloads,
  ) async {
    ValidationException? lastValidationError;

    for (var i = 0; i < payloads.length; i++) {
      try {
        return await _apiClient.put('$_baseEndpoint/$id', data: payloads[i]);
      } on ValidationException catch (e) {
        lastValidationError = e;
        if (i == payloads.length - 1) {
          rethrow;
        }
      }
    }

    if (lastValidationError != null) {
      throw lastValidationError;
    }

    throw ServerException(
      message: 'Gagal memperbarui periode karena payload tidak valid',
      statusCode: 500,
    );
  }
}

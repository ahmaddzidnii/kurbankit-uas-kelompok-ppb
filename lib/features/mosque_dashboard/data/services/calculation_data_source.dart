import 'package:qurban_kit/core/configs/exceptions.dart';
import 'package:qurban_kit/core/services/api_client.dart';

abstract class CalculationDataSource {
  Future<List<Map<String, dynamic>>> getCalculationsForPeriod(String periodeId);
  Future<Map<String, dynamic>> getCalculationById(String id);
  Future<Map<String, dynamic>> createCalculation({
    required String idPeriode,
    required String judul,
    required String jenisHewan,
    required String template,
    required Map<String, dynamic> detail,
  });
  Future<void> deleteCalculation(String id);
  Future<Map<String, dynamic>> updateCalculationTitle(String id, String judul);
}

class CalculationDataSourceImpl implements CalculationDataSource {
  final ApiClient _apiClient;
  static const String _base = '/perhitungan';

  CalculationDataSourceImpl(this._apiClient);

  @override
  Future<List<Map<String, dynamic>>> getCalculationsForPeriod(
    String periodeId,
  ) async {
    final paramNames = [
      'periodeId',
      'idPeriode',
      'periodId',
      'periode_id',
      'id_periode',
    ];
    Object? lastError;

    for (final param in paramNames) {
      try {
        final res = await _apiClient.get(
          _base,
          queryParameters: {param: periodeId},
        );

        // Debug: print raw response shape to assist troubleshooting
        try {
          // ignore: avoid_print
          print(
            '[CalculationDataSource] GET $_base?$param=$periodeId -> ${res.runtimeType}',
          );
          // ignore: avoid_print
          print(res);
        } catch (_) {}

        List<dynamic>? list;

        if (res is List) {
          list = res;
        } else if (res is Map<String, dynamic>) {
          // Common envelope keys
          list =
              res['data'] as List<dynamic>? ??
              res['items'] as List<dynamic>? ??
              res['results'] as List<dynamic>? ??
              res['perhitungan'] as List<dynamic>?;
          // If map contains single object, not list
          if (list == null) {
            final possibleItem = res['data'] is Map<String, dynamic>
                ? res['data']
                : res;
            if (possibleItem is Map<String, dynamic> &&
                (possibleItem.containsKey('id') ||
                    possibleItem.containsKey('_id'))) {
              list = [possibleItem];
            }
          }
        }

        if (list == null) {
          // try next param name
          continue;
        }

        // Normalize each item to UI-friendly shape expected by PeriodCalculationsPage
        final normalized = <Map<String, dynamic>>[];
        for (final raw in list) {
          if (raw is! Map<String, dynamic>) continue;

          final id =
              raw['id'] ?? raw['_id'] ?? raw['perhitungan_id'] ?? raw['uuid'];
          String? jenis =
              raw['jenisHewan'] ??
              raw['jenis_hewan'] ??
              raw['animalType'] ??
              raw['jenis'];
          if (jenis == null) {
            final d = raw['detail'];
            if (d is Map<String, dynamic>) {
              jenis =
                  d['jenisHewan'] ??
                  d['jenis_hewan'] ??
                  d['animalType'] ??
                  d['jenis'];
            }
          }
          if (jenis is String) jenis = jenis.toLowerCase();

          final title =
              raw['judul'] ?? raw['title'] ?? raw['nama'] ?? raw['label'];
          final templateName =
              raw['templateName'] ??
              raw['template_name'] ??
              raw['template'] ??
              raw['templateId'];
          final savedAt =
              raw['savedAt'] ??
              raw['createdAt'] ??
              raw['created_at'] ??
              raw['saved_at'] ??
              raw['updatedAt'];

          normalized.add({
            'id': id?.toString() ?? '',
            'animalType': jenis?.toString().toLowerCase() ?? '',
            'title': title?.toString() ?? (raw['judul']?.toString() ?? ''),
            'templateName': templateName?.toString() ?? '',
            'savedAt': savedAt?.toString(),
            'createdAt': raw['createdAt'] ?? raw['created_at'],
            'raw': raw,
          });
        }

        return normalized;
      } catch (e) {
        lastError = e;
        // try next param
        continue;
      }
    }

    if (lastError != null) {
      if (lastError is AppException) throw lastError;
      throw ServerException(
        message: 'Gagal mengambil perhitungan: $lastError',
        statusCode: 500,
      );
    }

    return <Map<String, dynamic>>[];
  }

  @override
  Future<Map<String, dynamic>> getCalculationById(String id) async {
    try {
      final res = await _apiClient.get('$_base/$id');
      if (res is Map<String, dynamic>) {
        final data = res['data'] ?? res;
        return Map<String, dynamic>.from(data);
      }
      return {};
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException(
        message: 'Gagal mengambil detail perhitungan: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> createCalculation({
    required String idPeriode,
    required String judul,
    required String jenisHewan,
    required String template,
    required Map<String, dynamic> detail,
  }) async {
    try {
      final payload = {
        'idPeriode': idPeriode,
        'judul': judul,
        'jenisHewan': jenisHewan,
        'template': template,
        'detail': detail,
      };

      final res = await _apiClient.post(_base, data: payload);
      if (res is Map<String, dynamic>) {
        final data = res['data'] ?? res;
        return Map<String, dynamic>.from(data);
      }
      return {};
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException(
        message: 'Gagal membuat perhitungan: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> deleteCalculation(String id) async {
    try {
      await _apiClient.delete('$_base/$id');
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException(
        message: 'Gagal menghapus perhitungan: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> updateCalculationTitle(
    String id,
    String judul,
  ) async {
    try {
      final res = await _apiClient.post('$_base/$id', data: {'judul': judul});
      if (res is Map<String, dynamic>) {
        final data = res['data'] ?? res;
        return Map<String, dynamic>.from(data);
      }
      return {};
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException(
        message: 'Gagal memperbarui judul perhitungan: $e',
        statusCode: 500,
      );
    }
  }
}

import 'package:qurban_kit/core/configs/exceptions.dart';
import 'package:qurban_kit/core/services/api_client.dart';
import 'package:qurban_kit/features/mosque_registration/data/models/wilayah_model.dart';

abstract class WilayahDataSource {
  Future<List<WilayahOption>> getProvinces({String? search});
  Future<List<WilayahOption>> getKabupaten({required String parentId});
  Future<List<WilayahOption>> getKecamatan({required String parentId});
  Future<List<WilayahOption>> getDesa({required String parentId});
}

class WilayahDataSourceImpl implements WilayahDataSource {
  final ApiClient _apiClient;

  const WilayahDataSourceImpl(this._apiClient);

  @override
  Future<List<WilayahOption>> getProvinces({String? search}) {
    return _fetchWilayah(level: 'provinsi', search: search);
  }

  @override
  Future<List<WilayahOption>> getKabupaten({required String parentId}) {
    return _fetchWilayah(level: 'kabupaten', parentId: parentId);
  }

  @override
  Future<List<WilayahOption>> getKecamatan({required String parentId}) {
    return _fetchWilayah(level: 'kecamatan', parentId: parentId);
  }

  @override
  Future<List<WilayahOption>> getDesa({required String parentId}) {
    return _fetchWilayah(level: 'desa', parentId: parentId);
  }

  Future<List<WilayahOption>> _fetchWilayah({
    required String level,
    String? parentId,
    String? search,
  }) async {
    try {
      final queryParameters = <String, dynamic>{'level': level};

      if (parentId != null && parentId.isNotEmpty) {
        queryParameters['parent_id'] = parentId;
      }

      if (search != null && search.trim().isNotEmpty) {
        queryParameters['search'] = search.trim();
      }

      final response = await _apiClient.get(
        '/wilayah',
        queryParameters: queryParameters,
      );

      final items = _asList(response);
      return items
          .whereType<Map<String, dynamic>>()
          .map(WilayahOption.fromJson)
          .where((item) => item.id.isNotEmpty && item.nama.isNotEmpty)
          .toList();
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }

      throw ServerException(
        message: 'Gagal mengambil data wilayah: $e',
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
}

import 'package:qurban_kit/core/configs/exceptions.dart';
import 'package:qurban_kit/core/services/api_client.dart';
import 'package:qurban_kit/features/admin_dashboard/data/models/admin_mosque_record.dart';

abstract class AdminMosqueDataSource {
  Future<List<AdminMosqueRecord>> getRegistrationRequests();
  Future<List<AdminMosqueRecord>> getMosques();
  Future<void> approveRegistration(String requestId);
  Future<void> rejectRegistration(String requestId, {String? reason});
  Future<void> blockMosque(String mosqueId, {String? reason});
}

class AdminMosqueDataSourceImpl implements AdminMosqueDataSource {
  final ApiClient _apiClient;

  const AdminMosqueDataSourceImpl(this._apiClient);

  @override
  Future<List<AdminMosqueRecord>> getRegistrationRequests() async {
    try {
      final response = await _apiClient.get('/masjid/list-permintaan');
      final items = _asList(response);
      return items
          .whereType<Map<String, dynamic>>()
          .map(AdminMosqueRecord.fromJson)
          .toList();
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ServerException(
        message: 'Gagal mengambil daftar permintaan: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<AdminMosqueRecord>> getMosques() async {
    try {
      final response = await _apiClient.get('/masjid');
      final items = _asList(response);
      return items
          .whereType<Map<String, dynamic>>()
          .map(AdminMosqueRecord.fromJson)
          .toList();
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ServerException(
        message: 'Gagal mengambil daftar masjid: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> approveRegistration(String requestId) async {
    try {
      await _apiClient.post(
        '/masjid/permintaan/$requestId/approve',
        data: const {},
      );
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ServerException(
        message: 'Gagal menyetujui permintaan: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> rejectRegistration(String requestId, {String? reason}) async {
    try {
      await _apiClient.post(
        '/masjid/permintaan/$requestId/reject',
        data: {if (reason != null && reason.isNotEmpty) 'reason': reason},
      );
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ServerException(
        message: 'Gagal menolak permintaan: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> blockMosque(String mosqueId, {String? reason}) async {
    try {
      await _apiClient.post(
        '/masjid/$mosqueId/blokir',
        data: {if (reason != null && reason.isNotEmpty) 'reason': reason},
      );
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ServerException(
        message: 'Gagal memblokir masjid: $e',
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

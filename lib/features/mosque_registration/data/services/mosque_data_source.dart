import 'package:dio/dio.dart';
import 'package:qurban_kit/core/configs/exceptions.dart';
import 'package:qurban_kit/core/services/api_client.dart';
import 'package:qurban_kit/features/mosque_registration/data/models/mosque_model.dart';
import 'package:qurban_kit/features/mosque_registration/data/models/mosque_registration_request_model.dart';

abstract class MosqueDataSource {
  /// Register a new mosque
  Future<MosqueModel> registerMosque(MosqueRegistrationRequest request);

  /// Get mosque registrations with optional status filter
  Future<List<MosqueModel>> getMosqueRegistrations({MosqueStatus? status});

  /// Get a specific mosque by ID
  Future<MosqueModel> getMosqueById(String id);

  /// Approve a mosque registration
  Future<void> approveMosqueRegistration(VerificationApprovalRequest request);

  /// Reject a mosque registration
  Future<void> rejectMosqueRegistration(VerificationRejectionRequest request);

  /// Perform takedown on a mosque
  Future<void> takedownMosque(MosqueTakedownRequest request);

  /// Get all active mosques (for takedown list)
  Future<List<MosqueModel>> getActiveMosques();

  /// Get all taken-down mosques
  Future<List<MosqueModel>> getTakenDownMosques();
}

class MosqueDataSourceImpl implements MosqueDataSource {
  final ApiClient _apiClient;

  static const String _baseEndpoint = '/api/mosques';

  MosqueDataSourceImpl(this._apiClient);

  @override
  Future<MosqueModel> registerMosque(MosqueRegistrationRequest request) async {
    try {
      final response = await _apiClient.post(
        '/masjid/permintaan',
        data: request.toFormData(),
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      if (response is Map<String, dynamic>) {
        final data = response['data'] ?? response;
        if (data is Map<String, dynamic>) {
          return MosqueModel.fromJson(data);
        }
      }

      throw ServerException(
        message: 'Failed to register mosque: unexpected response format',
      );
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }

  @override
  Future<List<MosqueModel>> getMosqueRegistrations({
    MosqueStatus? status,
  }) async {
    try {
      final params = status != null ? {'status': status.toJson()} : null;
      final response = await _apiClient.get(
        '$_baseEndpoint/registrations',
        queryParameters: params,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data
            .map((item) => MosqueModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to fetch registrations',
          statusCode: response.statusCode ?? 500,
        );
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }

  @override
  Future<MosqueModel> getMosqueById(String id) async {
    try {
      final response = await _apiClient.get('$_baseEndpoint/$id');

      if (response.statusCode == 200) {
        return MosqueModel.fromJson(response.data['data'] ?? response.data);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to fetch mosque',
          statusCode: response.statusCode ?? 500,
        );
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }

  @override
  Future<void> approveMosqueRegistration(
    VerificationApprovalRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        '$_baseEndpoint/approve',
        data: request.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to approve mosque',
          statusCode: response.statusCode ?? 500,
        );
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }

  @override
  Future<void> rejectMosqueRegistration(
    VerificationRejectionRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        '$_baseEndpoint/reject',
        data: request.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to reject mosque',
          statusCode: response.statusCode ?? 500,
        );
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }

  @override
  Future<void> takedownMosque(MosqueTakedownRequest request) async {
    try {
      final response = await _apiClient.post(
        '$_baseEndpoint/takedown',
        data: request.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to takedown mosque',
          statusCode: response.statusCode ?? 500,
        );
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }

  @override
  Future<List<MosqueModel>> getActiveMosques() async {
    try {
      final response = await _apiClient.get('$_baseEndpoint/active');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data
            .map((item) => MosqueModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to fetch active mosques',
          statusCode: response.statusCode ?? 500,
        );
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }

  @override
  Future<List<MosqueModel>> getTakenDownMosques() async {
    try {
      final response = await _apiClient.get('$_baseEndpoint/taken-down');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data
            .map((item) => MosqueModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          message:
              response.data['message'] ?? 'Failed to fetch taken-down mosques',
          statusCode: response.statusCode ?? 500,
        );
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }
}

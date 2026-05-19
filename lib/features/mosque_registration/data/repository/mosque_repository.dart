import 'package:qurban_kit/core/configs/exceptions.dart';
import 'package:qurban_kit/core/services/user_role_service.dart';
import 'package:qurban_kit/features/mosque_registration/data/models/mosque_model.dart';
import 'package:qurban_kit/features/mosque_registration/data/models/mosque_registration_request_model.dart';
import 'package:qurban_kit/features/mosque_registration/data/sources/mosque_data_source.dart';

abstract class MosqueRepository {
  Future<MosqueModel> registerMosque(MosqueRegistrationRequest request);
  Future<List<MosqueModel>> getMosqueRegistrations({MosqueStatus? status});
  Future<MosqueModel> getMosqueById(String id);
  Future<void> approveMosqueRegistration(VerificationApprovalRequest request);
  Future<void> rejectMosqueRegistration(VerificationRejectionRequest request);
  Future<void> takedownMosque(MosqueTakedownRequest request);
  Future<List<MosqueModel>> getActiveMosques();
  Future<List<MosqueModel>> getTakenDownMosques();
}

class MosqueRepositoryImpl implements MosqueRepository {
  final MosqueDataSource _dataSource;

  MosqueRepositoryImpl(this._dataSource);

  @override
  Future<MosqueModel> registerMosque(MosqueRegistrationRequest request) async {
    try {
      final mosque = await _dataSource.registerMosque(request);

      // Mark mosque as registered in local storage
      await UserRoleService.setMosqueRegistered(true);

      return mosque;
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ServerException(
        message: 'Failed to register mosque: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<MosqueModel>> getMosqueRegistrations({
    MosqueStatus? status,
  }) async {
    try {
      return await _dataSource.getMosqueRegistrations(status: status);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ServerException(
        message: 'Failed to fetch registrations: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<MosqueModel> getMosqueById(String id) async {
    try {
      return await _dataSource.getMosqueById(id);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ServerException(
        message: 'Failed to fetch mosque: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> approveMosqueRegistration(
    VerificationApprovalRequest request,
  ) async {
    try {
      await _dataSource.approveMosqueRegistration(request);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ServerException(
        message: 'Failed to approve mosque: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> rejectMosqueRegistration(
    VerificationRejectionRequest request,
  ) async {
    try {
      await _dataSource.rejectMosqueRegistration(request);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ServerException(
        message: 'Failed to reject mosque: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> takedownMosque(MosqueTakedownRequest request) async {
    try {
      await _dataSource.takedownMosque(request);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ServerException(
        message: 'Failed to takedown mosque: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<MosqueModel>> getActiveMosques() async {
    try {
      return await _dataSource.getActiveMosques();
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ServerException(
        message: 'Failed to fetch active mosques: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<MosqueModel>> getTakenDownMosques() async {
    try {
      return await _dataSource.getTakenDownMosques();
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ServerException(
        message: 'Failed to fetch taken-down mosques: $e',
        statusCode: 500,
      );
    }
  }
}

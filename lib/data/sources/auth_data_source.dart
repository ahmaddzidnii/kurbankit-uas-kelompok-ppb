import 'package:qurban_kit/core/configs/api_config.dart';
import 'package:qurban_kit/core/configs/exceptions.dart';
import 'package:qurban_kit/core/services/api_client.dart';
import 'package:qurban_kit/data/models/auth_models.dart';

abstract class AuthDataSource {
  Future<LoginResponse> login(LoginRequest request);
  Future<RegisterResponse> register(RegisterRequest request);
  Future<UserData> getProfile();
  Future<void> logout();
}

class AuthDataSourceImpl implements AuthDataSource {
  final ApiClient _apiClient;

  AuthDataSourceImpl(this._apiClient);

  @override
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.authLogin,
        data: request.toJson(),
      );

      if (response is! Map<String, dynamic>) {
        throw ServerException(
          message:
              'Response format tidak sesuai: expected Map, got ${response.runtimeType}',
        );
      }

      if (!response.containsKey('accessToken')) {
        throw ServerException(
          message:
              'Response tidak memiliki field accessToken. Keys: ${response.keys.join(", ")}',
        );
      }

      return LoginResponse.fromJson(response);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ServerException(message: 'Login gagal: $e');
    }
  }

  @override
  Future<RegisterResponse> register(RegisterRequest request) async {
    final response = await _apiClient.post(
      ApiConfig.authRegister,
      data: request.toJson(),
    );

    return RegisterResponse.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<UserData> getProfile() async {
    try {
      final response = await _apiClient.get(ApiConfig.authProfile);

      if (response is! Map<String, dynamic>) {
        throw ServerException(
          message:
              'Response format tidak sesuai: expected Map, got ${response.runtimeType}',
        );
      }

      return UserData.fromJson(response);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ServerException(message: 'Gagal fetch profile: $e');
    }
  }

  @override
  Future<void> logout() async {
    await _apiClient.post(ApiConfig.authLogout, data: {});
    _apiClient.clearAuthToken();
  }
}

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:qurban_kit/core/configs/exceptions.dart';
import 'package:qurban_kit/core/services/api_client.dart';
import 'package:qurban_kit/core/services/user_role_service.dart';
import 'package:qurban_kit/features/auth/data/models/auth_models.dart';
import 'package:qurban_kit/features/auth/data/services/auth_data_source.dart';

abstract class AuthRepository {
  Future<UserData> login(String email, String password);
  Future<RegisterResponse> register(String name, String email, String password);
  Future<void> logout();
  Future<UserData?> getProfile();
  Future<void> saveToken(String token);
  Future<String?> getAccessToken();
  Future<void> clearTokens();
  Future<bool> restoreToken();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _dataSource;
  final FlutterSecureStorage _secureStorage;
  final ApiClient _apiClient;

  static const String _accessTokenKey = 'access_token';

  AuthRepositoryImpl(this._dataSource, this._secureStorage, this._apiClient);

  @override
  Future<UserData> login(String email, String password) async {
    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _dataSource.login(request);

      // Save token
      await saveToken(response.accessToken);

      // Set token in API client for subsequent requests
      _apiClient.setAuthToken(response.accessToken);

      // Fetch user profile
      final user = await _dataSource.getProfile();

      // Save user role for role-based routing
      if (user.role != null) {
        await UserRoleService.setUserRole(user.role!);
      }

      return user;
    } catch (e) {
      // Re-throw app exceptions as-is
      if (e is AppException) {
        rethrow;
      }
      // Log unexpected errors
      print('Login error: $e');
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }

  @override
  Future<RegisterResponse> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final request = RegisterRequest(
        name: name,
        email: email,
        password: password,
      );
      final response = await _dataSource.register(request);

      return response;
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ServerException(message: 'Registrasi gagal. Silakan coba lagi.');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dataSource.logout();
      await clearTokens();
      // Clear role and mosque registration data
      await UserRoleService.clearUserRoleData();
    } catch (e) {
      // Clear tokens even if logout API fails
      await clearTokens();
      await UserRoleService.clearUserRoleData();
      if (e is AppException) {
        rethrow;
      }
    }
  }

  @override
  Future<UserData?> getProfile() async {
    try {
      return await _dataSource.getProfile();
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      return null;
    }
  }

  @override
  Future<void> saveToken(String token) async {
    try {
      await _secureStorage.write(key: _accessTokenKey, value: token);
    } catch (e) {
      throw CacheException(message: 'Failed to save token');
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      return await _secureStorage.read(key: _accessTokenKey);
    } catch (e) {
      throw CacheException(message: 'Failed to retrieve access token');
    }
  }

  @override
  Future<void> clearTokens() async {
    try {
      await _secureStorage.delete(key: _accessTokenKey);
      _apiClient.clearAuthToken();
    } catch (e) {
      throw CacheException(message: 'Failed to clear tokens');
    }
  }

  @override
  Future<bool> restoreToken() async {
    try {
      final token = await getAccessToken();
      if (token != null && token.isNotEmpty) {
        _apiClient.setAuthToken(token);
        return true;
      }
      return false;
    } catch (e) {
      print('Error restoring token: $e');
      return false;
    }
  }
}

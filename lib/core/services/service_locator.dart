import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:qurban_kit/core/services/api_client.dart';
import 'package:qurban_kit/data/repository/auth_repository.dart';
import 'package:qurban_kit/data/sources/auth_data_source.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Core Services
  getIt.registerSingleton<ApiClient>(ApiClient());
  getIt.registerSingleton<FlutterSecureStorage>(const FlutterSecureStorage());

  // Data Sources
  getIt.registerSingleton<AuthDataSource>(
    AuthDataSourceImpl(getIt<ApiClient>()),
  );

  // Repositories
  getIt.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(
      getIt<AuthDataSource>(),
      getIt<FlutterSecureStorage>(),
      getIt<ApiClient>(),
    ),
  );
}

// Helper functions for easy access
AuthRepository get authRepository => getIt<AuthRepository>();
ApiClient get apiClient => getIt<ApiClient>();

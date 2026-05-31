import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:qurban_kit/core/services/api_client.dart';
import 'package:qurban_kit/features/auth/data/services/auth_repository.dart';
import 'package:qurban_kit/features/mosque_dashboard/data/services/period_data_source.dart';
import 'package:qurban_kit/features/mosque_registration/data/services/mosque_repository.dart';
import 'package:qurban_kit/features/admin_dashboard/data/services/admin_mosque_data_source.dart';
import 'package:qurban_kit/features/auth/data/services/auth_data_source.dart';
import 'package:qurban_kit/features/mosque_registration/data/services/mosque_data_source.dart';
import 'package:qurban_kit/features/mosque_registration/data/services/wilayah_data_source.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Core Services
  getIt.registerSingleton<ApiClient>(ApiClient());
  getIt.registerSingleton<FlutterSecureStorage>(const FlutterSecureStorage());

  // Data Sources
  getIt.registerSingleton<AuthDataSource>(
    AuthDataSourceImpl(getIt<ApiClient>()),
  );

  getIt.registerSingleton<MosqueDataSource>(
    MosqueDataSourceImpl(getIt<ApiClient>()),
  );

  getIt.registerSingleton<WilayahDataSource>(
    WilayahDataSourceImpl(getIt<ApiClient>()),
  );

  getIt.registerSingleton<AdminMosqueDataSource>(
    AdminMosqueDataSourceImpl(getIt<ApiClient>()),
  );

  getIt.registerSingleton<PeriodDataSource>(
    PeriodDataSourceImpl(getIt<ApiClient>()),
  );

  // Repositories
  getIt.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(
      getIt<AuthDataSource>(),
      getIt<FlutterSecureStorage>(),
      getIt<ApiClient>(),
    ),
  );

  getIt.registerSingleton<MosqueRepository>(
    MosqueRepositoryImpl(getIt<MosqueDataSource>()),
  );
}

// Helper functions for easy access
AuthRepository get authRepository => getIt<AuthRepository>();
MosqueRepository get mosqueRepository => getIt<MosqueRepository>();
ApiClient get apiClient => getIt<ApiClient>();
AdminMosqueDataSource get adminMosqueDataSource =>
    getIt<AdminMosqueDataSource>();
PeriodDataSource get periodDataSource => getIt<PeriodDataSource>();

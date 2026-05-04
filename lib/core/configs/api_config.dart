class ApiConfig {
  // Base URL - Production API
  static const String baseUrl = 'https://qurbankit-backend-api.netlify.app';

  // Endpoints
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authProfile = '/auth/profile';
  static const String authLogout = '/auth/logout';

  // Timeouts (dalam milliseconds)
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;
}

class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;

  AppException({required this.message, this.code, this.originalException});

  @override
  String toString() => message;
}

class ServerException extends AppException {
  final int? statusCode;
  final dynamic response;

  ServerException({
    required String message,
    this.statusCode,
    this.response,
    String? code,
  }) : super(message: message, code: code ?? 'SERVER_ERROR');
}

class NetworkException extends AppException {
  NetworkException({required String message, dynamic originalException})
    : super(
        message: message,
        code: 'NETWORK_ERROR',
        originalException: originalException,
      );
}

class UnauthorizedException extends AppException {
  UnauthorizedException({required String message})
    : super(message: message, code: 'UNAUTHORIZED');
}

class ValidationException extends AppException {
  final Map<String, dynamic>? errors;

  ValidationException({required String message, this.errors})
    : super(message: message, code: 'VALIDATION_ERROR');
}

class CacheException extends AppException {
  CacheException({required String message})
    : super(message: message, code: 'CACHE_ERROR');
}

class ParseException extends AppException {
  ParseException({required String message})
    : super(message: message, code: 'PARSE_ERROR');
}

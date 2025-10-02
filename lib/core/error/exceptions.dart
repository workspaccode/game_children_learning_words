/// Exception thrown when there's a problem with the cache.
class CacheException implements Exception {

  CacheException([this.message]);
  final String? message;
}

/// Exception thrown when there's a problem with the server.
class ServerException implements Exception {

  ServerException([this.message]);
  final String? message;
}

/// Exception thrown when a user is not found.
class UserNotFoundException implements Exception {

  UserNotFoundException([this.message]);
  final String? message;
}

/// Exception thrown when authentication fails.
class AuthenticationException implements Exception {

  AuthenticationException([this.message]);
  final String? message;
}

/// Exception thrown when there's a network failure.
class NetworkException implements Exception {

  NetworkException([this.message]);
  final String? message;
}

/// Exception thrown when there's a validation failure.
class ValidationException implements Exception {

  ValidationException([this.message]);
  final String? message;
}

/// Exception thrown when there's a unauthorized access.
class UnauthorizedException implements Exception {

  UnauthorizedException([this.message]);
  final String? message;
}

/// Exception thrown when there's a permission error.
class PermissionException implements Exception {

  PermissionException([this.message]);
  final String? message;
}

/// Exception thrown when data is not found.
class NotFoundException implements Exception {

  NotFoundException([this.message]);
  final String? message;
}

/// Exception thrown when data is already exists.
class AlreadyExistsException implements Exception {

  AlreadyExistsException([this.message]);
  final String? message;
}

/// Exception thrown when there's an invalid operation.
class InvalidOperationException implements Exception {

  InvalidOperationException([this.message]);
  final String? message;
}

/// Exception thrown when rate limit is exceeded.
class RateLimitException implements Exception {

  RateLimitException([this.message, this.retryAfter]);
  final String? message;
  final DateTime? retryAfter;
}

/// Exception thrown when there's a business logic error.
class BusinessException implements Exception {

  BusinessException([this.message, this.code]);
  final String? message;
  final String? code;
}

/// Exception thrown when there's an audio-related error.
class AudioException implements Exception {

  AudioException([this.message]);
  final String? message;
}

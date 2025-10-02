import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DioClient {

  DioClient() {
    _dio = Dio();
    _initializeInterceptors();
  }
  static const String baseUrl = 'https://api.learningwords.com/v1/';
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  late Dio _dio;

  Dio get dio => _dio;

  void _initializeInterceptors() {
    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(milliseconds: connectTimeout),
      receiveTimeout: const Duration(milliseconds: receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // Add logging interceptor in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          logPrint: (object) => debugPrint(object.toString()),
        ),
      );
    }

    // Add auth interceptor
    _dio.interceptors.add(AuthInterceptor());

    // Add error interceptor
    _dio.interceptors.add(ErrorInterceptor());
  }
}

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add auth token if available
    // final token = getIt<AuthService>().user?.accessToken;
    // if (token != null) {
    //   options.headers['Authorization'] = 'Bearer $token';
    // }
    handler.next(options);
  }
}

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('DioError: ${err.message}');

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw TimeoutException();
      case DioExceptionType.badResponse:
        switch (err.response?.statusCode) {
          case 400:
            throw BadRequestException();
          case 401:
            throw UnauthorizedException();
          case 403:
            throw ForbiddenException();
          case 404:
            throw NotFoundException();
          case 500:
            throw InternalServerErrorException();
          default:
            throw UnknownException();
        }
      case DioExceptionType.cancel:
        throw RequestCancelledException();
      case DioExceptionType.unknown:
        throw NoInternetConnectionException();
      default:
        throw UnknownException();
    }
  }
}

// Custom exceptions
abstract class ApiException implements Exception {
  ApiException(this.message);
  final String message;
}

class TimeoutException extends ApiException {
  TimeoutException() : super('انتهت مهلة الاتصال');
}

class BadRequestException extends ApiException {
  BadRequestException() : super('طلب غير صحيح');
}

class UnauthorizedException extends ApiException {
  UnauthorizedException() : super('غير مخول للوصول');
}

class ForbiddenException extends ApiException {
  ForbiddenException() : super('ممنوع الوصول');
}

class NotFoundException extends ApiException {
  NotFoundException() : super('المورد غير موجود');
}

class InternalServerErrorException extends ApiException {
  InternalServerErrorException() : super('خطأ في الخادم');
}

class NoInternetConnectionException extends ApiException {
  NoInternetConnectionException() : super('لا يوجد اتصال بالإنترنت');
}

class RequestCancelledException extends ApiException {
  RequestCancelledException() : super('تم إلغاء الطلب');
}

class UnknownException extends ApiException {
  UnknownException() : super('حدث خطأ غير متوقع');
}

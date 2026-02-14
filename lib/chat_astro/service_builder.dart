import 'package:dio/dio.dart';

/// Service Builder for API communication
/// Equivalent to Kotlin's ServiceBuilder using OkHttp and Retrofit
class ServiceBuilder {
  static const String baseUrl = "https://test.bhagyag.com";

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  /// Get Dio instance for making API calls
  static Dio get dio => _dio;

  /// Build service with custom interceptors if needed
  static Dio buildService() {
    // Add interceptors for logging, authentication, etc.
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
      request: true,
      requestHeader: true,
    ));

    return _dio;
  }
}
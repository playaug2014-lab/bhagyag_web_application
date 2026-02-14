import 'package:dio/dio.dart';
import 'dart:io';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late Dio _dio;

  // Replace with your actual base URL
  static const String baseUrl = 'https://test.bhagyag.com/';

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'multipart/form-data',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptor for logging (optional)
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        requestHeader: true,
        responseHeader: false,
      ),
    );
  }

  /// Submit astrologer registration profile
  Future<AstroRegResponse> submitProfile({
    required String fullName,
    required String dateOfBirth,
    required String placeOfBirth,
    required String gender,
    required String knownLanguages,
    required String specializedIns,
    required String experience,
    required String emailId,
    required String phone,
    required String addressStatus,
    required String address,
    required String emergencyContact,
    required String emergencyContactName,
    required String passport,
    required String dl,
    required String aadhaarCard,
    required String whatsappNo,
    required String bloodGroup,
    required String familyMembersCount,
    required String kids,
    required String maritalStatus,
    required String minimumHours,
    required String daysAvailability,
    required String availabilityShift,
    required String aboutMe,
    required String certification,
    required String district,
    required String state,
    required String pincode,
    File? resumeFile,
  }) async {
    try {
      // Build query parameters
      final queryParams = {
        'fullName': fullName,
        'dateOfBirth': dateOfBirth,
        'placeOfBirth': placeOfBirth,
        'gender': gender,
        'knownLanguages': knownLanguages,
        'specializedIns': specializedIns,
        'experience': experience,
        'emailId': emailId,
        'phone': phone,
        'addressStatus': addressStatus,
        'address': address,
        'emergencyContact': emergencyContact,
        'emergencyContactName': emergencyContactName,
        'passport': passport,
        'DL': dl,
        'aadhaarCard': aadhaarCard,
        'whatsappNo': whatsappNo,
        'bloodGroup': bloodGroup,
        'familyMembersCount': familyMembersCount,
        'kids': kids,
        'maritalStatus': maritalStatus,
        'minimumHours': minimumHours,
        'daysAvailability': daysAvailability,
        'availabilityShift': availabilityShift,
        'abountMe': aboutMe,
        'certification': certification,
        'district': district,
        'state': state,
        'pincode': pincode,
      };

      // Create FormData for file upload
      FormData formData = FormData();

      // Add resume file if provided
      if (resumeFile != null) {
        String fileName = resumeFile.path.split('/').last;
        formData.files.add(
          MapEntry(
            'resume',
            await MultipartFile.fromFile(
              resumeFile.path,
              filename: fileName,
            ),
          ),
        );
      }

      final response = await _dio.post(
        '/api/AstroHiring/AstroHiringProfile',
        queryParameters: queryParams,
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AstroRegResponse.fromJson(response.data);
      } else {
        throw ApiException(
          message: 'Failed to submit registration',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException(
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  ApiException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Connection timeout. Please check your internet connection.',
          statusCode: error.response?.statusCode,
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        String message = 'Server error occurred';

        if (statusCode == 400) {
          message = 'Invalid request. Please check your information.';
        } else if (statusCode == 401) {
          message = 'Unauthorized access.';
        } else if (statusCode == 404) {
          message = 'Service not found.';
        } else if (statusCode == 500) {
          message = 'Server error. Please try again later.';
        }

        // Try to extract message from response
        if (error.response?.data != null) {
          if (error.response!.data is Map) {
            message = error.response!.data['message'] ?? message;
          }
        }

        return ApiException(
          message: message,
          statusCode: statusCode,
        );

      case DioExceptionType.cancel:
        return ApiException(
          message: 'Request was cancelled',
        );

      case DioExceptionType.connectionError:
        return ApiException(
          message: 'No internet connection. Please check your network.',
        );

      default:
        return ApiException(
          message: 'An unexpected error occurred. Please try again.',
        );
    }
  }
}

/// Response model for astrologer registration
class AstroRegResponse {
  final String message;

  AstroRegResponse({required this.message});

  factory AstroRegResponse.fromJson(Map<String, dynamic> json) {
    return AstroRegResponse(
      message: json['message'] ?? 'Registration submitted successfully',
    );
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => message;
}

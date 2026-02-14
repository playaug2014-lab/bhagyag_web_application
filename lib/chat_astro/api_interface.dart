import 'package:dio/dio.dart';
import 'dart:io';  // For File class
import 'service_builder.dart';
import 'chat_models.dart';

/// API Interface for Chat Operations
/// Equivalent to Kotlin's ApiInterface with Retrofit annotations
class ApiInterface {
  final Dio _dio = ServiceBuilder.buildService();

  /// Request Chat Session
  /// POST api/ChatSession
  /// Equivalent to Kotlin's @POST("api/ChatSession") fun requestchatseesion(@Body requestModel: Requestchat): Call<ChatModel>
  Future<ChatModel> requestChatSession(RequestChat request) async {
    try {
      print('🔵 Requesting chat session...');
      print('🔵 Request body: ${request.toJson()}');

      final response = await _dio.post(
        '/api/ChatSession',
        data: request.toJson(),
      );

      print('✅ Chat session response received');
      print('✅ Status code: ${response.statusCode}');
      print('✅ Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final chatModel = ChatModel.fromJson(response.data);
        print('✅ Chat session created successfully');
        print('✅ Chat Session ID: ${chatModel.record.chatSessionId}');
        print('✅ Message: ${chatModel.message}');
        return chatModel;
      } else {
        print('⚠️ Unexpected status code: ${response.statusCode}');
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: 'Unexpected status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('❌ DioException occurred');
      print('❌ Type: ${e.type}');
      print('❌ Message: ${e.message}');
      print('❌ Response: ${e.response?.data}');

      if (e.response != null) {
        throw Exception(
          'API Error: ${e.response?.statusCode} - ${e.response?.data}',
        );
      } else {
        throw Exception('Network Error: ${e.message}');
      }
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw Exception('Failed to request chat session: $e');
    }
  }

  /// Get Wallet Balance (additional method as seen in Kotlin code)
  Future<WalletBalanceModel> getWalletBalance(String userId) async {
    try {
      print('🔵 Getting wallet balance for user: $userId');
      print('🔵 Full URL: ${_dio.options.baseUrl}/api/Wallet/$userId');

      final response = await _dio.get(
        '/api/Wallet/$userId',
        options: Options(
          validateStatus: (status) {
            // Accept all status codes to see what's happening
            return status! < 500;
          },
        ),
      );

      print('✅ Wallet response received');
      print('✅ Status Code: ${response.statusCode}');
      print('✅ Response Data: ${response.data}');
      print('✅ Response Type: ${response.data.runtimeType}');

      if (response.statusCode == 200) {
        if (response.data is Map<String, dynamic>) {
          final walletModel = WalletBalanceModel.fromJson(response.data);
          print('✅ Wallet balance retrieved: ₹${walletModel.balance}');
          return walletModel;
        } else {
          print('❌ Invalid response format. Expected Map, got ${response.data.runtimeType}');
          throw Exception('Invalid response format from server');
        }
      } else if (response.statusCode == 404) {
        print('⚠️ User not found (404)');
        throw Exception('User not found. Please check the user ID.');
      } else if (response.statusCode == 401) {
        print('⚠️ Unauthorized (401) - Authentication required');
        throw Exception('Unauthorized. Please log in again.');
      } else {
        print('❌ Unexpected status code: ${response.statusCode}');
        throw Exception('Failed to get wallet balance. Status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ DioException occurred');
      print('❌ Type: ${e.type}');
      print('❌ Message: ${e.message}');
      print('❌ Response: ${e.response?.data}');

      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout. Server not responding.');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Server is taking too long to respond.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Cannot connect to server. Check internet connection.');
      } else if (e.response != null) {
        throw Exception('Server error: ${e.response?.statusCode} - ${e.response?.data}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('❌ Unexpected error in getWalletBalance: $e');
      rethrow;
    }
  }

  /// Deduct amount for chat
  Future<DeductChatResponse> deductAmountForChat(
      String userId,
      String astrologerId,
      ) async {
    try {
      print('🔵 Deducting amount for chat...');
      print('🔵 User ID: $userId, Astrologer ID: $astrologerId');
      print('🔵 Endpoint: POST /api/PaymentGatewayHistory/DeductForService2');

      final response = await _dio.post(
        '/api/PaymentGatewayHistory/DeductForService2',  // FIXED: Correct endpoint from Kotlin
        queryParameters: {  // FIXED: Using query parameters (not body)
          'userId': userId,
          'astrologerId': astrologerId,
        },
      );

      print('✅ Deduct response received');
      print('✅ Status: ${response.statusCode}');
      print('✅ Data: ${response.data}');

      if (response.statusCode == 200) {
        print('✅ Amount deducted successfully');
        return DeductChatResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to deduct amount. Status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ DioException in deductAmountForChat');
      print('❌ Type: ${e.type}');
      print('❌ Message: ${e.message}');
      print('❌ Response: ${e.response?.data}');

      if (e.response?.statusCode == 400) {
        throw Exception('Insufficient balance or invalid request');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Endpoint not found. Please check server configuration.');
      } else {
        throw Exception('Failed to deduct amount: ${e.message}');
      }
    } catch (e) {
      print('❌ Unexpected error in deductAmountForChat: $e');
      rethrow;
    }
  }

  /// Send Chat Message
  /// POST /api/Chat
  /// Equivalent to Kotlin's @POST("/api/Chat") fun requestchatsend(@Body requestModel: RequestSendChat): Call<ChatSendModel>
  Future<ChatSendModel> sendChatMessage(RequestSendChat request) async {
    try {
      print('🔵 Sending chat message to API...');
      print('🔵 Chat Session ID: ${request.chatSessionId}');
      print('🔵 Message: ${request.messageText}');
      print('🔵 Sender ID: ${request.senderId}');
      print('🔵 Message Type: ${request.msgType}');

      final response = await _dio.post(
        '/api/Chat',
        data: request.toJson(),
      );

      print('✅ Chat message response received');
      print('✅ Status code: ${response.statusCode}');
      print('✅ Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final chatSendModel = ChatSendModel.fromJson(response.data);
        print('✅ Chat message sent to API successfully');
        print('✅ Message: ${chatSendModel.message}');
        print('✅ Chat ID: ${chatSendModel.record.chatId}');
        return chatSendModel;
      } else {
        throw Exception('Failed to send chat message. Status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Error sending chat message: ${e.message}');
      print('❌ Response: ${e.response?.data}');

      if (e.response != null) {
        throw Exception('API Error: ${e.response?.statusCode} - ${e.response?.data}');
      } else {
        throw Exception('Network Error: ${e.message}');
      }
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw Exception('Failed to send chat message: $e');
    }
  }

  /// Upload Chat Image
  /// POST /api/Chat/ChatImagePost
  /// Equivalent to Kotlin's chatsends
  Future<ImageUploadResponse> uploadChatImage({
    required int chatSessionId,
    required String senderId,
    required File imageFile,
  }) async {
    try {
      print('🔵 Uploading chat image...');
      print('🔵 Chat Session ID: $chatSessionId');
      print('🔵 Sender ID: $senderId');

      // Create multipart request
      final fileName = imageFile.path.split('/').last;
      final formData = FormData.fromMap({
        'imageFile': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        '/api/Chat/ChatImagePost',
        data: formData,
        queryParameters: {
          'ChatSessionId': chatSessionId,
          'SenderId': senderId,
        },
      );

      if (response.statusCode == 200) {
        print('✅ Image uploaded successfully');
        return ImageUploadResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to upload image');
      }
    } on DioException catch (e) {
      print('❌ Error uploading image: ${e.message}');
      print('❌ Response: ${e.response?.data}');
      rethrow;
    }
  }

  /// Update Firebase ID
  /// POST /api/User/UpdateFirebaseID
  /// Equivalent to Kotlin's updatefirebaseid
  Future<FirebaseUpdateResponse> updateFirebaseId({
    required String userId,
    required String firebaseId,
    required String chatStatus,
  }) async {
    try {
      print('🔵 Updating Firebase ID...');
      print('🔵 User ID: $userId');
      print('🔵 Firebase ID: $firebaseId');
      print('🔵 Chat Status: $chatStatus');

      final response = await _dio.post(
        '/api/User/UpdateFirebaseID',
        queryParameters: {
          'UserId': userId,
          'FirebaseID': firebaseId,
          'ChatStatus': chatStatus,
        },
      );

      if (response.statusCode == 200) {
        print('✅ Firebase ID updated successfully');
        return FirebaseUpdateResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to update Firebase ID');
      }
    } on DioException catch (e) {
      print('❌ Error updating Firebase ID: ${e.message}');
      print('❌ Response: ${e.response?.data}');
      rethrow;
    }
  }
}

/// Wallet Balance Model
class WalletBalanceModel {
  final double balance;

  WalletBalanceModel({required this.balance});

  factory WalletBalanceModel.fromJson(Map<String, dynamic> json) {
    print('🔍 Parsing wallet response JSON: $json');
    print('🔍 Available keys: ${json.keys}');

    double balance = 0.0;

    // Try different possible response structures

    // Option 1: Direct balance field
    if (json.containsKey('balance')) {
      balance = _parseBalance(json['balance']);
      print('✅ Found direct balance field: $balance');
    }
    // Option 2: Nested in 'data' object
    else if (json.containsKey('data') && json['data'] is Map) {
      final data = json['data'] as Map<String, dynamic>;
      if (data.containsKey('balance')) {
        balance = _parseBalance(data['balance']);
        print('✅ Found balance in data object: $balance');
      }
    }
    // Option 3: Nested in 'record' object
    else if (json.containsKey('record') && json['record'] is Map) {
      final record = json['record'] as Map<String, dynamic>;
      if (record.containsKey('balance')) {
        balance = _parseBalance(record['balance']);
        print('✅ Found balance in record object: $balance');
      }
    }
    // Option 4: Other possible field names
    else if (json.containsKey('amount')) {
      balance = _parseBalance(json['amount']);
      print('✅ Found amount field: $balance');
    } else if (json.containsKey('walletBalance')) {
      balance = _parseBalance(json['walletBalance']);
      print('✅ Found walletBalance field: $balance');
    }

    if (balance == 0.0) {
      print('⚠️ Could not find balance in response');
      print('⚠️ Response structure: $json');
    }

    return WalletBalanceModel(balance: balance);
  }

  /// Helper method to parse balance from different types
  static double _parseBalance(dynamic value) {
    if (value == null) {
      return 0.0;
    } else if (value is double) {
      return value;
    } else if (value is int) {
      return value.toDouble();
    } else if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    print('⚠️ Unknown balance type: ${value.runtimeType}');
    return 0.0;
  }

  @override
  String toString() => 'WalletBalanceModel(balance: ₹$balance)';
}

/// Deduct Chat Response
/// Matches Kotlin: data class DeductChat(val message: String)
class DeductChatResponse {
  final String message;
  final bool success;  // Derived from message

  DeductChatResponse({
    required this.message,
    required this.success,
  });

  factory DeductChatResponse.fromJson(Map<String, dynamic> json) {
    print('🔍 Parsing deduct chat response: $json');

    final message = json['message']?.toString() ?? '';

    // Determine success based on message or explicit success field
    bool success = false;

    // Check for explicit success field
    if (json.containsKey('success')) {
      success = json['success'] == true || json['success'] == 'true';
    }
    // Or infer from message (common patterns)
    else if (message.isNotEmpty) {
      success = message.toLowerCase().contains('success') ||
          message.toLowerCase().contains('deducted') ||
          message.toLowerCase().contains('completed');
    }

    print('✅ Parsed - Message: "$message", Success: $success');

    return DeductChatResponse(
      message: message,
      success: success,
    );
  }

  @override
  String toString() => 'DeductChatResponse(message: $message, success: $success)';
}

/// Firebase Update Response
/// Equivalent to Kotlin's FireUpdateResp
class FirebaseUpdateResponse {
  final String status;

  FirebaseUpdateResponse({required this.status});

  factory FirebaseUpdateResponse.fromJson(Map<String, dynamic> json) {
    return FirebaseUpdateResponse(
      status: json['status'] ?? '',
    );
  }
}

/// Image Upload Response
/// Equivalent to Kotlin's response
class ImageUploadResponse {
  final String profileImage;
  final String message;

  ImageUploadResponse({
    required this.profileImage,
    required this.message,
  });

  factory ImageUploadResponse.fromJson(Map<String, dynamic> json) {
    return ImageUploadResponse(
      profileImage: json['profileImage'] ?? '',
      message: json['message'] ?? '',
    );
  }
}
// lib/services/agora_service.dart
// ✅ FIXED iOS VERSION - Matches Android Architecture
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AgoraService {
  // ✅ CRITICAL: Must match Android EXACTLY
  static const String APP_ID = "81b7c75580174bbb88f53e5543676cc1";
  static const String APP_CERTIFICATE = "9cf7fac7168048a39a1c778bffe6866a";
  static const String CHANNEL_NAME = "Liverec";

  // ✅ NEW Token API endpoint
  static const String TOKEN_API = "https://agoratoken-1.onrender.com/rtcToken";

  // Recording API endpoint
  static const String RECORDING_API_BASE = "https://test.bhagyag.com/api/S3Bucket";

  // ✅ Get token AND UID from SERVER (NEW API returns both)
  static Future<Map<String, dynamic>?> getTokenAndUidFromServer({
    required String channelName,
  }) async {
    try {
      print('🔑 FETCHING TOKEN AND UID FROM SERVER');
      print('   API: $TOKEN_API');
      print('   Channel: $channelName');

      // ✅ Use POST request with JSON body (only channelName needed)
      final response = await http.post(
        Uri.parse(TOKEN_API),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'channelName': channelName,
        }),
      );

      print('   Request Body: {"channelName": "$channelName"}');
      print('📡 Token API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseBody = response.body.trim();
        print('   Response body: $responseBody');

        try {
          final data = jsonDecode(responseBody);
          final uid = data['uid'] as int?;
          final token = data['token'] as String?;

          if (uid != null && token != null && token.isNotEmpty) {
            // Validate UID for iOS
            if (uid <= 0) {
              print('⚠️ Warning: Server returned UID <= 0: $uid');
            }

            // Validate token format
            if (!token.startsWith('007')) {
              print('⚠️ Warning: Token may have unexpected format: ${token.substring(0, min(10, token.length))}...');
            }

            print('✅ Token and UID received successfully');
            print('   UID: $uid');
            print('   Token Length: ${token.length}');
            print('   Token Format: ${token.substring(0, min(3, token.length))}...${token.substring(max(0, token.length - 10))}');

            return {
              'uid': uid,
              'token': token,
            };
          } else {
            print('❌ UID or Token is null/empty in response');
            print('   UID: $uid');
            print('   Token: $token');
          }
        } catch (jsonError) {
          print('❌ Failed to parse response: $jsonError');
          print('   Response body: $responseBody');
        }
      } else {
        print('❌ Token API error: ${response.statusCode}');
        print('   Response body: ${response.body}');
      }

      return null;
    } catch (e, stackTrace) {
      print('❌ Token fetch error: $e');
      print('   Stack: $stackTrace');
      return null;
    }
  }

  // ✅ Start recording with iOS compatibility (matching Android)
  static Future<String?> startRecording({
    required String channelName,
    required int uid,
    required String token,
    String recordingMode = 'video', // ✅ ADDED: 'video' or 'audio'
  }) async {
    try {
      print('🔴 STARTING RECORDING');
      print('   Channel: $channelName');
      print('   UID: $uid');
      print('   Platform: ${Platform.isIOS ? "iOS" : "Android"}');
      print('   Recording Mode: $recordingMode'); // ✅ ADDED
      print('   Token length: ${token.length}');

      final response = await http.post(
        Uri.parse('$RECORDING_API_BASE/start'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'channelName': channelName,
          'uid': uid.toString(),
          'token': token,
          'platform': Platform.isIOS ? 'ios' : 'android',
          'recordingMode': recordingMode, // ✅ ADDED: Specify audio or video
        }),
      );

      print('📡 Recording API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final sid = data['sid'] as String?;

        if (sid != null && sid.isNotEmpty) {
          // Save recording state
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('recording_sid', sid);
          await prefs.setString('recording_channel', channelName);
          await prefs.setInt('recording_uid', uid);
          await prefs.setBool('is_recording', true);
          await prefs.setString('recording_mode', recordingMode); // ✅ ADDED: Save mode

          print('✅ Recording started successfully');
          print('   SID: $sid');
          print('   Mode: $recordingMode'); // ✅ ADDED
          return sid;
        } else {
          print('❌ Recording SID is null or empty');
          print('   Response: ${response.body}');
        }
      } else {
        print('❌ Recording API error: ${response.statusCode}');
        print('   Response: ${response.body}');
      }

      return null;
    } catch (e, stackTrace) {
      print('❌ Recording error: $e');
      print('   Stack: $stackTrace');
      return null;
    }
  }

  // ✅ Stop recording
  static Future<bool> stopRecording({
    required String channelName,
    required int uid,
    required String sid,
  }) async {
    try {
      print('⏹️ STOPPING RECORDING');
      print('   Channel: $channelName');
      print('   UID: $uid');
      print('   SID: $sid');

      final response = await http.post(
        Uri.parse('$RECORDING_API_BASE/stop'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'channelName': channelName,
          'uid': uid.toString(),
          'sid': sid,
        }),
      );

      print('📡 Stop Recording Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Clear recording state
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('recording_sid');
        await prefs.remove('recording_channel');
        await prefs.remove('recording_uid');
        await prefs.setBool('is_recording', false);
        await prefs.remove('recording_mode'); // ✅ ADDED: Clear mode

        print('✅ Recording stopped successfully');
        return true;
      }

      print('❌ Recording stop failed: ${response.body}');
      return false;
    } catch (e, stackTrace) {
      print('❌ Stop recording error: $e');
      print('   Stack: $stackTrace');
      return false;
    }
  }

  // ✅ Get saved recording SID
  static Future<String?> getRecordingSID() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('recording_sid');
    } catch (e) {
      print('❌ Error getting recording SID: $e');
      return null;
    }
  }

  // ✅ Check if currently recording
  static Future<bool> isRecording() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('is_recording') ?? false;
    } catch (e) {
      return false;
    }
  }

  // ✅ Clear recording state
  static Future<void> clearRecordingState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('recording_sid');
      await prefs.remove('recording_channel');
      await prefs.remove('recording_uid');
      await prefs.setBool('is_recording', false);
      await prefs.remove('recording_mode'); // ✅ ADDED: Clear mode
      print('✅ Recording state cleared');
    } catch (e) {
      print('❌ Error clearing recording state: $e');
    }
  }

  // ✅ Platform-specific debug info
  static void debugInfo() {
    print('\n📊 AGORA DEBUG INFO');
    print('   Platform: ${Platform.isIOS ? "iOS" : "Android"}');
    print('   App ID: $APP_ID');
    print('   Channel: $CHANNEL_NAME');
    print('   Token API: $TOKEN_API');
    print('   Recording API: $RECORDING_API_BASE');
    print('═══════════════════════════════════════════════════════\n');
  }
}

// Helper function for min/max
int min(int a, int b) => a < b ? a : b;
int max(int a, int b) => a > b ? a : b;
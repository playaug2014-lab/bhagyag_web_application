// lib/utils/agora_debug_helper.dart
// ✅ DEBUG UTILITY FOR TROUBLESHOOTING AGORA ISSUES

import 'dart:io';
import 'package:flutter/foundation.dart';
import '../astrologer/agora_service.dart';
import '../astrologer/agora_config.dart';

class AgoraDebugHelper {
  /// ✅ Comprehensive system check
  static Future<void> runDiagnostics() async {
    print('\n' + '=' * 60);
    print('🔍 AGORA DIAGNOSTICS STARTING');
    print('=' * 60 + '\n');

    // 1. Platform info
    _checkPlatform();

    // 2. Configuration
    _checkConfiguration();

    // 3. Test token generation
    await _testTokenGeneration();

    // 4. Test recording API
    await _testRecordingAPI();

    print('\n' + '=' * 60);
    print('🔍 DIAGNOSTICS COMPLETE');
    print('=' * 60 + '\n');
  }

  /// Check platform details
  static void _checkPlatform() {
    print('📱 PLATFORM INFO:');
    print('   OS: ${Platform.operatingSystem}');
    print('   Version: ${Platform.operatingSystemVersion}');
    print('   Is iOS: ${Platform.isIOS}');
    print('   Is Android: ${Platform.isAndroid}');
    print('');
  }

  /// Check configuration
  static void _checkConfiguration() {
    print('⚙️  CONFIGURATION:');
    print('   App ID: ${AgoraConfig.APP_ID}');
    print('   App ID Length: ${AgoraConfig.APP_ID.length}');
    print('   App ID Format Valid: ${_validateUUID(AgoraConfig.APP_ID)}');
    print('   Certificate Length: ${AgoraConfig.APP_CERTIFICATE.length}');
    print('   Certificate Format Valid: ${_validateUUID(AgoraConfig.APP_CERTIFICATE)}');
    print('   Channel Name: ${AgoraConfig.CHANNEL_NAME}');
    print('   Token API: ${AgoraService.TOKEN_API}');
    print('   Recording API: ${AgoraService.RECORDING_API_BASE}');
    print('');
  }

  /// Test token generation
  static Future<void> _testTokenGeneration() async {
    print('🔑 TOKEN GENERATION TEST:');

    try {
      print('   Calling server API...');

      final result = await AgoraService.getTokenAndUidFromServer(
        channelName: AgoraConfig.CHANNEL_NAME,
      );

      if (result != null) {
        final uid = result['uid'] as int;
        final token = result['token'] as String;

        print('   ✅ Token and UID received successfully');
        print('   UID: $uid');
        print('   Token Length: ${token.length}');
        print('   Token Prefix: ${token.substring(0, 3)}');
        print('   Starts with 007: ${token.startsWith('007') ? '✅' : '❌'}');
        print('   Token Preview: ${token.substring(0, min(30, token.length))}...');
      } else {
        print('   ❌ Token generation failed');
        print('   Result is null');
      }
    } catch (e) {
      print('   ❌ Token generation error: $e');
    }
    print('');
  }

  /// Test recording API connectivity
  static Future<void> _testRecordingAPI() async {
    print('🎥 RECORDING API TEST:');
    print('   This will test API connectivity only (not actual recording)');
    print('   API Base: ${AgoraService.RECORDING_API_BASE}');
    print('   Start Endpoint: ${AgoraService.RECORDING_API_BASE}/start');
    print('   Stop Endpoint: ${AgoraService.RECORDING_API_BASE}/stop');
    print('   ℹ️  Skipping actual API call to avoid creating test sessions');
    print('');
  }

  /// Validate UUID format (32 hex characters)
  static bool _validateUUID(String uuid) {
    if (uuid.length != 32) return false;
    return RegExp(r'^[0-9a-fA-F]{32}$').hasMatch(uuid);
  }

  /// Test complete flow with mock data
  static Future<void> testCompleteFlow() async {
    print('\n' + '=' * 60);
    print('🚀 TESTING COMPLETE AGORA FLOW');
    print('=' * 60 + '\n');

    // Step 1: Get UID and token from server
    print('Step 1: Get UID and Token from Server');
    final result = await AgoraService.getTokenAndUidFromServer(
      channelName: AgoraConfig.CHANNEL_NAME,
    );

    if (result == null) {
      print('   ❌ FAILED: Could not get token and UID\n');
      print('🛑 FLOW STOPPED: Fix token generation first\n');
      return;
    }

    final uid = result['uid'] as int;
    final token = result['token'] as String;

    print('   UID: $uid ✅');
    print('   Token: ${token.substring(0, 20)}... ✅\n');

    // Step 2: Simulate join (we won't actually join)
    print('Step 2: Join Channel (Simulated)');
    print('   Channel: ${AgoraConfig.CHANNEL_NAME}');
    print('   UID: $uid');
    print('   Token: Ready ✅\n');

    // Step 3: Check recording state
    print('Step 3: Check Recording State');
    final isRecording = await AgoraService.isRecording();
    print('   Currently Recording: $isRecording');
    final sid = await AgoraService.getRecordingSID();
    print('   Recording SID: ${sid ?? 'None'}\n');

    print('=' * 60);
    print('✅ FLOW TEST COMPLETE');
    print('=' * 60 + '\n');
  }

  /// Quick check before joining channel
  static Future<bool> preJoinCheck({
    required String channelName,
    required int uid,
    required String token,
  }) async {
    print('\n📋 PRE-JOIN CHECKLIST:');

    bool allGood = true;

    // 1. Channel name
    if (channelName.isEmpty) {
      print('   ❌ Channel name is empty');
      allGood = false;
    } else {
      print('   ✅ Channel name: $channelName');
    }

    // 2. UID validation
    if (uid <= 0) {
      print('   ❌ UID is invalid: $uid (must be > 0 for iOS)');
      allGood = false;
    } else if (uid > 100000) {
      print('   ⚠️  UID is very large: $uid (might cause issues)');
    } else {
      print('   ✅ UID: $uid');
    }

    // 3. Token validation
    if (token.isEmpty) {
      print('   ❌ Token is empty');
      allGood = false;
    } else if (!token.startsWith('007')) {
      print('   ⚠️  Token has unexpected format: ${token.substring(0, 3)}');
    } else {
      print('   ✅ Token: ${token.substring(0, 20)}...');
    }

    // 4. Platform check
    if (Platform.isIOS) {
      print('   ✅ Platform: iOS');
    } else {
      print('   ✅ Platform: ${Platform.operatingSystem}');
    }

    print('');

    if (allGood) {
      print('✅ All checks passed - Ready to join!\n');
    } else {
      print('❌ Some checks failed - Fix issues before joining!\n');
    }

    return allGood;
  }

  /// Monitor Agora connection
  static void logConnectionEvent({
    required String event,
    String? channelId,
    int? uid,
    String? error,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    print('[$timestamp] 📡 AGORA EVENT: $event');
    if (channelId != null) print('   Channel: $channelId');
    if (uid != null) print('   UID: $uid');
    if (error != null) print('   Error: $error');
  }

  /// Compare with Android parameters
  static void compareWithAndroid({
    required String androidToken,
    required int androidUid,
    required String iosToken,
    required int iosUid,
  }) {
    print('\n🔄 ANDROID vs iOS COMPARISON:');
    print('   Android UID: $androidUid');
    print('   iOS UID: $iosUid');
    print('   UIDs Match: ${androidUid == iosUid ? '✅' : '❌'}');
    print('');
    print('   Android Token: ${androidToken.substring(0, 20)}...');
    print('   iOS Token: ${iosToken.substring(0, 20)}...');
    print('   Tokens Match: ${androidToken == iosToken ? '✅' : '❌'}');
    print('');
  }
}

int min(int a, int b) => a < b ? a : b;
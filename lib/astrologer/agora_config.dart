// lib/config/agora_config.dart
class AgoraConfig {
  // ✅ Production Configuration
  static const String APP_ID = "81b7c75580174bbb88f53e5543676cc1";
  static const String APP_CERTIFICATE = "9cf7fac7168048a39a1c778bffe6866a";
  static const String CHANNEL_NAME = "Liverec";

  // ✅ iOS-specific settings
  static const int MIN_IOS_UID = 10; // iOS requires UID > 0 (matching Android's min of 10)
  static const int MAX_UID = 9999; // Matching Android's max range

  // ✅ Token expiration (in seconds)
  static const int TOKEN_EXPIRATION_SECONDS = 300; // 5 minutes (matching Android)
}



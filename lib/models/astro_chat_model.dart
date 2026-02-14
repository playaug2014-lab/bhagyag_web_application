// lib/models/astro_chat_model.dart
class AstroChat {
  final String message;
  final List<UserChatDetail> record;

  AstroChat({
    required this.message,
    required this.record,
  });

  factory AstroChat.fromJson(Map<String, dynamic> json) {
    return AstroChat(
      message: json['message'] ?? '',
      record: (json['record'] as List?)
          ?.map((e) => UserChatDetail.fromJson(e))
          .toList() ??
          [],
    );
  }
}

class UserChatDetail {
  final int chatSessionId;
  final String endDate;
  final String fullName;
  final String gender;
  final String profileImage;
  final String startDate;
  final String userId;
  final String firebaseID;

  UserChatDetail({
    required this.chatSessionId,
    required this.endDate,
    required this.fullName,
    required this.gender,
    required this.profileImage,
    required this.startDate,
    required this.userId,
    required this.firebaseID,
  });

  factory UserChatDetail.fromJson(Map<String, dynamic> json) {
    return UserChatDetail(
      chatSessionId: json['chatSessionId'] ?? 0,
      endDate: json['endDate'] ?? '',
      fullName: json['fullName'] ?? '',
      gender: json['gender'] ?? '',
      profileImage: json['profileImage'] ?? '',
      startDate: json['startDate'] ?? '',
      userId: json['userId'] ?? '',
      firebaseID: json['firebaseID'] ?? '',
    );
  }
}
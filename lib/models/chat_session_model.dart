// lib/models/chat_session_model.dart
class RequestChat {
  final String astrologerId;
  final int chatSessionId;
  final String userId;

  RequestChat({
    required this.astrologerId,
    required this.chatSessionId,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'astrologerId': astrologerId,
      'chatSessionId': chatSessionId,
      'userId': userId,
    };
  }
}

class ChatModel {
  final String message;
  final ChatSessionRecord record;

  ChatModel({
    required this.message,
    required this.record,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      message: json['message'] ?? '',
      record: ChatSessionRecord.fromJson(json['record'] ?? {}),
    );
  }
}

class ChatSessionRecord {
  final String astrologerId;
  final int chatSessionId;
  final String endDate;
  final String sessionStatus;
  final String startDate;
  final String userId;

  ChatSessionRecord({
    required this.astrologerId,
    required this.chatSessionId,
    required this.endDate,
    required this.sessionStatus,
    required this.startDate,
    required this.userId,
  });

  factory ChatSessionRecord.fromJson(Map<String, dynamic> json) {
    return ChatSessionRecord(
      astrologerId: json['astrologerId']?.toString() ?? '',
      chatSessionId: json['chatSessionId'] ?? 0,
      endDate: json['endDate']?.toString() ?? '',
      sessionStatus: json['sessionStatus']?.toString() ?? '',
      startDate: json['startDate']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
    );
  }
}
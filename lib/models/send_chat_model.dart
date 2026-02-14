// lib/models/send_chat_model.dart
class RequestSendChat {
  final int chatId;
  final int chatSessionId;
  final String senderId;
  final String messageText;
  final String msgType;
  final String sentOn;

  RequestSendChat({
    required this.chatId,
    required this.chatSessionId,
    required this.senderId,
    required this.messageText,
    required this.msgType,
    required this.sentOn,
  });

  Map<String, dynamic> toJson() {
    return {
      'chatId': chatId,
      'chatSessionId': chatSessionId,
      'senderId': senderId,
      'messageText': messageText,
      'msgType': msgType,
      'sentOn': sentOn,
    };
  }
}

class ChatSendModel {
  final String message;
  final ChatSendRecord record;

  ChatSendModel({
    required this.message,
    required this.record,
  });

  factory ChatSendModel.fromJson(Map<String, dynamic> json) {
    return ChatSendModel(
      message: json['message'] ?? '',
      record: ChatSendRecord.fromJson(json['record'] ?? {}),
    );
  }
}

class ChatSendRecord {
  final int chatId;
  final int chatSessionId;
  final String messageText;
  final String msgType;
  final String senderId;
  final String sentOn;

  ChatSendRecord({
    required this.chatId,
    required this.chatSessionId,
    required this.messageText,
    required this.msgType,
    required this.senderId,
    required this.sentOn,
  });

  factory ChatSendRecord.fromJson(Map<String, dynamic> json) {
    return ChatSendRecord(
      chatId: json['chatId'] ?? 0,
      chatSessionId: json['chatSessionId'] ?? 0,
      messageText: json['messageText']?.toString() ?? '',
      msgType: json['msgType']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      sentOn: json['sentOn']?.toString() ?? '',
    );
  }
}
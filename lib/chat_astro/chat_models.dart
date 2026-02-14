/// Chat Model - Response from API
/// Equivalent to Kotlin's ChatModel
class ChatModel {
  final String message;
  final RecordX record;

  ChatModel({
    required this.message,
    required this.record,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      message: json['message'] ?? '',
      record: RecordX.fromJson(json['record'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'record': record.toJson(),
    };
  }

  @override
  String toString() {
    return 'ChatModel(message: $message, record: $record)';
  }
}

/// Record X - Chat Session Record
/// Equivalent to Kotlin's RecordX
class RecordX {
  final String astrologerId;
  final int chatSessionId;
  final String endDate;
  final String sessionStatus;
  final String startDate;
  final String userId;

  RecordX({
    required this.astrologerId,
    required this.chatSessionId,
    required this.endDate,
    required this.sessionStatus,
    required this.startDate,
    required this.userId,
  });

  factory RecordX.fromJson(Map<String, dynamic> json) {
    return RecordX(
      astrologerId: json['astrologerId'] ?? '',
      chatSessionId: json['chatSessionId'] ?? 0,
      endDate: json['endDate'] ?? '',
      sessionStatus: json['sessionStatus'] ?? '',
      startDate: json['startDate'] ?? '',
      userId: json['userId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'astrologerId': astrologerId,
      'chatSessionId': chatSessionId,
      'endDate': endDate,
      'sessionStatus': sessionStatus,
      'startDate': startDate,
      'userId': userId,
    };
  }

  @override
  String toString() {
    return 'RecordX(astrologerId: $astrologerId, chatSessionId: $chatSessionId, '
        'endDate: $endDate, sessionStatus: $sessionStatus, '
        'startDate: $startDate, userId: $userId)';
  }
}

/// Request Chat - Request body for chat session
/// Equivalent to Kotlin's Requestchat
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

  @override
  String toString() {
    return 'RequestChat(astrologerId: $astrologerId, chatSessionId: $chatSessionId, userId: $userId)';
  }
}

/// Request Send Chat - Request body for sending a chat message
/// Equivalent to Kotlin's RequestSendChat
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

  @override
  String toString() {
    return 'RequestSendChat(chatId: $chatId, chatSessionId: $chatSessionId, '
        'senderId: $senderId, messageText: $messageText, msgType: $msgType, sentOn: $sentOn)';
  }
}

/// Chat Send Model - Response from sending a chat message
/// Equivalent to Kotlin's ChatSendModel
class ChatSendModel {
  final String message;
  final RecordXX record;

  ChatSendModel({
    required this.message,
    required this.record,
  });

  factory ChatSendModel.fromJson(Map<String, dynamic> json) {
    return ChatSendModel(
      message: json['message'] ?? '',
      record: RecordXX.fromJson(json['record'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'record': record.toJson(),
    };
  }

  @override
  String toString() {
    return 'ChatSendModel(message: $message, record: $record)';
  }
}

/// Record XX - Chat message record
/// Equivalent to Kotlin's RecordXX
class RecordXX {
  final int chatId;
  final int chatSessionId;
  final String messageText;
  final String msgType;
  final String senderId;
  final String sentOn;

  RecordXX({
    required this.chatId,
    required this.chatSessionId,
    required this.messageText,
    required this.msgType,
    required this.senderId,
    required this.sentOn,
  });

  factory RecordXX.fromJson(Map<String, dynamic> json) {
    return RecordXX(
      chatId: json['chatId'] ?? 0,
      chatSessionId: json['chatSessionId'] ?? 0,
      messageText: json['messageText'] ?? '',
      msgType: json['msgType'] ?? '',
      senderId: json['senderId'] ?? '',
      sentOn: json['sentOn'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chatId': chatId,
      'chatSessionId': chatSessionId,
      'messageText': messageText,
      'msgType': msgType,
      'senderId': senderId,
      'sentOn': sentOn,
    };
  }

  @override
  String toString() {
    return 'RecordXX(chatId: $chatId, chatSessionId: $chatSessionId, '
        'messageText: $messageText, msgType: $msgType, senderId: $senderId, sentOn: $sentOn)';
  }
}
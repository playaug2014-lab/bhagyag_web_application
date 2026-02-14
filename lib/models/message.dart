// lib/models/message.dart
class Message {
  final String? message;
  final String? senderId;
  final String? timestamp;
  final String? url;

  Message({
    this.message,
    this.senderId,
    this.timestamp,
    this.url,
  });

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'senderId': senderId,
      'timestamp': timestamp,
      'url': url,
    };
  }

  factory Message.fromJson(Map<dynamic, dynamic> json) {
    return Message(
      message: json['message']?.toString(),
      senderId: json['senderId']?.toString(),
      timestamp: json['timestamp']?.toString(),
      url: json['url']?.toString(),
    );
  }
}
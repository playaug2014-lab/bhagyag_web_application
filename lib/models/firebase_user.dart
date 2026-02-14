// lib/models/firebase_user.dart
class FirebaseUser {
  final String? name;
  final String? email;
  final String? uid;
  final String? status;
  final String? comswitch;
  final String? videocall;
  final String? voicecall;
  final String? type;
  final String? profileImage;

  FirebaseUser({
    this.name,
    this.email,
    this.uid,
    this.status,
    this.comswitch,
    this.videocall,
    this.voicecall,
    this.type,
    this.profileImage,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'uid': uid,
      'status': status ?? 'offline',
      'comswitch': comswitch ?? 'offline',
      'videocall': videocall ?? 'offline',
      'voicecall': voicecall ?? 'offline',
      'type': type ?? 'disable',
      'profileImage': profileImage ?? '',
    };
  }

  factory FirebaseUser.fromJson(Map<dynamic, dynamic> json) {
    return FirebaseUser(
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      uid: json['uid']?.toString(),
      status: json['status']?.toString(),
      comswitch: json['comswitch']?.toString(),
      videocall: json['videocall']?.toString(),
      voicecall: json['voicecall']?.toString(),
      type: json['type']?.toString(),
      profileImage: json['profileImage']?.toString(),
    );
  }
}
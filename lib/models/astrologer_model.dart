  class AstrologerModel {
    final int chargesPerMinutes;
    final String fullName;
    final String knownLanguages;
    final String profileImage;
    final double rating;
    final String specializedIn;
    final int totalChatMinutes;
    final String userId;
    final String workingSince;
    final String firebaseID;
    final String chatStatus;
    final String status;
    final String aboutMe;
    final String experience;
    final int voiceCallPerMinutes;
    final int videoCallPerMinuters;

    AstrologerModel({
      required this.chargesPerMinutes,
      required this.fullName,
      required this.knownLanguages,
      required this.profileImage,
      required this.rating,
      required this.specializedIn,
      required this.totalChatMinutes,
      required this.userId,
      required this.workingSince,
      required this.firebaseID,
      required this.chatStatus,
      required this.status,
      required this.aboutMe,
      required this.experience,
      required this.voiceCallPerMinutes,
      required this.videoCallPerMinuters,
    });

    factory AstrologerModel.fromJson(Map<String, dynamic> json) {
      return AstrologerModel(
        chargesPerMinutes: json['chargesPerMinutes'] ?? 0,
        fullName: json['fullName'] ?? '',
        knownLanguages: json['knownLanguages'] ?? '',
        profileImage: json['profileImage'] ?? '',
        rating: (json['rating'] ?? 0.0).toDouble(),
        specializedIn: json['specializedIn'] ?? '',
        totalChatMinutes: json['totalChatMinutes'] ?? 0,
        userId: json['userId'] ?? '',
        workingSince: json['workingSince'] ?? '',
        firebaseID: json['firebaseID'] ?? '',
        chatStatus: json['chatStatus'] ?? '',
        status: json['status'] ?? 'offline',
        aboutMe: json['aboutMe'] ?? '',
        experience: json['experience'] ?? '',
        voiceCallPerMinutes: json['voiceCallPerMinutes'] ?? 0,
        videoCallPerMinuters: json['videoCallPerMinuters'] ?? 0,
      );
    }
  }
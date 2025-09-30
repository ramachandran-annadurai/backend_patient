class KickCounterRequestModel{
  final String userId;
  final String userRole;
  final String username;
  final int kickCount;
  final int sessionDuration;
  final String? sessionStartTime;
  final String sessionEndTime;
  final double averageKicksPerMinute;
  final String notes;
  final String timestamp;

  KickCounterRequestModel({
    required this.userId,
    required this.userRole,
    required this.username,
    required this.kickCount,
    required this.sessionDuration,
    required this.sessionStartTime,
    required this.sessionEndTime,
    required this.averageKicksPerMinute,
    required this.notes,
    required this.timestamp,
  });

  factory KickCounterRequestModel.fromJson(Map<String, dynamic> json) {
    return KickCounterRequestModel(
      userId: (json['userId'] ?? '').toString(),
      userRole: (json['userRole'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
      kickCount: json['kickCount'] as int? ?? 0,
      sessionDuration: json['sessionDuration'] as int? ?? 0,
      sessionStartTime: json['sessionStartTime'] as String?,
      sessionEndTime: (json['sessionEndTime'] ?? '').toString(),
      averageKicksPerMinute:
          (json['averageKicksPerMinute'] as num?)?.toDouble() ?? 0.0,
      notes: (json['notes'] ?? '').toString(),
      timestamp: (json['timestamp'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userRole': userRole,
      'username': username,
      'kickCount': kickCount,
      'sessionDuration': sessionDuration,
      'sessionStartTime': sessionStartTime,
      'sessionEndTime': sessionEndTime,
      'averageKicksPerMinute': averageKicksPerMinute,
      'notes': notes,
      'timestamp': timestamp,
    };
  }

  @override
  String toString() {
    return 'KickCounterRequestModel(userId: $userId, userRole: $userRole, username: $username, kickCount: $kickCount, sessionDuration: $sessionDuration, sessionStartTime: $sessionStartTime, sessionEndTime: $sessionEndTime, averageKicksPerMinute: $averageKicksPerMinute, notes: $notes, timestamp: $timestamp)';
  }
}

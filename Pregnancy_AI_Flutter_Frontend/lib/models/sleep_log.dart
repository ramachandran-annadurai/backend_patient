class SleepLogModel {
  final String userId;
  final String userRole;
  final String username;
  final String startTime;
  final String endTime;
  final String totalSleep;
  final bool smartAlarmEnabled;
  final String optimalWakeUpTime;
  final String sleepRating;
  final String? notes;
  final String timestamp;

  SleepLogModel({
    required this.userId,
    required this.userRole,
    required this.username,
    required this.startTime,
    required this.endTime,
    required this.totalSleep,
    required this.smartAlarmEnabled,
    required this.optimalWakeUpTime,
    required this.sleepRating,
    required this.notes,
    required this.timestamp,
  });

  factory SleepLogModel.fromJson(Map<String, dynamic> json) {
    return SleepLogModel(
      userId: (json['userId'] ?? '').toString(),
      userRole: (json['userRole'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
      startTime: (json['startTime'] ?? '').toString(),
      endTime: (json['endTime'] ?? '').toString(),
      totalSleep: (json['totalSleep'] ?? '').toString(),
      smartAlarmEnabled: json['smartAlarmEnabled'] == true ||
          json['smartAlarmEnabled'] == 'true',
      optimalWakeUpTime: (json['optimalWakeUpTime'] ?? '').toString(),
      sleepRating: (json['sleepRating'] ?? '').toString(),
      notes: (json['notes'] ?? '').toString(),
      timestamp: (json['timestamp'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userRole': userRole,
      'username': username,
      'startTime': startTime,
      'endTime': endTime,
      'totalSleep': totalSleep,
      'smartAlarmEnabled': smartAlarmEnabled,
      'optimalWakeUpTime': optimalWakeUpTime,
      'sleepRating': sleepRating,
      'notes': notes ?? '',
      'timestamp': timestamp,
    };
  }
}

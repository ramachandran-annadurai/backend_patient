class FoodEntryModel {
  final String userId;
  final String userRole;
  final String username;
  final String email;
  final String foodDetails;
  final String mealType;
  final int? pregnancyWeek;
  final String? notes;
  final String? transcribedText;
  final Map<String, dynamic> nutritionalBreakdown;
  final Map<String, dynamic>? gpt4Analysis;
  final String timestamp; // ISO-8601 string

  const FoodEntryModel({
    required this.userId,
    required this.userRole,
    required this.username,
    required this.email,
    required this.foodDetails,
    required this.mealType,
    required this.pregnancyWeek,
    required this.timestamp,
    this.notes,
    this.transcribedText,
    this.nutritionalBreakdown = const {},
    this.gpt4Analysis,
  });

  /// Build model from flexible backend JSON keys
  factory FoodEntryModel.fromJson(Map<String, dynamic> json) {
    int? _parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      final asString = value.toString();
      return int.tryParse(asString);
    }

    Map<String, dynamic> _mapOrEmpty(dynamic value) {
      if (value is Map<String, dynamic>) return value;
      if (value is Map) {
        return value.map((key, val) => MapEntry(key.toString(), val));
      }
      return <String, dynamic>{};
    }

    String _string(dynamic value) => (value ?? '').toString();

    return FoodEntryModel(
      userId: _string(json['userId'] ?? json['user_id'] ?? json['patient_id']),
      userRole: _string(json['userRole'] ?? json['user_role'] ?? 'patient'),
      username: _string(json['username'] ?? json['name'] ?? ''),
      email: _string(json['email'] ?? ''),
      foodDetails: _string(json['food_details'] ?? json['food_input'] ?? json['food'] ?? ''),
      mealType: _string(json['meal_type'] ?? json['mealType'] ?? ''),
      pregnancyWeek: _parseInt(json['pregnancy_week'] ?? json['weeks_pregnant'] ?? json['pregnancyWeek']),
      notes: (json['notes'] == null) ? null : _string(json['notes']),
      transcribedText: (json['transcribed_text'] == null) ? null : _string(json['transcribed_text']),
      nutritionalBreakdown: _mapOrEmpty(json['nutritional_breakdown']),
      gpt4Analysis: json['gpt4_analysis'] == null ? null : _mapOrEmpty(json['gpt4_analysis']),
      timestamp: _string(json['timestamp'] ?? json['created_at'] ?? ''),
    );
  }

  /// Convert model to API payload matching existing app/backend expectations
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userRole': userRole,
      'username': username,
      'email': email,
      'food_details': foodDetails,
      'meal_type': mealType,
      'pregnancy_week': pregnancyWeek,
      'notes': notes,
      'transcribed_text': transcribedText,
      'nutritional_breakdown': nutritionalBreakdown,
      'gpt4_analysis': gpt4Analysis,
      'timestamp': timestamp,
    };
  }

  FoodEntryModel copyWith({
    String? userId,
    String? userRole,
    String? username,
    String? email,
    String? foodDetails,
    String? mealType,
    int? pregnancyWeek,
    String? notes,
    String? transcribedText,
    Map<String, dynamic>? nutritionalBreakdown,
    Map<String, dynamic>? gpt4Analysis,
    String? timestamp,
  }) {
    return FoodEntryModel(
      userId: userId ?? this.userId,
      userRole: userRole ?? this.userRole,
      username: username ?? this.username,
      email: email ?? this.email,
      foodDetails: foodDetails ?? this.foodDetails,
      mealType: mealType ?? this.mealType,
      pregnancyWeek: pregnancyWeek ?? this.pregnancyWeek,
      notes: notes ?? this.notes,
      transcribedText: transcribedText ?? this.transcribedText,
      nutritionalBreakdown: nutritionalBreakdown ?? this.nutritionalBreakdown,
      gpt4Analysis: gpt4Analysis ?? this.gpt4Analysis,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'FoodEntryModel(userId: '
        '$userId, userRole: $userRole, username: $username, email: $email, '
        'foodDetails: $foodDetails, mealType: $mealType, pregnancyWeek: $pregnancyWeek, '
        'notes: $notes, transcribedText: $transcribedText, nutritionalBreakdown: $nutritionalBreakdown, '
        'gpt4Analysis: $gpt4Analysis, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FoodEntryModel) return false;
    return other.userId == userId &&
        other.userRole == userRole &&
        other.username == username &&
        other.email == email &&
        other.foodDetails == foodDetails &&
        other.mealType == mealType &&
        other.pregnancyWeek == pregnancyWeek &&
        other.notes == notes &&
        other.transcribedText == transcribedText &&
        _deepEquals(other.nutritionalBreakdown, nutritionalBreakdown) &&
        _deepEquals(other.gpt4Analysis, gpt4Analysis) &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
    userRole.hashCode ^
    username.hashCode ^
    email.hashCode ^
    foodDetails.hashCode ^
    mealType.hashCode ^
    (pregnancyWeek?.hashCode ?? 0) ^
    (notes?.hashCode ?? 0) ^
    (transcribedText?.hashCode ?? 0) ^
    _mapHash(nutritionalBreakdown) ^
    _mapHash(gpt4Analysis) ^
    timestamp.hashCode;
  }

  static bool _deepEquals(Map<String, dynamic>? a, Map<String, dynamic>? b) {
    if (identical(a, b)) return true;
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key)) return false;
      final av = a[key];
      final bv = b[key];
      if (av is Map<String, dynamic> && bv is Map<String, dynamic>) {
        if (!_deepEquals(av, bv)) return false;
      } else if (av != bv) {
        return false;
      }
    }
    return true;
  }

  static int _mapHash(Map<String, dynamic>? map) {
    if (map == null) return 0;
    var result = 0;
    map.forEach((key, value) {
      result = result ^ key.hashCode ^ (value?.hashCode ?? 0);
    });
    return result;
  }
}

// Backward-compatible alias used in screens
class FoodEntry extends FoodEntryModel {
  const FoodEntry({
    required super.userId,
    required super.userRole,
    required super.username,
    required super.email,
    required super.foodDetails,
    required super.mealType,
    required super.pregnancyWeek,
    required super.timestamp,
    super.notes,
    super.transcribedText,
    super.nutritionalBreakdown,
    super.gpt4Analysis,
  });

  factory FoodEntry.fromJson(Map<String, dynamic> json) {
    final base = FoodEntryModel.fromJson(json);
    return FoodEntry(
      userId: base.userId,
      userRole: base.userRole,
      username: base.username,
      email: base.email,
      foodDetails: base.foodDetails,
      mealType: base.mealType,
      pregnancyWeek: base.pregnancyWeek,
      notes: base.notes,
      transcribedText: base.transcribedText,
      nutritionalBreakdown: base.nutritionalBreakdown,
      gpt4Analysis: base.gpt4Analysis,
      timestamp: base.timestamp,
    );
  }
}
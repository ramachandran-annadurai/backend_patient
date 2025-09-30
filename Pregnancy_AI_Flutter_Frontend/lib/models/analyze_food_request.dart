class AnalyzeFoodRequestModel {
  final String foodInput;
  final int pregnancyWeek;
  final String userId;

  AnalyzeFoodRequestModel({
    required this.foodInput,
    required this.pregnancyWeek,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'food_input': foodInput,
      'pregnancy_week': pregnancyWeek,
      'userId': userId,
    };
  }

  factory AnalyzeFoodRequestModel.fromJson(Map<String, dynamic> json) {
    return AnalyzeFoodRequestModel(
      foodInput: json['food_input'] ?? '',
      pregnancyWeek: json['pregnancy_week'] ?? 1,
      userId: json['userId'] ?? '',
    );
  }

  @override
  String toString() {
    return 'AnalyzeFoodRequestModel(foodInput: $foodInput, pregnancyWeek: $pregnancyWeek, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnalyzeFoodRequestModel &&
        other.foodInput == foodInput &&
        other.pregnancyWeek == pregnancyWeek &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return foodInput.hashCode ^ pregnancyWeek.hashCode ^ userId.hashCode;
  }
}

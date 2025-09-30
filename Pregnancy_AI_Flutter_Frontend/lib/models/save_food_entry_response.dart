import '../services/core/network_request.dart';

class SaveFoodEntryResponseModel extends NetworkResponse {
  final bool success;
  final String message;
  final int totalEntries;
  final FoodEntryData foodEntry;

  SaveFoodEntryResponseModel({
    required this.success,
    required this.message,
    required this.totalEntries,
    required this.foodEntry,
  }) : super.fromJson({});

  @override
  factory SaveFoodEntryResponseModel.fromJson(Map<String, dynamic> json) {
    return SaveFoodEntryResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      totalEntries: json['total_entries'] ?? 0,
      foodEntry: FoodEntryData.fromJson(json['food_entry'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'total_entries': totalEntries,
      'food_entry': foodEntry.toJson(),
    };
  }

  @override
  String toString() {
    return 'SaveFoodEntryResponseModel(success: $success, message: $message, totalEntries: $totalEntries, foodEntry: $foodEntry)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SaveFoodEntryResponseModel &&
        other.success == success &&
        other.message == message &&
        other.totalEntries == totalEntries &&
        other.foodEntry == foodEntry;
  }

  @override
  int get hashCode {
    return success.hashCode ^
        message.hashCode ^
        totalEntries.hashCode ^
        foodEntry.hashCode;
  }
}

class FoodEntryData {
  final String createdAt;
  final String foodDetails;
  final String foodInput;
  final Gpt4Analysis gpt4Analysis;
  final String mealType;
  final String? notes;
  final NutritionalBreakdown nutritionalBreakdown;
  final int pregnancyWeek;
  final String timestamp;
  final String? transcribedText;
  final String type;

  FoodEntryData({
    required this.createdAt,
    required this.foodDetails,
    required this.foodInput,
    required this.gpt4Analysis,
    required this.mealType,
    this.notes,
    required this.nutritionalBreakdown,
    required this.pregnancyWeek,
    required this.timestamp,
    this.transcribedText,
    required this.type,
  });

  factory FoodEntryData.fromJson(Map<String, dynamic> json) {
    return FoodEntryData(
      createdAt: json['created_at'] ?? '',
      foodDetails: json['food_details'] ?? '',
      foodInput: json['food_input'] ?? '',
      gpt4Analysis: Gpt4Analysis.fromJson(json['gpt4_analysis'] ?? {}),
      mealType: json['meal_type'] ?? '',
      notes: json['notes'],
      nutritionalBreakdown:
          NutritionalBreakdown.fromJson(json['nutritional_breakdown'] ?? {}),
      pregnancyWeek: json['pregnancy_week'] ?? 0,
      timestamp: json['timestamp'] ?? '',
      transcribedText: json['transcribed_text'],
      type: json['type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt,
      'food_details': foodDetails,
      'food_input': foodInput,
      'gpt4_analysis': gpt4Analysis.toJson(),
      'meal_type': mealType,
      'notes': notes,
      'nutritional_breakdown': nutritionalBreakdown.toJson(),
      'pregnancy_week': pregnancyWeek,
      'timestamp': timestamp,
      'transcribed_text': transcribedText,
      'type': type,
    };
  }

  @override
  String toString() {
    return 'FoodEntryData(createdAt: $createdAt, foodDetails: $foodDetails, foodInput: $foodInput, gpt4Analysis: $gpt4Analysis, mealType: $mealType, notes: $notes, nutritionalBreakdown: $nutritionalBreakdown, pregnancyWeek: $pregnancyWeek, timestamp: $timestamp, transcribedText: $transcribedText, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FoodEntryData &&
        other.createdAt == createdAt &&
        other.foodDetails == foodDetails &&
        other.foodInput == foodInput &&
        other.gpt4Analysis == gpt4Analysis &&
        other.mealType == mealType &&
        other.notes == notes &&
        other.nutritionalBreakdown == nutritionalBreakdown &&
        other.pregnancyWeek == pregnancyWeek &&
        other.timestamp == timestamp &&
        other.transcribedText == transcribedText &&
        other.type == type;
  }

  @override
  int get hashCode {
    return createdAt.hashCode ^
        foodDetails.hashCode ^
        foodInput.hashCode ^
        gpt4Analysis.hashCode ^
        mealType.hashCode ^
        notes.hashCode ^
        nutritionalBreakdown.hashCode ^
        pregnancyWeek.hashCode ^
        timestamp.hashCode ^
        transcribedText.hashCode ^
        type.hashCode;
  }
}

class Gpt4Analysis {
  final String suggestions;
  final String summary;

  Gpt4Analysis({
    required this.suggestions,
    required this.summary,
  });

  factory Gpt4Analysis.fromJson(Map<String, dynamic> json) {
    return Gpt4Analysis(
      suggestions: json['suggestions'] ?? '',
      summary: json['summary'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'suggestions': suggestions,
      'summary': summary,
    };
  }

  @override
  String toString() {
    return 'Gpt4Analysis(suggestions: $suggestions, summary: $summary)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Gpt4Analysis &&
        other.suggestions == suggestions &&
        other.summary == summary;
  }

  @override
  int get hashCode {
    return suggestions.hashCode ^ summary.hashCode;
  }
}

class NutritionalBreakdown {
  final double calciumMg;
  final double calories;
  final double carbsG;
  final double fatG;
  final double proteinG;

  NutritionalBreakdown({
    required this.calciumMg,
    required this.calories,
    required this.carbsG,
    required this.fatG,
    required this.proteinG,
  });

  factory NutritionalBreakdown.fromJson(Map<String, dynamic> json) {
    return NutritionalBreakdown(
      calciumMg: (json['calcium_mg'] ?? 0).toDouble(),
      calories: (json['calories'] ?? 0).toDouble(),
      carbsG: (json['carbs_g'] ?? 0).toDouble(),
      fatG: (json['fat_g'] ?? 0).toDouble(),
      proteinG: (json['protein_g'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calcium_mg': calciumMg,
      'calories': calories,
      'carbs_g': carbsG,
      'fat_g': fatG,
      'protein_g': proteinG,
    };
  }

  @override
  String toString() {
    return 'NutritionalBreakdown(calciumMg: $calciumMg, calories: $calories, carbsG: $carbsG, fatG: $fatG, proteinG: $proteinG)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NutritionalBreakdown &&
        other.calciumMg == calciumMg &&
        other.calories == calories &&
        other.carbsG == carbsG &&
        other.fatG == fatG &&
        other.proteinG == proteinG;
  }

  @override
  int get hashCode {
    return calciumMg.hashCode ^
        calories.hashCode ^
        carbsG.hashCode ^
        fatG.hashCode ^
        proteinG.hashCode;
  }
}

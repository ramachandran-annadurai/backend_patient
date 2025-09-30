import '../services/core/network_request.dart';

class AnalyzeFoodResponseModel extends NetworkResponse {
  final bool success;
  final bool fallbackUsed;
  final String foodInput;
  final int pregnancyWeek;
  final String timestamp;
  final AnalysisData analysis;

  AnalyzeFoodResponseModel({
    required this.success,
    required this.fallbackUsed,
    required this.foodInput,
    required this.pregnancyWeek,
    required this.timestamp,
    required this.analysis,
  }) : super.fromJson({});

  @override
  factory AnalyzeFoodResponseModel.fromJson(Map<String, dynamic> json) {
    return AnalyzeFoodResponseModel(
      success: json['success'] ?? false,
      fallbackUsed: json['fallback_used'] ?? false,
      foodInput: json['food_input'] ?? '',
      pregnancyWeek:
          int.tryParse(json['pregnancy_week']?.toString() ?? '1') ?? 1,
      timestamp: json['timestamp'] ?? '',
      analysis: AnalysisData.fromJson(json['analysis'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'fallback_used': fallbackUsed,
      'food_input': foodInput,
      'pregnancy_week': pregnancyWeek,
      'timestamp': timestamp,
      'analysis': analysis.toJson(),
    };
  }

  @override
  String toString() {
    return 'AnalyzeFoodResponseModel(success: $success, fallbackUsed: $fallbackUsed, foodInput: $foodInput, pregnancyWeek: $pregnancyWeek, timestamp: $timestamp, analysis: $analysis)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnalyzeFoodResponseModel &&
        other.success == success &&
        other.fallbackUsed == fallbackUsed &&
        other.foodInput == foodInput &&
        other.pregnancyWeek == pregnancyWeek &&
        other.timestamp == timestamp &&
        other.analysis == analysis;
  }

  @override
  int get hashCode {
    return success.hashCode ^
        fallbackUsed.hashCode ^
        foodInput.hashCode ^
        pregnancyWeek.hashCode ^
        timestamp.hashCode ^
        analysis.hashCode;
  }
}

class AnalysisData {
  final String note;
  final NutritionalBreakdown nutritionalBreakdown;
  final PregnancyBenefits pregnancyBenefits;
  final SafetyConsiderations safetyConsiderations;
  final SmartRecommendations smartRecommendations;

  AnalysisData({
    required this.note,
    required this.nutritionalBreakdown,
    required this.pregnancyBenefits,
    required this.safetyConsiderations,
    required this.smartRecommendations,
  });

  factory AnalysisData.fromJson(Map<String, dynamic> json) {
    return AnalysisData(
      note: json['note'] ?? '',
      nutritionalBreakdown:
          NutritionalBreakdown.fromJson(json['nutritional_breakdown'] ?? {}),
      pregnancyBenefits:
          PregnancyBenefits.fromJson(json['pregnancy_benefits'] ?? {}),
      safetyConsiderations:
          SafetyConsiderations.fromJson(json['safety_considerations'] ?? {}),
      smartRecommendations:
          SmartRecommendations.fromJson(json['smart_recommendations'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'note': note,
      'nutritional_breakdown': nutritionalBreakdown.toJson(),
      'pregnancy_benefits': pregnancyBenefits.toJson(),
      'safety_considerations': safetyConsiderations.toJson(),
      'smart_recommendations': smartRecommendations.toJson(),
    };
  }

  @override
  String toString() {
    return 'AnalysisData(note: $note, nutritionalBreakdown: $nutritionalBreakdown, pregnancyBenefits: $pregnancyBenefits, safetyConsiderations: $safetyConsiderations, smartRecommendations: $smartRecommendations)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnalysisData &&
        other.note == note &&
        other.nutritionalBreakdown == nutritionalBreakdown &&
        other.pregnancyBenefits == pregnancyBenefits &&
        other.safetyConsiderations == safetyConsiderations &&
        other.smartRecommendations == smartRecommendations;
  }

  @override
  int get hashCode {
    return note.hashCode ^
        nutritionalBreakdown.hashCode ^
        pregnancyBenefits.hashCode ^
        safetyConsiderations.hashCode ^
        smartRecommendations.hashCode;
  }
}

class NutritionalBreakdown {
  final double carbohydratesGrams;
  final double estimatedCalories;
  final double fatGrams;
  final double fiberGrams;
  final double proteinGrams;

  NutritionalBreakdown({
    required this.carbohydratesGrams,
    required this.estimatedCalories,
    required this.fatGrams,
    required this.fiberGrams,
    required this.proteinGrams,
  });

  factory NutritionalBreakdown.fromJson(Map<String, dynamic> json) {
    return NutritionalBreakdown(
      carbohydratesGrams: (json['carbohydrates_grams'] ?? 0).toDouble(),
      estimatedCalories: (json['estimated_calories'] ?? 0).toDouble(),
      fatGrams: (json['fat_grams'] ?? 0).toDouble(),
      fiberGrams: (json['fiber_grams'] ?? 0).toDouble(),
      proteinGrams: (json['protein_grams'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'carbohydrates_grams': carbohydratesGrams,
      'estimated_calories': estimatedCalories,
      'fat_grams': fatGrams,
      'fiber_grams': fiberGrams,
      'protein_grams': proteinGrams,
    };
  }

  @override
  String toString() {
    return 'NutritionalBreakdown(carbohydratesGrams: $carbohydratesGrams, estimatedCalories: $estimatedCalories, fatGrams: $fatGrams, fiberGrams: $fiberGrams, proteinGrams: $proteinGrams)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NutritionalBreakdown &&
        other.carbohydratesGrams == carbohydratesGrams &&
        other.estimatedCalories == estimatedCalories &&
        other.fatGrams == fatGrams &&
        other.fiberGrams == fiberGrams &&
        other.proteinGrams == proteinGrams;
  }

  @override
  int get hashCode {
    return carbohydratesGrams.hashCode ^
        estimatedCalories.hashCode ^
        fatGrams.hashCode ^
        fiberGrams.hashCode ^
        proteinGrams.hashCode;
  }
}

class PregnancyBenefits {
  final List<String> benefitsForMother;
  final List<String> nutrientsForFetalDevelopment;
  final String weekSpecificAdvice;

  PregnancyBenefits({
    required this.benefitsForMother,
    required this.nutrientsForFetalDevelopment,
    required this.weekSpecificAdvice,
  });

  factory PregnancyBenefits.fromJson(Map<String, dynamic> json) {
    return PregnancyBenefits(
      benefitsForMother: List<String>.from(json['benefits_for_mother'] ?? []),
      nutrientsForFetalDevelopment:
          List<String>.from(json['nutrients_for_fetal_development'] ?? []),
      weekSpecificAdvice: json['week_specific_advice'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'benefits_for_mother': benefitsForMother,
      'nutrients_for_fetal_development': nutrientsForFetalDevelopment,
      'week_specific_advice': weekSpecificAdvice,
    };
  }

  @override
  String toString() {
    return 'PregnancyBenefits(benefitsForMother: $benefitsForMother, nutrientsForFetalDevelopment: $nutrientsForFetalDevelopment, weekSpecificAdvice: $weekSpecificAdvice)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PregnancyBenefits &&
        other.benefitsForMother == benefitsForMother &&
        other.nutrientsForFetalDevelopment == nutrientsForFetalDevelopment &&
        other.weekSpecificAdvice == weekSpecificAdvice;
  }

  @override
  int get hashCode {
    return benefitsForMother.hashCode ^
        nutrientsForFetalDevelopment.hashCode ^
        weekSpecificAdvice.hashCode;
  }
}

class SafetyConsiderations {
  final List<String> cookingRecommendations;
  final List<String> foodSafetyTips;

  SafetyConsiderations({
    required this.cookingRecommendations,
    required this.foodSafetyTips,
  });

  factory SafetyConsiderations.fromJson(Map<String, dynamic> json) {
    return SafetyConsiderations(
      cookingRecommendations:
          List<String>.from(json['cooking_recommendations'] ?? []),
      foodSafetyTips: List<String>.from(json['food_safety_tips'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cooking_recommendations': cookingRecommendations,
      'food_safety_tips': foodSafetyTips,
    };
  }

  @override
  String toString() {
    return 'SafetyConsiderations(cookingRecommendations: $cookingRecommendations, foodSafetyTips: $foodSafetyTips)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SafetyConsiderations &&
        other.cookingRecommendations == cookingRecommendations &&
        other.foodSafetyTips == foodSafetyTips;
  }

  @override
  int get hashCode {
    return cookingRecommendations.hashCode ^ foodSafetyTips.hashCode;
  }
}

class SmartRecommendations {
  final String hydrationTips;
  final List<String> nextMealSuggestions;

  SmartRecommendations({
    required this.hydrationTips,
    required this.nextMealSuggestions,
  });

  factory SmartRecommendations.fromJson(Map<String, dynamic> json) {
    return SmartRecommendations(
      hydrationTips: json['hydration_tips'] ?? '',
      nextMealSuggestions:
          List<String>.from(json['next_meal_suggestions'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hydration_tips': hydrationTips,
      'next_meal_suggestions': nextMealSuggestions,
    };
  }

  @override
  String toString() {
    return 'SmartRecommendations(hydrationTips: $hydrationTips, nextMealSuggestions: $nextMealSuggestions)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SmartRecommendations &&
        other.hydrationTips == hydrationTips &&
        other.nextMealSuggestions == nextMealSuggestions;
  }

  @override
  int get hashCode {
    return hydrationTips.hashCode ^ nextMealSuggestions.hashCode;
  }
}

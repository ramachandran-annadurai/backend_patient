class Gpt4AnalysisEntryModel {
  final String id;
  final String userId;
  final String input;
  final String output;
  final String timestamp;

  Gpt4AnalysisEntryModel({
    required this.id,
    required this.userId,
    required this.input,
    required this.output,
    required this.timestamp,
  });

  factory Gpt4AnalysisEntryModel.fromJson(Map<String, dynamic> json) => Gpt4AnalysisEntryModel(
        id: (json['id'] ?? json['_id'] ?? '').toString(),
        userId: (json['user_id'] ?? json['userId'] ?? '').toString(),
        input: (json['food_input'] ?? json['input'] ?? '').toString(),
        output: (json['analysis'] ?? json['output'] ?? '').toString(),
        timestamp: (json['timestamp'] ?? '').toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'food_input': input,
        'analysis': output,
        'timestamp': timestamp,
      };
}



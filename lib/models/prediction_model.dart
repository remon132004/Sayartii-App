class PredictionModel {
  final String? prediction; // "Normal" or "Problem Detected"
  final String? troubleCode; // e.g., "C0300"
  final double? estimatedTimeRemaining; // e.g., 7.27
  final String? openAiResponse; // Detailed descriptive text from GPT-4o

  PredictionModel({
    this.prediction,
    this.troubleCode,
    this.estimatedTimeRemaining,
    this.openAiResponse,
  });

  factory PredictionModel.fromJson(Map<String, dynamic> json) {
    // Parse the keys flexibly to handle slight variations from the Flask Backend.
    return PredictionModel(
      prediction: json['prediction']?.toString(),
      troubleCode: json['trouble_code']?.toString() ?? json['troubleCode']?.toString(),
      estimatedTimeRemaining: (json['estimated_time_remaining'] as num?)?.toDouble() 
                           ?? (json['estimatedTimeRemaining'] as num?)?.toDouble()
                           ?? (json['estimated_hours'] as num?)?.toDouble(),
      openAiResponse: json['openai_response']?.toString() ?? json['openAiResponse']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prediction': prediction,
      'trouble_code': troubleCode,
      'estimated_time_remaining': estimatedTimeRemaining,
      'openai_response': openAiResponse,
    };
  }

  @override
  String toString() {
    return 'PredictionModel{\n'
        '  prediction: $prediction,\n'
        '  troubleCode: $troubleCode,\n'
        '  estimatedTimeRemaining: $estimatedTimeRemaining,\n'
        '  openAiResponse: $openAiResponse,\n'
        '}';
  }
}

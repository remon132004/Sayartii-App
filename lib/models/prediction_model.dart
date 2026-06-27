class PredictionModel {
  final String? prediction;              // "Normal" or "Problem Detected"
  final double? confidence;             // 0.0 – 1.0 probability of the predicted class
  final String? troubleCode;            // e.g., "C0300"
  final double? estimatedTimeRemaining; // estimated hours until failure
  final dynamic openAiResponse;         // Detailed JSON report from GPT / fallback dict

  PredictionModel({
    this.prediction,
    this.confidence,
    this.troubleCode,
    this.estimatedTimeRemaining,
    this.openAiResponse,
  });

  factory PredictionModel.fromJson(Map<String, dynamic> json) {
    return PredictionModel(
      prediction: json['prediction']?.toString(),
      confidence: (json['confidence'] as num?)?.toDouble(),
      troubleCode: json['trouble_code']?.toString() ?? json['troubleCode']?.toString(),
      estimatedTimeRemaining: (json['estimated_time_remaining'] as num?)?.toDouble()
                           ?? (json['estimatedTimeRemaining'] as num?)?.toDouble()
                           ?? (json['estimated_hours'] as num?)?.toDouble(),
      openAiResponse: json['openai_response'] ?? json['openAiResponse'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prediction': prediction,
      'confidence': confidence,
      'trouble_code': troubleCode,
      'estimated_time_remaining': estimatedTimeRemaining,
      'openai_response': openAiResponse,
    };
  }

  /// Confidence as a formatted percentage string, e.g. "87%"
  String get confidencePercent =>
      confidence != null ? '${(confidence! * 100).round()}%' : '';

  @override
  String toString() {
    return 'PredictionModel{\n'
        '  prediction: $prediction,\n'
        '  confidence: $confidencePercent,\n'
        '  troubleCode: $troubleCode,\n'
        '  estimatedTimeRemaining: $estimatedTimeRemaining,\n'
        '  openAiResponse: $openAiResponse,\n'
        '}';
  }
}

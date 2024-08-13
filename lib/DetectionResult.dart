import 'dart:convert';

class DetectionResult {
  final double xmin;
  final double ymin;
  final double xmax;
  final double ymax;
  final double confidence;
  final String name;

  DetectionResult({
    required this.xmin,
    required this.ymin,
    required this.xmax,
    required this.ymax,
    required this.confidence,
    required this.name,
  });

  factory DetectionResult.fromJson(Map<String, dynamic> json) {
    return DetectionResult(
      xmin: json['xmin'],
      ymin: json['ymin'],
      xmax: json['xmax'],
      ymax: json['ymax'],
      confidence: json['confidence'],
      name: json['name'],
    );
  }
}

List<DetectionResult> parseResults(String responseBody) {
  final parsed = jsonDecode(responseBody)['results'] as List;
  return parsed.map<DetectionResult>((json) => DetectionResult.fromJson(json)).toList();
}
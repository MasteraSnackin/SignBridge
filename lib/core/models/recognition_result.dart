import 'enums.dart';

class RecognitionResult {
  final String letter;
  final double confidence;
  final DateTime timestamp;
  final ProcessingSource source;
  final int latencyMs;
  
  RecognitionResult({
    required this.letter,
    required this.confidence,
    required this.timestamp,
    this.source = ProcessingSource.local,
    this.latencyMs = 0,
  });
  
  factory RecognitionResult.unknown() {
    return RecognitionResult(
      letter: '',
      confidence: 0.0,
      timestamp: DateTime.now(),
    );
  }
  
  bool get isValid => letter.isNotEmpty && confidence > 0.75;
  
  Map<String, dynamic> toJson() => {
    'letter': letter,
    'confidence': confidence,
    'timestamp': timestamp.toIso8601String(),
    'source': source.toString(),
    'latencyMs': latencyMs,
  };
  
  factory RecognitionResult.fromJson(Map<String, dynamic> json) {
    return RecognitionResult(
      letter: json['letter'] as String,
      confidence: json['confidence'] as double,
      timestamp: DateTime.parse(json['timestamp'] as String),
      source: ProcessingSource.values.firstWhere(
        (e) => e.toString() == json['source'],
        orElse: () => ProcessingSource.local,
      ),
      latencyMs: json['latencyMs'] as int? ?? 0,
    );
  }
  
  @override
  String toString() => 'RecognitionResult($letter, ${(confidence * 100).toStringAsFixed(1)}%)';
}
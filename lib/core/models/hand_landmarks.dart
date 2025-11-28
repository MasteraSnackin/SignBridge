import 'point_3d.dart';

class HandLandmarks {
  final List<Point3D> points; // 21 landmarks
  final double confidence;
  final DateTime timestamp;
  
  HandLandmarks({
    required this.points,
    this.confidence = 1.0,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now(),
       assert(points.length == 21, 'Must have exactly 21 landmarks');
  
  /// Convert to 63-dimensional vector (21 points × 3 coordinates)
  List<double> toVector() {
    return points.expand((p) => [p.x, p.y, p.z]).toList();
  }
  
  /// Normalize landmarks relative to wrist (point 0)
  HandLandmarks normalize() {
    if (points.isEmpty) return this;
    
    final wrist = points[0];
    final normalizedPoints = points.map((p) => p - wrist).toList();
    
    // Calculate scale factor (distance from wrist to middle finger base)
    final scale = normalizedPoints[9].distanceTo(const Point3D(0, 0, 0));
    
    // Normalize by scale
    final scaledPoints = scale > 0
        ? normalizedPoints.map((p) => p * (1.0 / scale)).toList()
        : normalizedPoints;
    
    return HandLandmarks(
      points: scaledPoints,
      confidence: confidence,
      timestamp: timestamp,
    );
  }
  
  /// Calculate bounding box
  Map<String, double> getBoundingBox() {
    if (points.isEmpty) {
      return {'minX': 0, 'minY': 0, 'maxX': 0, 'maxY': 0, 'width': 0, 'height': 0};
    }
    
    double minX = points[0].x;
    double minY = points[0].y;
    double maxX = points[0].x;
    double maxY = points[0].y;
    
    for (final point in points) {
      if (point.x < minX) minX = point.x;
      if (point.y < minY) minY = point.y;
      if (point.x > maxX) maxX = point.x;
      if (point.y > maxY) maxY = point.y;
    }
    
    return {
      'minX': minX,
      'minY': minY,
      'maxX': maxX,
      'maxY': maxY,
      'width': maxX - minX,
      'height': maxY - minY,
    };
  }
  
  Map<String, dynamic> toJson() => {
    'points': points.map((p) => p.toJson()).toList(),
    'confidence': confidence,
    'timestamp': timestamp.toIso8601String(),
  };
  
  factory HandLandmarks.fromJson(Map<String, dynamic> json) {
    return HandLandmarks(
      points: (json['points'] as List)
          .map((p) => Point3D.fromJson(p as Map<String, dynamic>))
          .toList(),
      confidence: json['confidence'] as double,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
  
  @override
  String toString() => 'HandLandmarks(${points.length} points, confidence: ${(confidence * 100).toStringAsFixed(1)}%)';
}
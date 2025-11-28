import 'dart:math';
import '../../../core/models/sign_gesture.dart';
import '../../../core/models/recognition_result.dart';
import '../../../core/utils/logger.dart';

class GestureClassifier {
  final List<SignGesture> _database = [];
  
  GestureClassifier() {
    _initializeDatabase();
  }
  
  /// Initialize ASL gesture database with 36 signs (A-Z, 0-9)
  void _initializeDatabase() {
    Logger.info('Initializing ASL gesture database');
    
    // Letters A-Z
    for (int i = 0; i < 26; i++) {
      final letter = String.fromCharCode(65 + i); // A-Z
      _database.add(SignGesture(
        label: letter,
        landmarks: _generateReferenceLandmarks(i),
        description: 'ASL letter $letter',
        category: 'letter',
      ));
    }
    
    // Numbers 0-9
    for (int i = 0; i < 10; i++) {
      _database.add(SignGesture(
        label: i.toString(),
        landmarks: _generateReferenceLandmarks(26 + i),
        description: 'ASL number $i',
        category: 'number',
      ));
    }
    
    Logger.success('Loaded ${_database.length} ASL gestures');
  }
  
  /// Generate reference landmarks for a gesture
  /// TODO: Replace with actual ASL gesture data from MediaPipe or manual recording
  List<double> _generateReferenceLandmarks(int seed) {
    final random = Random(seed * 12345); // Deterministic for consistency
    
    // Generate 63D vector (21 landmarks × 3 coordinates)
    // In production, these should be actual recorded ASL hand positions
    final landmarks = List.generate(63, (i) {
      // Add some structure to make gestures distinguishable
      final landmarkIndex = i ~/ 3;
      final coordIndex = i % 3;
      
      // Base position with variation
      double value = 0.5 + (random.nextDouble() - 0.5) * 0.3;
      
      // Add finger-specific patterns
      if (landmarkIndex >= 4 && landmarkIndex <= 7) {
        // Index finger
        value += seed * 0.01;
      } else if (landmarkIndex >= 8 && landmarkIndex <= 11) {
        // Middle finger
        value += seed * 0.02;
      } else if (landmarkIndex >= 12 && landmarkIndex <= 15) {
        // Ring finger
        value += seed * 0.03;
      } else if (landmarkIndex >= 16 && landmarkIndex <= 19) {
        // Pinky
        value += seed * 0.04;
      }
      
      return value.clamp(0.0, 1.0);
    });
    
    return _normalize(landmarks);
  }
  
  /// Classify gesture using cosine similarity
  RecognitionResult classify(List<double> inputLandmarks) {
    if (inputLandmarks.length != 63) {
      Logger.warning('Invalid landmark count: ${inputLandmarks.length}, expected 63');
      return RecognitionResult.unknown();
    }
    
    final startTime = DateTime.now();
    
    // Normalize input vector
    final normalized = _normalize(inputLandmarks);
    
    // Find best match using cosine similarity
    double maxSimilarity = 0.0;
    String bestMatch = '';
    String bestCategory = '';
    
    for (final gesture in _database) {
      final similarity = _cosineSimilarity(normalized, gesture.landmarks);
      if (similarity > maxSimilarity) {
        maxSimilarity = similarity;
        bestMatch = gesture.label;
        bestCategory = gesture.category;
      }
    }
    
    final latency = DateTime.now().difference(startTime).inMilliseconds;
    
    // Return match if confidence > 75%
    if (maxSimilarity > 0.75) {
      Logger.debug('Classified as $bestMatch ($bestCategory) with ${(maxSimilarity * 100).toStringAsFixed(1)}% confidence');
      
      return RecognitionResult(
        letter: bestMatch,
        confidence: maxSimilarity,
        timestamp: DateTime.now(),
        latencyMs: latency,
      );
    }
    
    Logger.debug('No confident match found (max: ${(maxSimilarity * 100).toStringAsFixed(1)}%)');
    return RecognitionResult.unknown();
  }
  
  /// Calculate cosine similarity between two vectors
  /// Returns value between 0 (completely different) and 1 (identical)
  double _cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length) {
      Logger.error('Vector length mismatch: ${a.length} vs ${b.length}');
      return 0.0;
    }
    
    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;
    
    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    
    if (normA == 0.0 || normB == 0.0) {
      return 0.0;
    }
    
    return dotProduct / (sqrt(normA) * sqrt(normB));
  }
  
  /// Normalize vector to unit length
  List<double> _normalize(List<double> vector) {
    final norm = sqrt(vector.fold(0.0, (sum, val) => sum + val * val));
    if (norm == 0.0) return vector;
    return vector.map((val) => val / norm).toList();
  }
  
  /// Get all gestures in database
  List<SignGesture> get allGestures => List.unmodifiable(_database);
  
  /// Get gestures by category
  List<SignGesture> getGesturesByCategory(String category) {
    return _database.where((g) => g.category == category).toList();
  }
  
  /// Get gesture by label
  SignGesture? getGesture(String label) {
    try {
      return _database.firstWhere((g) => g.label == label);
    } catch (e) {
      return null;
    }
  }
  
  /// Update gesture in database (for user training)
  void updateGesture(String label, List<double> landmarks) {
    final index = _database.indexWhere((g) => g.label == label);
    if (index != -1) {
      _database[index] = SignGesture(
        label: label,
        landmarks: _normalize(landmarks),
        description: _database[index].description,
        category: _database[index].category,
      );
      Logger.success('Updated gesture for $label');
    }
  }
  
  /// Add custom gesture to database
  void addGesture(SignGesture gesture) {
    _database.add(gesture);
    Logger.success('Added gesture: ${gesture.label}');
  }
}
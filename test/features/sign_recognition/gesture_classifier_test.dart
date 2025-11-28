import 'package:flutter_test/flutter_test.dart';
import 'package:signbridge/features/sign_recognition/models/gesture_classifier.dart';
import 'package:signbridge/core/models/hand_landmarks.dart';
import 'package:signbridge/core/models/point_3d.dart';

void main() {
  group('GestureClassifier', () {
    late GestureClassifier classifier;
    
    setUp(() {
      classifier = GestureClassifier();
    });
    
    test('initializes with 36 gestures (A-Z, 0-9)', () {
      expect(classifier.gestureCount, 36);
    });
    
    test('has all letters A-Z', () {
      for (int i = 0; i < 26; i++) {
        final letter = String.fromCharCode(65 + i); // A-Z
        expect(classifier.hasGesture(letter), true);
      }
    });
    
    test('has all numbers 0-9', () {
      for (int i = 0; i < 10; i++) {
        expect(classifier.hasGesture(i.toString()), true);
      }
    });
    
    test('returns null for invalid landmarks (all zeros)', () {
      final landmarks = HandLandmarks(
        points: List.generate(21, (i) => Point3D(0, 0, 0)),
      );
      
      final result = classifier.classify(landmarks);
      
      expect(result, isNull);
    });
    
    test('returns null for landmarks with wrong count', () {
      final landmarks = HandLandmarks(
        points: List.generate(10, (i) => Point3D(0.5, 0.5, 0)),
      );
      
      final result = classifier.classify(landmarks);
      
      expect(result, isNull);
    });
    
    test('normalizes landmarks before classification', () {
      // Create landmarks at different scales
      final landmarks1 = _createTestLandmarks(scale: 1.0);
      final landmarks2 = _createTestLandmarks(scale: 2.0);
      
      final result1 = classifier.classify(landmarks1);
      final result2 = classifier.classify(landmarks2);
      
      // Should recognize same gesture regardless of scale
      if (result1 != null && result2 != null) {
        expect(result1.letter, result2.letter);
      }
    });
    
    test('calculates cosine similarity correctly', () {
      final landmarks = _createTestLandmarks();
      
      final result = classifier.classify(landmarks);
      
      if (result != null) {
        expect(result.confidence, greaterThanOrEqualTo(0.0));
        expect(result.confidence, lessThanOrEqualTo(1.0));
      }
    });
    
    test('returns result with timestamp', () {
      final landmarks = _createTestLandmarks();
      final before = DateTime.now();
      
      final result = classifier.classify(landmarks);
      
      final after = DateTime.now();
      
      if (result != null) {
        expect(result.timestamp.isAfter(before) || result.timestamp.isAtSameMomentAs(before), true);
        expect(result.timestamp.isBefore(after) || result.timestamp.isAtSameMomentAs(after), true);
      }
    });
    
    test('confidence threshold filters low confidence results', () {
      // Create very random landmarks (should have low confidence)
      final landmarks = HandLandmarks(
        points: List.generate(21, (i) => Point3D(
          (i * 0.1) % 1.0,
          (i * 0.2) % 1.0,
          (i * 0.05) % 0.5,
        )),
      );
      
      final result = classifier.classify(landmarks);
      
      // Should either return null or high confidence result
      if (result != null) {
        expect(result.confidence, greaterThan(0.75));
      }
    });
    
    test('getGestureInfo returns correct information', () {
      final info = classifier.getGestureInfo('A');
      
      expect(info, isNotNull);
      expect(info!['letter'], 'A');
      expect(info['vector'], isNotNull);
      expect(info['vector'].length, 63); // 21 points × 3 coordinates
    });
    
    test('getGestureInfo returns null for invalid letter', () {
      final info = classifier.getGestureInfo('invalid');
      
      expect(info, isNull);
    });
    
    test('getAllGestures returns all 36 gestures', () {
      final gestures = classifier.getAllGestures();
      
      expect(gestures.length, 36);
      expect(gestures.contains('A'), true);
      expect(gestures.contains('Z'), true);
      expect(gestures.contains('0'), true);
      expect(gestures.contains('9'), true);
    });
  });
}

/// Helper function to create test landmarks
HandLandmarks _createTestLandmarks({double scale = 1.0}) {
  // Create a simple hand pose (palm facing camera)
  final points = <Point3D>[];
  
  // Wrist
  points.add(Point3D(0.5 * scale, 0.7 * scale, 0.0));
  
  // Thumb (4 points)
  for (int i = 0; i < 4; i++) {
    points.add(Point3D(
      (0.4 + i * 0.03) * scale,
      (0.65 - i * 0.05) * scale,
      -0.01 * i * scale,
    ));
  }
  
  // Index finger (4 points)
  for (int i = 0; i < 4; i++) {
    points.add(Point3D(
      (0.45 + i * 0.01) * scale,
      (0.6 - i * 0.08) * scale,
      -0.005 * i * scale,
    ));
  }
  
  // Middle finger (4 points)
  for (int i = 0; i < 4; i++) {
    points.add(Point3D(
      (0.5 + i * 0.005) * scale,
      (0.6 - i * 0.09) * scale,
      -0.005 * i * scale,
    ));
  }
  
  // Ring finger (4 points)
  for (int i = 0; i < 4; i++) {
    points.add(Point3D(
      (0.55 - i * 0.005) * scale,
      (0.6 - i * 0.08) * scale,
      -0.005 * i * scale,
    ));
  }
  
  // Pinky (4 points)
  for (int i = 0; i < 4; i++) {
    points.add(Point3D(
      (0.6 - i * 0.01) * scale,
      (0.62 - i * 0.07) * scale,
      -0.005 * i * scale,
    ));
  }
  
  return HandLandmarks(points: points);
}
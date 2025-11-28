import 'package:flutter_test/flutter_test.dart';
import 'package:signbridge/core/models/point_3d.dart';
import 'dart:math' as math;

void main() {
  group('Point3D', () {
    test('creates point with correct coordinates', () {
      final point = Point3D(1.0, 2.0, 3.0);
      
      expect(point.x, 1.0);
      expect(point.y, 2.0);
      expect(point.z, 3.0);
    });
    
    test('calculates distance correctly', () {
      final p1 = Point3D(0.0, 0.0, 0.0);
      final p2 = Point3D(3.0, 4.0, 0.0);
      
      expect(p1.distanceTo(p2), 5.0);
    });
    
    test('calculates 3D distance correctly', () {
      final p1 = Point3D(0.0, 0.0, 0.0);
      final p2 = Point3D(1.0, 1.0, 1.0);
      
      expect(p1.distanceTo(p2), closeTo(math.sqrt(3), 0.0001));
    });
    
    test('adds points correctly', () {
      final p1 = Point3D(1.0, 2.0, 3.0);
      final p2 = Point3D(4.0, 5.0, 6.0);
      final result = p1 + p2;
      
      expect(result.x, 5.0);
      expect(result.y, 7.0);
      expect(result.z, 9.0);
    });
    
    test('subtracts points correctly', () {
      final p1 = Point3D(5.0, 7.0, 9.0);
      final p2 = Point3D(1.0, 2.0, 3.0);
      final result = p1 - p2;
      
      expect(result.x, 4.0);
      expect(result.y, 5.0);
      expect(result.z, 6.0);
    });
    
    test('multiplies by scalar correctly', () {
      final point = Point3D(1.0, 2.0, 3.0);
      final result = point * 2.0;
      
      expect(result.x, 2.0);
      expect(result.y, 4.0);
      expect(result.z, 6.0);
    });
    
    test('divides by scalar correctly', () {
      final point = Point3D(2.0, 4.0, 6.0);
      final result = point / 2.0;
      
      expect(result.x, 1.0);
      expect(result.y, 2.0);
      expect(result.z, 3.0);
    });
    
    test('calculates magnitude correctly', () {
      final point = Point3D(3.0, 4.0, 0.0);
      
      expect(point.magnitude, 5.0);
    });
    
    test('normalizes vector correctly', () {
      final point = Point3D(3.0, 4.0, 0.0);
      final normalized = point.normalize();
      
      expect(normalized.magnitude, closeTo(1.0, 0.0001));
      expect(normalized.x, closeTo(0.6, 0.0001));
      expect(normalized.y, closeTo(0.8, 0.0001));
    });
    
    test('calculates dot product correctly', () {
      final p1 = Point3D(1.0, 2.0, 3.0);
      final p2 = Point3D(4.0, 5.0, 6.0);
      
      expect(p1.dot(p2), 32.0); // 1*4 + 2*5 + 3*6 = 32
    });
    
    test('toString returns correct format', () {
      final point = Point3D(1.5, 2.5, 3.5);
      
      expect(point.toString(), 'Point3D(1.5, 2.5, 3.5)');
    });
    
    test('equality works correctly', () {
      final p1 = Point3D(1.0, 2.0, 3.0);
      final p2 = Point3D(1.0, 2.0, 3.0);
      final p3 = Point3D(1.0, 2.0, 4.0);
      
      expect(p1 == p2, true);
      expect(p1 == p3, false);
    });
    
    test('hashCode works correctly', () {
      final p1 = Point3D(1.0, 2.0, 3.0);
      final p2 = Point3D(1.0, 2.0, 3.0);
      
      expect(p1.hashCode, p2.hashCode);
    });
  });
}
import 'dart:math';

class Point3D {
  final double x;
  final double y;
  final double z;
  
  const Point3D(this.x, this.y, this.z);
  
  Point3D operator +(Point3D other) {
    return Point3D(x + other.x, y + other.y, z + other.z);
  }
  
  Point3D operator -(Point3D other) {
    return Point3D(x - other.x, y - other.y, z - other.z);
  }
  
  Point3D operator *(double scalar) {
    return Point3D(x * scalar, y * scalar, z * scalar);
  }
  
  Point3D operator /(double scalar) {
    return Point3D(x / scalar, y / scalar, z / scalar);
  }
  
  double get magnitude {
    return sqrt(x * x + y * y + z * z);
  }
  
  Point3D normalize() {
    final mag = magnitude;
    if (mag == 0) return this;
    return this / mag;
  }
  
  double dot(Point3D other) {
    return x * other.x + y * other.y + z * other.z;
  }
  
  double distanceTo(Point3D other) {
    final dx = x - other.x;
    final dy = y - other.y;
    final dz = z - other.z;
    return sqrt(dx * dx + dy * dy + dz * dz);
  }
  
  Map<String, dynamic> toJson() => {
    'x': x,
    'y': y,
    'z': z,
  };
  
  factory Point3D.fromJson(Map<String, dynamic> json) {
    return Point3D(
      json['x'] as double,
      json['y'] as double,
      json['z'] as double,
    );
  }
  
  @override
  String toString() => 'Point3D($x, $y, $z)';
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Point3D &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y &&
          z == other.z;
  
  @override
  int get hashCode => x.hashCode ^ y.hashCode ^ z.hashCode;
}
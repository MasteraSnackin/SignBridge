import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../models/hand_landmarks.dart';
import '../models/point_3d.dart';
import '../utils/logger.dart';

/// Hand Detection Service using Google ML Kit
/// 
/// This service uses Google ML Kit's Pose Detection to detect hand landmarks.
/// While ML Kit doesn't have dedicated hand detection, we can use pose detection
/// to track hand positions and approximate hand landmarks.
/// 
/// For production, consider using:
/// - MediaPipe Hands (more accurate for hand tracking)
/// - Custom TensorFlow Lite model trained on hand landmarks
/// - Cactus SDK vision model (when available)
class HandDetectionService {
  static final HandDetectionService _instance = HandDetectionService._internal();
  factory HandDetectionService() => _instance;
  HandDetectionService._internal();
  
  PoseDetector? _poseDetector;
  bool _isInitialized = false;
  
  /// Initialize the pose detector
  Future<void> initialize() async {
    if (_isInitialized) {
      Logger.info('Hand detection already initialized');
      return;
    }
    
    try {
      Logger.info('Initializing Google ML Kit Pose Detector...');
      
      _poseDetector = PoseDetector(
        options: PoseDetectorOptions(
          mode: PoseDetectionMode.stream,
          model: PoseDetectionModel.accurate,
        ),
      );
      
      _isInitialized = true;
      Logger.success('Hand detection initialized');
    } catch (e, stackTrace) {
      Logger.error('Failed to initialize hand detection', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  /// Detect hand landmarks from camera image
  /// 
  /// Note: This uses pose detection as a proxy for hand detection.
  /// For better accuracy, consider using MediaPipe Hands or a custom model.
  Future<HandLandmarks?> detectHandLandmarks(CameraImage image) async {
    if (!_isInitialized || _poseDetector == null) {
      Logger.warning('Hand detection not initialized');
      return null;
    }
    
    try {
      // Convert CameraImage to InputImage
      final inputImage = _convertCameraImage(image);
      if (inputImage == null) {
        return null;
      }
      
      // Detect poses
      final poses = await _poseDetector!.processImage(inputImage);
      
      if (poses.isEmpty) {
        return null;
      }
      
      // Extract hand landmarks from pose
      final handLandmarks = _extractHandLandmarks(poses.first);
      
      return handLandmarks;
    } catch (e, stackTrace) {
      Logger.error('Failed to detect hand landmarks', error: e, stackTrace: stackTrace);
      return null;
    }
  }
  
  /// Convert CameraImage to InputImage for ML Kit
  InputImage? _convertCameraImage(CameraImage image) {
    try {
      // Get image rotation
      const rotation = InputImageRotation.rotation0deg;
      
      // Get image format
      const format = InputImageFormat.nv21;
      
      // Create plane data
      final planeData = image.planes.map((plane) {
        return InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: format,
          bytesPerRow: plane.bytesPerRow,
        );
      }).toList();
      
      // Create InputImage
      final inputImage = InputImage.fromBytes(
        bytes: image.planes[0].bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: format,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );
      
      return inputImage;
    } catch (e, stackTrace) {
      Logger.error('Failed to convert camera image', error: e, stackTrace: stackTrace);
      return null;
    }
  }
  
  /// Extract hand landmarks from pose
  /// 
  /// This is an approximation since ML Kit Pose Detection doesn't provide
  /// detailed hand landmarks. For production, use MediaPipe Hands or a
  /// custom hand detection model.
  HandLandmarks? _extractHandLandmarks(Pose pose) {
    try {
      // Get right wrist landmark
      final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];
      if (rightWrist == null) {
        return null;
      }
      
      // Generate approximate hand landmarks based on wrist position
      // This is a simplified approach - for production, use a proper hand model
      final points = _generateHandLandmarksFromWrist(
        rightWrist.x,
        rightWrist.y,
        rightWrist.z,
      );
      
      return HandLandmarks(
        points: points,
        confidence: rightWrist.likelihood,
        timestamp: DateTime.now(),
      );
    } catch (e, stackTrace) {
      Logger.error('Failed to extract hand landmarks', error: e, stackTrace: stackTrace);
      return null;
    }
  }
  
  /// Generate approximate hand landmarks from wrist position
  /// 
  /// This creates a simplified hand model with 21 landmarks.
  /// For production, replace with actual hand detection model.
  List<Point3D> _generateHandLandmarksFromWrist(double wx, double wy, double wz) {
    final points = <Point3D>[];
    
    // Normalize coordinates to 0-1 range
    final normalizedWx = wx / 1000.0;
    final normalizedWy = wy / 1000.0;
    final normalizedWz = wz / 1000.0;
    
    // Wrist (landmark 0)
    points.add(Point3D(normalizedWx, normalizedWy, normalizedWz));
    
    // Thumb (landmarks 1-4)
    for (int i = 0; i < 4; i++) {
      points.add(Point3D(
        normalizedWx - 0.05 + (i * 0.02),
        normalizedWy - 0.05 - (i * 0.03),
        normalizedWz - (i * 0.01),
      ));
    }
    
    // Index finger (landmarks 5-8)
    for (int i = 0; i < 4; i++) {
      points.add(Point3D(
        normalizedWx - 0.02 + (i * 0.01),
        normalizedWy - 0.08 - (i * 0.05),
        normalizedWz - (i * 0.005),
      ));
    }
    
    // Middle finger (landmarks 9-12)
    for (int i = 0; i < 4; i++) {
      points.add(Point3D(
        normalizedWx + (i * 0.005),
        normalizedWy - 0.08 - (i * 0.06),
        normalizedWz - (i * 0.005),
      ));
    }
    
    // Ring finger (landmarks 13-16)
    for (int i = 0; i < 4; i++) {
      points.add(Point3D(
        normalizedWx + 0.02 - (i * 0.005),
        normalizedWy - 0.08 - (i * 0.05),
        normalizedWz - (i * 0.005),
      ));
    }
    
    // Pinky (landmarks 17-20)
    for (int i = 0; i < 4; i++) {
      points.add(Point3D(
        normalizedWx + 0.04 - (i * 0.01),
        normalizedWy - 0.06 - (i * 0.04),
        normalizedWz - (i * 0.005),
      ));
    }
    
    return points;
  }
  
  /// Dispose the pose detector
  Future<void> dispose() async {
    if (_poseDetector != null) {
      await _poseDetector!.close();
      _poseDetector = null;
      _isInitialized = false;
      Logger.info('Hand detection disposed');
    }
  }
}
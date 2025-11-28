import 'dart:ui';
import 'package:camera/camera.dart';
import '../utils/logger.dart';

class CameraService {
  static final CameraService _instance = CameraService._internal();
  factory CameraService() => _instance;
  CameraService._internal();
  
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  
  // Getters
  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  List<CameraDescription> get cameras => _cameras;
  
  /// Initialize camera service
  Future<void> initialize() async {
    if (_isInitialized) {
      Logger.info('Camera already initialized');
      return;
    }
    
    try {
      Logger.info('Initializing camera service');
      
      // Get available cameras
      _cameras = await availableCameras();
      
      if (_cameras.isEmpty) {
        throw Exception('No cameras available');
      }
      
      Logger.info('Found ${_cameras.length} cameras');
      
      // Use front camera for sign language recognition
      final frontCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras.first,
      );
      
      // Initialize camera controller
      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium, // Balance quality and performance
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420, // Efficient format
      );
      
      await _controller!.initialize();
      
      _isInitialized = true;
      Logger.success('Camera initialized: ${frontCamera.name}');
    } catch (e, stackTrace) {
      Logger.error('Failed to initialize camera', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  /// Start image stream for processing
  Future<void> startImageStream(Function(CameraImage) onImage) async {
    if (!_isInitialized || _controller == null) {
      throw Exception('Camera not initialized');
    }
    
    try {
      Logger.info('Starting camera image stream');
      await _controller!.startImageStream(onImage);
      Logger.success('Image stream started');
    } catch (e, stackTrace) {
      Logger.error('Failed to start image stream', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  /// Stop image stream
  Future<void> stopImageStream() async {
    if (!_isInitialized || _controller == null) {
      return;
    }
    
    try {
      if (_controller!.value.isStreamingImages) {
        await _controller!.stopImageStream();
        Logger.info('Image stream stopped');
      }
    } catch (e, stackTrace) {
      Logger.error('Failed to stop image stream', error: e, stackTrace: stackTrace);
    }
  }
  
  /// Switch between front and back camera
  Future<void> switchCamera() async {
    if (!_isInitialized || _cameras.length < 2) {
      return;
    }
    
    try {
      Logger.info('Switching camera');
      
      final currentLens = _controller!.description.lensDirection;
      final newCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection != currentLens,
        orElse: () => _cameras.first,
      );
      
      await dispose();
      
      _controller = CameraController(
        newCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      
      await _controller!.initialize();
      _isInitialized = true;
      
      Logger.success('Switched to ${newCamera.name}');
    } catch (e, stackTrace) {
      Logger.error('Failed to switch camera', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  /// Set flash mode
  Future<void> setFlashMode(FlashMode mode) async {
    if (!_isInitialized || _controller == null) {
      return;
    }
    
    try {
      await _controller!.setFlashMode(mode);
      Logger.debug('Flash mode set to $mode');
    } catch (e) {
      Logger.error('Failed to set flash mode', error: e);
    }
  }
  
  /// Set zoom level (0.0 to 1.0)
  Future<void> setZoomLevel(double zoom) async {
    if (!_isInitialized || _controller == null) {
      return;
    }
    
    try {
      final clampedZoom = zoom.clamp(0.0, 1.0);
      await _controller!.setZoomLevel(clampedZoom);
      Logger.debug('Zoom level set to $clampedZoom');
    } catch (e) {
      Logger.error('Failed to set zoom level', error: e);
    }
  }
  
  /// Get camera resolution
  Size? getCameraResolution() {
    if (!_isInitialized || _controller == null) {
      return null;
    }
    
    return Size(
      _controller!.value.previewSize!.height,
      _controller!.value.previewSize!.width,
    );
  }
  
  /// Check if camera is streaming
  bool get isStreaming {
    return _isInitialized && 
           _controller != null && 
           _controller!.value.isStreamingImages;
  }
  
  /// Dispose camera controller
  Future<void> dispose() async {
    if (!_isInitialized || _controller == null) {
      return;
    }
    
    try {
      await stopImageStream();
      await _controller!.dispose();
      _controller = null;
      _isInitialized = false;
      Logger.info('Camera disposed');
    } catch (e, stackTrace) {
      Logger.error('Failed to dispose camera', error: e, stackTrace: stackTrace);
    }
  }
}
import 'package:permission_handler/permission_handler.dart';
import '../utils/logger.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();
  
  /// Check if camera permission is granted
  Future<bool> hasCameraPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }
  
  /// Check if microphone permission is granted
  Future<bool> hasMicrophonePermission() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }
  
  /// Request camera permission
  Future<bool> requestCameraPermission() async {
    Logger.info('Requesting camera permission');
    
    final status = await Permission.camera.status;
    
    if (status.isGranted) {
      Logger.success('Camera permission already granted');
      return true;
    }
    
    if (status.isDenied) {
      final result = await Permission.camera.request();
      if (result.isGranted) {
        Logger.success('Camera permission granted');
        return true;
      } else {
        Logger.warning('Camera permission denied');
        return false;
      }
    }
    
    if (status.isPermanentlyDenied) {
      Logger.warning('Camera permission permanently denied');
      await openAppSettings();
      return false;
    }
    
    return false;
  }
  
  /// Request microphone permission
  Future<bool> requestMicrophonePermission() async {
    Logger.info('Requesting microphone permission');
    
    final status = await Permission.microphone.status;
    
    if (status.isGranted) {
      Logger.success('Microphone permission already granted');
      return true;
    }
    
    if (status.isDenied) {
      final result = await Permission.microphone.request();
      if (result.isGranted) {
        Logger.success('Microphone permission granted');
        return true;
      } else {
        Logger.warning('Microphone permission denied');
        return false;
      }
    }
    
    if (status.isPermanentlyDenied) {
      Logger.warning('Microphone permission permanently denied');
      await openAppSettings();
      return false;
    }
    
    return false;
  }
  
  /// Request all required permissions
  Future<Map<String, bool>> requestAllPermissions() async {
    Logger.info('Requesting all permissions');
    
    final results = await [
      Permission.camera,
      Permission.microphone,
    ].request();
    
    final cameraGranted = results[Permission.camera]?.isGranted ?? false;
    final micGranted = results[Permission.microphone]?.isGranted ?? false;
    
    Logger.info('Camera: ${cameraGranted ? "✅" : "❌"}, Microphone: ${micGranted ? "✅" : "❌"}');
    
    return {
      'camera': cameraGranted,
      'microphone': micGranted,
    };
  }
  
  /// Check if all required permissions are granted
  Future<bool> hasAllPermissions() async {
    final camera = await hasCameraPermission();
    final microphone = await hasMicrophonePermission();
    return camera && microphone;
  }
  
  /// Open app settings
  Future<void> openSettings() async {
    Logger.info('Opening app settings');
    await openAppSettings();
  }
}
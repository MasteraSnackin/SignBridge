import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/models/hand_landmarks.dart';
import '../../../core/models/recognition_result.dart';
import '../../../core/models/enums.dart';
import '../../../core/utils/logger.dart';
import '../../sign_recognition/models/gesture_classifier.dart';
import '../models/hybrid_metrics.dart';
import 'cloud_api_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Hybrid Router Service
/// 
/// Implements intelligent routing between local and cloud inference based on:
/// - Local confidence score
/// - Network availability
/// - User preferences
/// - Performance metrics
/// 
/// This is the core of Track 2: The Hybrid Hero implementation.
class HybridRouter extends ChangeNotifier {
  static final HybridRouter _instance = HybridRouter._internal();
  factory HybridRouter() => _instance;
  HybridRouter._internal();
  
  final GestureClassifier _localClassifier = GestureClassifier();
  final CloudAPIService _cloudAPI = CloudAPIService();
  final HybridMetrics _metrics = HybridMetrics();
  
  // Configuration
  bool _hybridModeEnabled = false;
  double _confidenceThreshold = 0.75;
  bool _preferLocal = true;
  
  // State
  bool _isOnline = false;
  bool _cloudAvailable = false;
  
  // Getters
  bool get hybridModeEnabled => _hybridModeEnabled;
  double get confidenceThreshold => _confidenceThreshold;
  bool get preferLocal => _preferLocal;
  bool get isOnline => _isOnline;
  bool get cloudAvailable => _cloudAvailable;
  HybridMetrics get metrics => _metrics;
  
  /// Initialize the hybrid router
  Future<void> initialize() async {
    try {
      Logger.info('Initializing HybridRouter');
      
      // Load preferences
      await _loadPreferences();
      
      // Check network connectivity
      await _checkConnectivity();
      
      // Check cloud API availability
      if (_isOnline) {
        _cloudAvailable = await _cloudAPI.isAvailable();
      }
      
      // Listen to connectivity changes
      Connectivity().onConnectivityChanged.listen((result) {
        _handleConnectivityChange(result);
      });
      
      Logger.success('HybridRouter initialized (mode: ${_hybridModeEnabled ? "enabled" : "disabled"})');
    } catch (e, stackTrace) {
      Logger.error('Failed to initialize HybridRouter', error: e, stackTrace: stackTrace);
    }
  }
  
  /// Route gesture recognition request
  /// 
  /// This is the main routing logic that decides whether to use local or cloud inference.
  Future<RecognitionResult> route(HandLandmarks landmarks) async {
    final startTime = DateTime.now();
    
    try {
      // Step 1: Always try local first
      final localResult = _localClassifier.classify(landmarks.toVector());
      
      // Step 2: Check if we should use cloud fallback
      final shouldUseCloud = _shouldRouteToCloud(localResult);
      
      if (shouldUseCloud) {
        Logger.info('Routing to cloud (local confidence: ${(localResult.confidence * 100).toStringAsFixed(1)}%)');
        
        // Try cloud inference
        final cloudResult = await _cloudAPI.recognizeGesture(landmarks);
        
        if (cloudResult != null && cloudResult.confidence > localResult.confidence) {
          // Cloud gave better result
          _metrics.recordCloudRequest(
            latencyMs: DateTime.now().difference(startTime).inMilliseconds,
            success: true,
          );
          
          Logger.success('Cloud result used (confidence: ${(cloudResult.confidence * 100).toStringAsFixed(1)}%)');
          notifyListeners();
          return cloudResult;
        } else {
          // Cloud failed or gave worse result, use local
          _metrics.recordCloudRequest(
            latencyMs: DateTime.now().difference(startTime).inMilliseconds,
            success: false,
          );
          
          Logger.warning('Cloud result rejected, using local');
        }
      }
      
      // Use local result
      _metrics.recordLocalRequest(
        latencyMs: DateTime.now().difference(startTime).inMilliseconds,
        success: localResult.confidence > 0.5,
      );
      
      notifyListeners();
      return localResult.copyWith(source: ProcessingSource.local);
      
    } catch (e, stackTrace) {
      Logger.error('Routing failed', error: e, stackTrace: stackTrace);
      
      // Fallback to local on error
      final localResult = _localClassifier.classify(landmarks.toVector());
      _metrics.recordLocalRequest(
        latencyMs: DateTime.now().difference(startTime).inMilliseconds,
        success: false,
      );
      
      return localResult.copyWith(source: ProcessingSource.localFallback);
    }
  }
  
  /// Determine if request should be routed to cloud
  bool _shouldRouteToCloud(RecognitionResult localResult) {
    // Don't use cloud if hybrid mode is disabled
    if (!_hybridModeEnabled) {
      return false;
    }
    
    // Don't use cloud if offline
    if (!_isOnline || !_cloudAvailable) {
      return false;
    }
    
    // Don't use cloud if user prefers local only
    if (_preferLocal && localResult.confidence >= _confidenceThreshold) {
      return false;
    }
    
    // Use cloud if local confidence is below threshold
    if (localResult.confidence < _confidenceThreshold) {
      return true;
    }
    
    return false;
  }
  
  /// Check network connectivity
  Future<void> _checkConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      _isOnline = connectivityResult != ConnectivityResult.none;
      Logger.info('Network status: ${_isOnline ? "online" : "offline"}');
    } catch (e) {
      _isOnline = false;
      Logger.warning('Failed to check connectivity: $e');
    }
  }
  
  /// Handle connectivity changes
  void _handleConnectivityChange(ConnectivityResult result) async {
    final wasOnline = _isOnline;
    _isOnline = result != ConnectivityResult.none;
    
    if (_isOnline != wasOnline) {
      Logger.info('Connectivity changed: ${_isOnline ? "online" : "offline"}');
      
      if (_isOnline) {
        _cloudAvailable = await _cloudAPI.isAvailable();
      } else {
        _cloudAvailable = false;
      }
      
      notifyListeners();
    }
  }
  
  /// Enable/disable hybrid mode
  Future<void> setHybridMode(bool enabled) async {
    _hybridModeEnabled = enabled;
    await _savePreferences();
    Logger.info('Hybrid mode ${enabled ? "enabled" : "disabled"}');
    notifyListeners();
  }
  
  /// Set confidence threshold
  Future<void> setConfidenceThreshold(double threshold) async {
    _confidenceThreshold = threshold.clamp(0.5, 0.95);
    await _savePreferences();
    Logger.info('Confidence threshold set to ${(_confidenceThreshold * 100).toStringAsFixed(0)}%');
    notifyListeners();
  }
  
  /// Set local preference
  Future<void> setPreferLocal(bool prefer) async {
    _preferLocal = prefer;
    await _savePreferences();
    Logger.info('Prefer local set to $prefer');
    notifyListeners();
  }
  
  /// Reset metrics
  void resetMetrics() {
    _metrics.reset();
    Logger.info('Hybrid metrics reset');
    notifyListeners();
  }
  
  /// Load preferences from storage
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _hybridModeEnabled = prefs.getBool('hybrid_mode_enabled') ?? false;
      _confidenceThreshold = prefs.getDouble('confidence_threshold') ?? 0.75;
      _preferLocal = prefs.getBool('prefer_local') ?? true;
    } catch (e) {
      Logger.warning('Failed to load hybrid preferences: $e');
    }
  }
  
  /// Save preferences to storage
  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hybrid_mode_enabled', _hybridModeEnabled);
      await prefs.setDouble('confidence_threshold', _confidenceThreshold);
      await prefs.setBool('prefer_local', _preferLocal);
    } catch (e) {
      Logger.warning('Failed to save hybrid preferences: $e');
    }
  }
  
  /// Get router statistics
  Map<String, dynamic> getStatistics() {
    return {
      'hybridModeEnabled': _hybridModeEnabled,
      'confidenceThreshold': _confidenceThreshold,
      'preferLocal': _preferLocal,
      'isOnline': _isOnline,
      'cloudAvailable': _cloudAvailable,
      'metrics': _metrics.toJson(),
    };
  }
}
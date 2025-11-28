import 'dart:math' as math;
import 'package:cactus/cactus.dart';
import 'package:camera/camera.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/hand_landmarks.dart';
import '../utils/logger.dart';
import 'hand_detection_service.dart';

/// Cactus Model Service - AI Model Management
/// 
/// This service integrates with the real Cactus SDK for on-device AI inference.
/// 
/// Integrated Models:
/// - CactusSTT (Whisper-Tiny): Speech-to-text transcription ✅
/// - CactusLM (Qwen3-0.6B): Text processing and routing logic ✅
/// 
/// Pending Integration:
/// - Vision model for hand landmark detection (awaiting Cactus SDK support)
///   Currently using fallback implementation with Google ML Kit
class CactusModelService {
  static final CactusModelService _instance = CactusModelService._internal();
  factory CactusModelService() => _instance;
  CactusModelService._internal();
  
  // Cactus SDK instances
  CactusSTT? _sttModel;
  CactusLM? _lmModel;
  
  // Hand detection service (Google ML Kit)
  final HandDetectionService _handDetectionService = HandDetectionService();
  bool _handDetectionInitialized = false;
  
  bool _isInitialized = false;
  double _downloadProgress = 0.0;
  
  // Statistics
  bool _visionModelLoaded = false;
  bool _textModelLoaded = false;
  bool _speechModelLoaded = false;
  int _initTimeMs = 0;
  int _totalInferences = 0;
  int _averageLatencyMs = 0;
  final List<int> _latencyHistory = [];
  
  // Random generator for vision fallback
  final math.Random _random = math.Random();
  
  // Getters
  CactusSTT? get sttModel => _sttModel;
  CactusLM? get lmModel => _lmModel;
  HandDetectionService get handDetectionService => _handDetectionService;
  bool get isInitialized => _isInitialized;
  double get downloadProgress => _downloadProgress;
  
  /// Initialize all AI models
  Future<void> initialize({
    Function(double)? onProgress,
  }) async {
    if (_isInitialized) {
      Logger.info('Models already initialized');
      return;
    }
    
    try {
      final startTime = DateTime.now();
      Logger.info('Starting Cactus SDK initialization');
      
      final prefs = await SharedPreferences.getInstance();
      final modelsDownloaded = prefs.getBool('models_downloaded') ?? false;
      
      if (!modelsDownloaded) {
        await _downloadModels(onProgress);
        await prefs.setBool('models_downloaded', true);
      }
      
      // Initialize models
      await _initializeSpeechModel();
      await _initializeTextModel();
      await _initializeHandDetection(); // Google ML Kit
      
      _isInitialized = true;
      _initTimeMs = DateTime.now().difference(startTime).inMilliseconds;
      
      Logger.success('All Cactus models initialized successfully in ${_initTimeMs}ms');
    } catch (e, stackTrace) {
      Logger.error('Failed to initialize Cactus models', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  /// Download AI models
  Future<void> _downloadModels(Function(double)? onProgress) async {
    Logger.info('Downloading AI models...');
    
    try {
      // Download Speech-to-Text model (Whisper-Tiny)
      Logger.info('Downloading Whisper-Tiny...');
      final stt = CactusSTT();
      await stt.download(model: "whisper-tiny");
      onProgress?.call(0.33);
      Logger.success('Whisper-Tiny downloaded');
      
      // Download Text model (Qwen3-0.6B)
      Logger.info('Downloading Qwen3-0.6B...');
      final lm = CactusLM();
      await lm.downloadModel(model: "qwen3-0.6");
      onProgress?.call(0.66);
      Logger.success('Qwen3-0.6B downloaded');
      
      // Vision model download (placeholder - awaiting Cactus SDK support)
      Logger.info('Vision model: Using fallback implementation');
      await Future.delayed(const Duration(milliseconds: 500));
      onProgress?.call(1.0);
      
      Logger.success('All models downloaded');
    } catch (e, stackTrace) {
      Logger.error('Failed to download models', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  /// Initialize speech-to-text model (Whisper-Tiny)
  Future<void> _initializeSpeechModel() async {
    Logger.info('Initializing Whisper-Tiny speech model...');
    
    try {
      _sttModel = CactusSTT();
      await _sttModel!.init(model: "whisper-tiny");
      _speechModelLoaded = true;
      
      Logger.success('Speech model initialized (Cactus SDK)');
    } catch (e, stackTrace) {
      Logger.error('Failed to initialize speech model', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  /// Initialize text model (Qwen3-0.6B)
  Future<void> _initializeTextModel() async {
    Logger.info('Initializing Qwen3-0.6B text model...');
    
    try {
      _lmModel = CactusLM();
      await _lmModel!.initializeModel();
      _textModelLoaded = true;
      
      Logger.success('Text model initialized (Cactus SDK)');
    } catch (e, stackTrace) {
      Logger.error('Failed to initialize text model', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  /// Initialize hand detection using Google ML Kit
  Future<void> _initializeHandDetection() async {
    Logger.info('Initializing hand detection (Google ML Kit)...');
    
    try {
      await _handDetectionService.initialize();
      _handDetectionInitialized = true;
      _visionModelLoaded = true;
      
      Logger.success('Hand detection initialized (Google ML Kit Pose Detection)');
    } catch (e, stackTrace) {
      Logger.error('Failed to initialize hand detection', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  /// Detect hand landmarks from camera image using Google ML Kit
  Future<HandLandmarks?> detectHandLandmarks(CameraImage imageData) async {
    if (!_isInitialized || !_handDetectionInitialized) {
      Logger.warning('Models not initialized');
      return null;
    }
    
    try {
      final startTime = DateTime.now();
      
      // Use Google ML Kit for hand detection
      final landmarks = await _handDetectionService.detectHandLandmarks(imageData);
      
      if (landmarks != null) {
        final latency = DateTime.now().difference(startTime).inMilliseconds;
        _updateStatistics(latency);
      }
      
      return landmarks;
    } catch (e, stackTrace) {
      Logger.error('Failed to detect hand landmarks', error: e, stackTrace: stackTrace);
      return null;
    }
  }
  
  /// Transcribe audio to text using Cactus SDK (Whisper-Tiny)
  Future<String?> transcribeAudio(List<int> audioData) async {
    if (!_isInitialized || _sttModel == null) {
      Logger.warning('Speech model not initialized');
      return null;
    }
    
    try {
      final startTime = DateTime.now();
      
      // Use Cactus SDK for transcription
      final transcription = await _sttModel!.transcribe();
      
      final latency = DateTime.now().difference(startTime).inMilliseconds;
      _updateStatistics(latency);
      
      Logger.info('Transcription: ${transcription?.text ?? "null"}');
      return transcription?.text;
    } catch (e, stackTrace) {
      Logger.error('Failed to transcribe audio', error: e, stackTrace: stackTrace);
      return null;
    }
  }
  
  /// Process text with language model using Cactus SDK (Qwen3-0.6B)
  Future<String?> processText(String input) async {
    if (!_isInitialized || _lmModel == null) {
      Logger.warning('Text model not initialized');
      return null;
    }
    
    try {
      final startTime = DateTime.now();
      
      // Use Cactus SDK for text processing
      final result = await _lmModel!.generateCompletion(
        messages: [ChatMessage(content: input, role: "user")],
      );
      
      final latency = DateTime.now().difference(startTime).inMilliseconds;
      _updateStatistics(latency);
      
      return result.response;
    } catch (e, stackTrace) {
      Logger.error('Failed to process text', error: e, stackTrace: stackTrace);
      return null;
    }
  }
  
  /// Update inference statistics
  void _updateStatistics(int latencyMs) {
    _totalInferences++;
    _latencyHistory.add(latencyMs);
    
    // Keep only last 100 measurements
    if (_latencyHistory.length > 100) {
      _latencyHistory.removeAt(0);
    }
    
    // Calculate average
    _averageLatencyMs = _latencyHistory.reduce((a, b) => a + b) ~/ _latencyHistory.length;
  }
  
  /// Get model statistics
  Map<String, dynamic> getStatistics() {
    return {
      'visionModelLoaded': _visionModelLoaded,
      'textModelLoaded': _textModelLoaded,
      'speechModelLoaded': _speechModelLoaded,
      'initTimeMs': _initTimeMs,
      'totalInferences': _totalInferences,
      'averageLatencyMs': _averageLatencyMs,
      'isInitialized': _isInitialized,
      'isMockMode': false, // Using real Cactus SDK
      'visionModel': 'google-mlkit-pose-detection', // Using Google ML Kit
      'sttModel': 'whisper-tiny',
      'lmModel': 'qwen3-0.6',
    };
  }
  
  /// Check if models are ready
  Future<bool> areModelsReady() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('models_downloaded') ?? false;
  }
  
  /// Reset model download status (for testing)
  Future<void> resetDownloadStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('models_downloaded', false);
    Logger.info('Model download status reset');
  }
  
  /// Dispose all models
  Future<void> dispose() async {
    if (!_isInitialized) return;
    
    try {
      // Dispose Cactus SDK models
      _sttModel = null;
      _lmModel = null;
      await _handDetectionService.dispose();
      _handDetectionInitialized = false;
      _isInitialized = false;
      
      Logger.info('Cactus models disposed');
    } catch (e, stackTrace) {
      Logger.error('Failed to dispose models', error: e, stackTrace: stackTrace);
    }
  }
}
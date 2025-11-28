import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import '../../../core/services/cactus_model_service.dart';
import '../../../core/services/camera_service.dart';
import '../../../core/utils/logger.dart';
import '../models/gesture_classifier.dart';
import '../models/letter_buffer.dart';
import '../../../features/text_to_speech/services/tts_service.dart';
import '../../hybrid_routing/services/hybrid_router.dart';

class SignRecognitionService extends ChangeNotifier {
  final CactusModelService _cactusService = CactusModelService();
  final CameraService _cameraService = CameraService();
  final GestureClassifier _classifier = GestureClassifier();
  final LetterBuffer _buffer = LetterBuffer(windowSize: 5);
  final TTSService _ttsService = TTSService();
  final HybridRouter _hybridRouter = HybridRouter();
  
  bool _isProcessing = false;
  String _currentLetter = '';
  double _confidence = 0.0;
  String _assembledText = '';
  int _fps = 0;
  int _latencyMs = 0;
  int _frameCount = 0;
  DateTime? _lastFrameTime;
  String _processingSource = 'local';
  
  // Frame throttling (process every 3rd frame for 10 FPS at 30 FPS capture)
  int _frameSkipCounter = 0;
  final int _frameSkipInterval = 3;
  
  // Getters
  bool get isProcessing => _isProcessing;
  String get currentLetter => _currentLetter;
  double get confidence => _confidence;
  String get assembledText => _assembledText;
  int get fps => _fps;
  int get latencyMs => _latencyMs;
  String get processingSource => _processingSource;
  CameraController? get cameraController => _cameraService.controller;
  HybridRouter get hybridRouter => _hybridRouter;
  
  /// Initialize the recognition service
  Future<void> initialize() async {
    try {
      Logger.info('Initializing SignRecognitionService');
      
      // Initialize Cactus models
      if (!_cactusService.isInitialized) {
        await _cactusService.initialize();
      }
      
      // Initialize TTS
      if (!_ttsService.isInitialized) {
        await _ttsService.initialize();
      }
      
      // Initialize camera
      if (!_cameraService.isInitialized) {
        await _cameraService.initialize();
      }
      
      // Initialize hybrid router
      await _hybridRouter.initialize();
      
      Logger.success('SignRecognitionService initialized');
    } catch (e, stackTrace) {
      Logger.error('Failed to initialize SignRecognitionService',
                   error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  /// Start sign recognition
  Future<void> startRecognition() async {
    if (_isProcessing) {
      Logger.warning('Recognition already running');
      return;
    }
    
    try {
      Logger.info('Starting sign recognition');
      
      // Ensure everything is initialized
      await initialize();
      
      // Clear previous state
      _buffer.clear();
      _frameCount = 0;
      _frameSkipCounter = 0;
      _lastFrameTime = DateTime.now();
      
      // Start camera stream
      await _cameraService.startImageStream(_processFrame);
      
      _isProcessing = true;
      notifyListeners();
      
      Logger.success('Sign recognition started');
    } catch (e, stackTrace) {
      Logger.error('Failed to start recognition', error: e, stackTrace: stackTrace);
      _isProcessing = false;
      notifyListeners();
      rethrow;
    }
  }
  
  /// Stop sign recognition
  Future<void> stopRecognition() async {
    if (!_isProcessing) {
      return;
    }
    
    try {
      Logger.info('Stopping sign recognition');
      
      await _cameraService.stopImageStream();
      
      _isProcessing = false;
      notifyListeners();
      
      Logger.success('Sign recognition stopped');
    } catch (e, stackTrace) {
      Logger.error('Failed to stop recognition', error: e, stackTrace: stackTrace);
    }
  }
  
  /// Process camera frame
  void _processFrame(CameraImage image) async {
    if (!_isProcessing) return;
    
    // Frame throttling: process every 3rd frame (10 FPS from 30 FPS)
    _frameSkipCounter++;
    if (_frameSkipCounter % _frameSkipInterval != 0) {
      return;
    }
    
    try {
      final startTime = DateTime.now();
      _frameCount++;
      
      // Step 1: Detect hand landmarks using Cactus SDK
      final landmarks = await _cactusService.detectHandLandmarks(image);
      
      if (landmarks == null || landmarks.confidence < 0.5) {
        // No hand detected or low confidence
        return;
      }
      
      // Step 2: Normalize landmarks
      final normalized = landmarks.normalize();
      
      // Step 3: Classify gesture using hybrid router (Track 2 feature)
      // This will intelligently route between local and cloud based on confidence
      final result = await _hybridRouter.route(normalized);
      
      // Track processing source for transparency
      _processingSource = result.source.toString().split('.').last;
      
      // Step 4: Buffer result for stability
      _buffer.add(result);
      
      // Step 5: Get stable letter
      final stableLetter = _buffer.getStableLetter();
      
      if (stableLetter != null) {
        _currentLetter = stableLetter;
        _confidence = _buffer.getAverageConfidence();
        
        // Add to assembled text
        _assembledText += stableLetter;
        
        Logger.info('Recognized: $stableLetter (${(_confidence * 100).toStringAsFixed(1)}%) via $_processingSource');
        
        // Reset buffer to allow same letter again
        _buffer.resetStableLetter();
        
        notifyListeners();
      }
      
      // Update metrics
      _latencyMs = DateTime.now().difference(startTime).inMilliseconds;
      _updateFps();
      
    } catch (e, stackTrace) {
      Logger.error('Error processing frame', error: e, stackTrace: stackTrace);
    }
  }
  
  /// Update FPS calculation
  void _updateFps() {
    final now = DateTime.now();
    if (_lastFrameTime != null) {
      final delta = now.difference(_lastFrameTime!).inMilliseconds;
      if (delta > 0) {
        _fps = (1000 / delta).round();
      }
    }
    _lastFrameTime = now;
  }
  
  /// Add space to text
  void addSpace() {
    if (_assembledText.isNotEmpty && !_assembledText.endsWith(' ')) {
      _assembledText += ' ';
      Logger.debug('Space added');
      notifyListeners();
    }
  }
  
  /// Delete last character
  void deleteLastCharacter() {
    if (_assembledText.isNotEmpty) {
      _assembledText = _assembledText.substring(0, _assembledText.length - 1);
      Logger.debug('Last character deleted');
      notifyListeners();
    }
  }
  
  /// Clear assembled text
  void clearText() {
    _assembledText = '';
    _currentLetter = '';
    _confidence = 0.0;
    _buffer.clear();
    Logger.debug('Text cleared');
    notifyListeners();
  }
  
  /// Speak assembled text
  Future<void> speakText() async {
    if (_assembledText.isEmpty) {
      Logger.warning('No text to speak');
      return;
    }
    
    try {
      Logger.info('Speaking: "$_assembledText"');
      await _ttsService.speak(_assembledText);
    } catch (e, stackTrace) {
      Logger.error('Failed to speak text', error: e, stackTrace: stackTrace);
    }
  }
  
  /// Stop speaking
  Future<void> stopSpeaking() async {
    try {
      await _ttsService.stop();
    } catch (e) {
      Logger.error('Failed to stop speaking', error: e);
    }
  }
  
  /// Get buffer statistics (for debugging)
  Map<String, dynamic> getStatistics() {
    return {
      'isProcessing': _isProcessing,
      'currentLetter': _currentLetter,
      'confidence': _confidence,
      'assembledText': _assembledText,
      'fps': _fps,
      'latencyMs': _latencyMs,
      'frameCount': _frameCount,
      'processingSource': _processingSource,
      'bufferStats': _buffer.getStatistics(),
      'hybridStats': _hybridRouter.getStatistics(),
    };
  }
  
  @override
  void dispose() {
    stopRecognition();
    _cameraService.dispose();
    _ttsService.dispose();
    super.dispose();
  }
}
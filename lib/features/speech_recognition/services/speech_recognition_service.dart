import 'package:flutter/foundation.dart';
import '../../../core/services/cactus_model_service.dart';
import '../../../core/utils/logger.dart';

class SpeechRecognitionService extends ChangeNotifier {
  final CactusModelService _cactusService = CactusModelService();
  
  bool _isListening = false;
  String _transcribedText = '';
  List<String> _words = [];
  double _confidence = 0.0;
  int _latencyMs = 0;
  
  // Getters
  bool get isListening => _isListening;
  String get transcribedText => _transcribedText;
  List<String> get words => _words;
  double get confidence => _confidence;
  int get latencyMs => _latencyMs;
  
  /// Initialize the service
  Future<void> initialize() async {
    try {
      Logger.info('Initializing SpeechRecognitionService');
      
      if (!_cactusService.isInitialized) {
        await _cactusService.initialize();
      }
      
      Logger.success('SpeechRecognitionService initialized');
    } catch (e, stackTrace) {
      Logger.error('Failed to initialize SpeechRecognitionService', 
                   error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  /// Start listening for speech
  Future<void> startListening() async {
    if (_isListening) {
      Logger.warning('Already listening');
      return;
    }
    
    try {
      Logger.info('Starting speech recognition');
      
      await initialize();
      
      _isListening = true;
      _transcribedText = '';
      _words = [];
      
      // TODO: Start actual audio capture
      // For now, simulate with placeholder
      _simulateListening();
      
      notifyListeners();
      Logger.success('Speech recognition started');
    } catch (e, stackTrace) {
      Logger.error('Failed to start listening', error: e, stackTrace: stackTrace);
      _isListening = false;
      notifyListeners();
      rethrow;
    }
  }
  
  /// Stop listening
  Future<void> stopListening() async {
    if (!_isListening) {
      return;
    }
    
    try {
      Logger.info('Stopping speech recognition');
      
      // TODO: Stop actual audio capture
      
      _isListening = false;
      notifyListeners();
      
      Logger.success('Speech recognition stopped');
    } catch (e, stackTrace) {
      Logger.error('Failed to stop listening', error: e, stackTrace: stackTrace);
    }
  }
  
  /// Process audio data
  /// 
  /// TODO: Replace with actual audio capture and Whisper processing
  Future<void> _processAudio(List<int> audioData) async {
    if (!_isListening) return;
    
    try {
      final startTime = DateTime.now();
      
      // Use Whisper model from Cactus SDK
      final text = await _cactusService.transcribeAudio(audioData);
      
      if (text != null && text.isNotEmpty) {
        _transcribedText = text;
        _words = _tokenizeText(text);
        _confidence = 0.85; // Placeholder
        
        Logger.info('Transcribed: "$text"');
        notifyListeners();
      }
      
      _latencyMs = DateTime.now().difference(startTime).inMilliseconds;
    } catch (e, stackTrace) {
      Logger.error('Error processing audio', error: e, stackTrace: stackTrace);
    }
  }
  
  /// Simulate listening (for testing without microphone)
  void _simulateListening() {
    // Placeholder: simulate transcription after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (_isListening) {
        _transcribedText = 'Hello world';
        _words = ['hello', 'world'];
        _confidence = 0.90;
        Logger.info('Simulated transcription: "$_transcribedText"');
        notifyListeners();
      }
    });
  }
  
  /// Tokenize text into words
  List<String> _tokenizeText(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '') // Remove punctuation
        .split(RegExp(r'\s+')) // Split on whitespace
        .where((word) => word.isNotEmpty)
        .toList();
  }
  
  /// Set transcribed text manually (for testing)
  void setTranscribedText(String text) {
    _transcribedText = text;
    _words = _tokenizeText(text);
    Logger.debug('Text set manually: "$text"');
    notifyListeners();
  }
  
  /// Clear transcription
  void clear() {
    _transcribedText = '';
    _words = [];
    _confidence = 0.0;
    Logger.debug('Transcription cleared');
    notifyListeners();
  }
  
  /// Get statistics
  Map<String, dynamic> getStatistics() {
    return {
      'isListening': _isListening,
      'transcribedText': _transcribedText,
      'wordCount': _words.length,
      'confidence': _confidence,
      'latencyMs': _latencyMs,
    };
  }
  
  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
import 'package:flutter_tts/flutter_tts.dart';
import '../../../core/utils/logger.dart';

class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();
  
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isSpeaking = false;
  
  /// Initialize TTS engine
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      Logger.info('Initializing TTS service');
      
      // Set language
      await _flutterTts.setLanguage('en-US');
      
      // Set speech rate (0.0 to 1.0, default 0.5)
      await _flutterTts.setSpeechRate(0.5);
      
      // Set volume (0.0 to 1.0, default 1.0)
      await _flutterTts.setVolume(1.0);
      
      // Set pitch (0.5 to 2.0, default 1.0)
      await _flutterTts.setPitch(1.0);
      
      // Set up handlers
      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
        Logger.debug('TTS started speaking');
      });
      
      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        Logger.debug('TTS completed speaking');
      });
      
      _flutterTts.setErrorHandler((msg) {
        _isSpeaking = false;
        Logger.error('TTS error: $msg');
      });
      
      _isInitialized = true;
      Logger.success('TTS service initialized');
    } catch (e) {
      Logger.error('Failed to initialize TTS', error: e);
      rethrow;
    }
  }
  
  /// Speak the given text
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    if (text.isEmpty) {
      Logger.warning('Cannot speak empty text');
      return;
    }
    
    try {
      Logger.info('Speaking: "$text"');
      await _flutterTts.speak(text);
    } catch (e) {
      Logger.error('Failed to speak text', error: e);
    }
  }
  
  /// Stop speaking
  Future<void> stop() async {
    if (!_isInitialized) return;
    
    try {
      await _flutterTts.stop();
      _isSpeaking = false;
      Logger.debug('TTS stopped');
    } catch (e) {
      Logger.error('Failed to stop TTS', error: e);
    }
  }
  
  /// Pause speaking
  Future<void> pause() async {
    if (!_isInitialized) return;
    
    try {
      await _flutterTts.pause();
      Logger.debug('TTS paused');
    } catch (e) {
      Logger.error('Failed to pause TTS', error: e);
    }
  }
  
  /// Set speech rate (0.0 to 1.0)
  Future<void> setSpeechRate(double rate) async {
    if (!_isInitialized) await initialize();
    
    try {
      await _flutterTts.setSpeechRate(rate.clamp(0.0, 1.0));
      Logger.debug('Speech rate set to $rate');
    } catch (e) {
      Logger.error('Failed to set speech rate', error: e);
    }
  }
  
  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    if (!_isInitialized) await initialize();
    
    try {
      await _flutterTts.setVolume(volume.clamp(0.0, 1.0));
      Logger.debug('Volume set to $volume');
    } catch (e) {
      Logger.error('Failed to set volume', error: e);
    }
  }
  
  /// Set pitch (0.5 to 2.0)
  Future<void> setPitch(double pitch) async {
    if (!_isInitialized) await initialize();
    
    try {
      await _flutterTts.setPitch(pitch.clamp(0.5, 2.0));
      Logger.debug('Pitch set to $pitch');
    } catch (e) {
      Logger.error('Failed to set pitch', error: e);
    }
  }
  
  /// Set language
  Future<void> setLanguage(String language) async {
    if (!_isInitialized) await initialize();
    
    try {
      await _flutterTts.setLanguage(language);
      Logger.debug('Language set to $language');
    } catch (e) {
      Logger.error('Failed to set language', error: e);
    }
  }
  
  /// Get available languages
  Future<List<String>> getLanguages() async {
    if (!_isInitialized) await initialize();
    
    try {
      final languages = await _flutterTts.getLanguages;
      return List<String>.from(languages);
    } catch (e) {
      Logger.error('Failed to get languages', error: e);
      return [];
    }
  }
  
  /// Check if currently speaking
  bool get isSpeaking => _isSpeaking;
  
  /// Check if initialized
  bool get isInitialized => _isInitialized;
  
  /// Dispose TTS engine
  Future<void> dispose() async {
    if (!_isInitialized) return;
    
    try {
      await stop();
      _isInitialized = false;
      Logger.info('TTS service disposed');
    } catch (e) {
      Logger.error('Failed to dispose TTS', error: e);
    }
  }
}
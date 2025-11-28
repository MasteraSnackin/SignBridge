import 'package:flutter/foundation.dart';
import '../../../core/utils/logger.dart';
import '../../../data/repositories/sign_dictionary_repository.dart';

/// Represents a single animation frame or step
class AnimationStep {
  final String type; // 'word' or 'letter'
  final String content; // word or letter
  final String? animationPath; // path to animation file
  final Duration duration;
  
  AnimationStep({
    required this.type,
    required this.content,
    this.animationPath,
    required this.duration,
  });
}

/// Service for managing sign language animation playback
class SignAnimationService extends ChangeNotifier {
  final SignDictionaryRepository _dictionary = SignDictionaryRepository();
  
  bool _isPlaying = false;
  List<AnimationStep> _animationQueue = [];
  int _currentStepIndex = 0;
  String _currentAnimation = '';
  double _progress = 0.0;
  
  // Statistics
  int _wordsDisplayed = 0;
  int _lettersFingerSpelled = 0;
  int _totalAnimations = 0;
  
  // Getters
  bool get isPlaying => _isPlaying;
  List<AnimationStep> get animationQueue => _animationQueue;
  int get currentStepIndex => _currentStepIndex;
  String get currentAnimation => _currentAnimation;
  double get progress => _progress;
  int get wordsDisplayed => _wordsDisplayed;
  int get lettersFingerSpelled => _lettersFingerSpelled;
  int get totalAnimations => _totalAnimations;
  
  /// Initialize the service
  Future<void> initialize() async {
    try {
      Logger.info('Initializing SignAnimationService');
      
      await _dictionary.initialize();
      
      Logger.success('SignAnimationService initialized with ${_dictionary.size} words');
    } catch (e, stackTrace) {
      Logger.error('Failed to initialize SignAnimationService', 
                   error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  /// Play animations for a list of words
  Future<void> playWords(List<String> words) async {
    if (_isPlaying) {
      Logger.warning('Animation already playing, stopping current animation');
      await stop();
    }
    
    try {
      Logger.info('Playing animations for ${words.length} words: ${words.join(", ")}');
      
      await initialize();
      
      // Build animation queue
      _animationQueue = _buildAnimationQueue(words);
      _currentStepIndex = 0;
      _isPlaying = true;
      _progress = 0.0;
      
      notifyListeners();
      
      // Play animations sequentially
      await _playAnimationQueue();
      
      Logger.success('Completed playing ${_animationQueue.length} animation steps');
    } catch (e, stackTrace) {
      Logger.error('Failed to play animations', error: e, stackTrace: stackTrace);
      _isPlaying = false;
      notifyListeners();
      rethrow;
    }
  }
  
  /// Build animation queue from words
  List<AnimationStep> _buildAnimationQueue(List<String> words) {
    final queue = <AnimationStep>[];
    
    for (final word in words) {
      final normalizedWord = word.toLowerCase().trim();
      
      if (_dictionary.hasSign(normalizedWord)) {
        // Word has a sign animation
        queue.add(AnimationStep(
          type: 'word',
          content: normalizedWord,
          animationPath: _dictionary.getAnimationPath(normalizedWord),
          duration: const Duration(milliseconds: 1500), // 1.5s per word
        ));
        Logger.debug('Added word animation: $normalizedWord');
      } else {
        // Fingerspell the word letter by letter
        Logger.debug('Fingerspelling unknown word: $normalizedWord');
        
        for (int i = 0; i < normalizedWord.length; i++) {
          final letter = normalizedWord[i];
          
          // Only fingerspell letters (skip punctuation, spaces, etc.)
          if (RegExp(r'[a-z]').hasMatch(letter)) {
            queue.add(AnimationStep(
              type: 'letter',
              content: letter,
              animationPath: 'assets/signs/letters/$letter.json',
              duration: const Duration(milliseconds: 800), // 0.8s per letter
            ));
          }
        }
      }
      
      // Add pause between words
      queue.add(AnimationStep(
        type: 'pause',
        content: '',
        duration: const Duration(milliseconds: 500), // 0.5s pause
      ));
    }
    
    return queue;
  }
  
  /// Play the animation queue sequentially
  Future<void> _playAnimationQueue() async {
    for (int i = 0; i < _animationQueue.length; i++) {
      if (!_isPlaying) {
        Logger.info('Animation playback stopped');
        break;
      }
      
      _currentStepIndex = i;
      final step = _animationQueue[i];
      
      // Update current animation
      _currentAnimation = step.animationPath ?? '';
      _progress = (i + 1) / _animationQueue.length;
      
      // Update statistics
      if (step.type == 'word') {
        _wordsDisplayed++;
      } else if (step.type == 'letter') {
        _lettersFingerSpelled++;
      }
      _totalAnimations++;
      
      notifyListeners();
      
      Logger.debug('Playing step ${i + 1}/${_animationQueue.length}: ${step.type} "${step.content}"');
      
      // Wait for animation duration
      await Future.delayed(step.duration);
    }
    
    // Animation complete
    _isPlaying = false;
    _currentAnimation = '';
    _progress = 1.0;
    notifyListeners();
  }
  
  /// Stop current animation
  Future<void> stop() async {
    if (!_isPlaying) {
      return;
    }
    
    Logger.info('Stopping animation playback');
    
    _isPlaying = false;
    _currentAnimation = '';
    _progress = 0.0;
    
    notifyListeners();
  }
  
  /// Pause current animation
  void pause() {
    if (!_isPlaying) {
      return;
    }
    
    Logger.info('Pausing animation playback');
    _isPlaying = false;
    notifyListeners();
  }
  
  /// Resume paused animation
  Future<void> resume() async {
    if (_isPlaying || _animationQueue.isEmpty) {
      return;
    }
    
    Logger.info('Resuming animation playback from step ${_currentStepIndex + 1}');
    
    _isPlaying = true;
    notifyListeners();
    
    // Continue from current step
    final remainingSteps = _animationQueue.sublist(_currentStepIndex);
    _animationQueue = remainingSteps;
    _currentStepIndex = 0;
    
    await _playAnimationQueue();
  }
  
  /// Clear animation queue
  void clear() {
    _animationQueue = [];
    _currentStepIndex = 0;
    _currentAnimation = '';
    _progress = 0.0;
    _isPlaying = false;
    
    Logger.debug('Animation queue cleared');
    notifyListeners();
  }
  
  /// Check if a word can be displayed (has animation)
  bool canDisplayWord(String word) {
    return _dictionary.hasSign(word.toLowerCase().trim());
  }
  
  /// Get animation path for a word
  String? getAnimationPath(String word) {
    return _dictionary.getAnimationPath(word.toLowerCase().trim());
  }
  
  /// Get current step
  AnimationStep? getCurrentStep() {
    if (_currentStepIndex >= 0 && _currentStepIndex < _animationQueue.length) {
      return _animationQueue[_currentStepIndex];
    }
    return null;
  }
  
  /// Get statistics
  Map<String, dynamic> getStatistics() {
    return {
      'isPlaying': _isPlaying,
      'queueLength': _animationQueue.length,
      'currentStep': _currentStepIndex + 1,
      'progress': _progress,
      'wordsDisplayed': _wordsDisplayed,
      'lettersFingerSpelled': _lettersFingerSpelled,
      'totalAnimations': _totalAnimations,
      'dictionarySize': _dictionary.size,
    };
  }
  
  /// Reset statistics
  void resetStatistics() {
    _wordsDisplayed = 0;
    _lettersFingerSpelled = 0;
    _totalAnimations = 0;
    Logger.debug('Statistics reset');
  }
  
  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
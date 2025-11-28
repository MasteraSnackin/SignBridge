import 'dart:collection';
import '../../../core/models/recognition_result.dart';
import '../../../core/utils/logger.dart';

class LetterBuffer {
  final int windowSize;
  final Queue<RecognitionResult> _buffer = Queue();
  String? _lastStableLetter;
  
  LetterBuffer({this.windowSize = 5}) {
    Logger.info('LetterBuffer initialized with window size: $windowSize');
  }
  
  /// Add recognition result to buffer
  void add(RecognitionResult result) {
    _buffer.add(result);
    
    // Remove oldest if buffer exceeds window size
    if (_buffer.length > windowSize) {
      _buffer.removeFirst();
    }
  }
  
  /// Get stable letter using majority vote algorithm
  /// Returns null if no stable letter is found
  String? getStableLetter() {
    if (_buffer.length < windowSize) {
      return null; // Not enough data yet
    }
    
    // Count occurrences of each letter
    final counts = <String, int>{};
    final confidences = <String, List<double>>{};
    
    for (final result in _buffer) {
      if (result.isValid) {
        counts[result.letter] = (counts[result.letter] ?? 0) + 1;
        confidences.putIfAbsent(result.letter, () => []).add(result.confidence);
      }
    }
    
    if (counts.isEmpty) {
      return null; // No valid results in buffer
    }
    
    // Find letter with majority vote (>60% of frames)
    final threshold = (windowSize * 0.6).ceil();
    
    for (final entry in counts.entries) {
      if (entry.value >= threshold) {
        final avgConfidence = confidences[entry.key]!.reduce((a, b) => a + b) / 
                             confidences[entry.key]!.length;
        
        // Only return if this is a new stable letter (debounce)
        if (entry.key != _lastStableLetter) {
          _lastStableLetter = entry.key;
          Logger.debug(
            'Stable letter detected: ${entry.key} '
            '(${entry.value}/$windowSize frames, '
            '${(avgConfidence * 100).toStringAsFixed(1)}% avg confidence)'
          );
          return entry.key;
        }
      }
    }
    
    return null; // No stable letter yet
  }
  
  /// Get average confidence for current buffer
  double getAverageConfidence() {
    if (_buffer.isEmpty) return 0.0;
    
    final validResults = _buffer.where((r) => r.isValid).toList();
    if (validResults.isEmpty) return 0.0;
    
    final sum = validResults.fold(0.0, (sum, r) => sum + r.confidence);
    return sum / validResults.length;
  }
  
  /// Get the most common letter in current buffer (even if not stable)
  String? getMostCommonLetter() {
    if (_buffer.isEmpty) return null;
    
    final counts = <String, int>{};
    
    for (final result in _buffer) {
      if (result.isValid) {
        counts[result.letter] = (counts[result.letter] ?? 0) + 1;
      }
    }
    
    if (counts.isEmpty) return null;
    
    // Find letter with highest count
    String? mostCommon;
    int maxCount = 0;
    
    for (final entry in counts.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        mostCommon = entry.key;
      }
    }
    
    return mostCommon;
  }
  
  /// Get confidence for a specific letter in the buffer
  double getLetterConfidence(String letter) {
    final results = _buffer.where((r) => r.letter == letter && r.isValid).toList();
    if (results.isEmpty) return 0.0;
    
    final sum = results.fold(0.0, (sum, r) => sum + r.confidence);
    return sum / results.length;
  }
  
  /// Clear buffer and reset state
  void clear() {
    _buffer.clear();
    _lastStableLetter = null;
    Logger.debug('Buffer cleared');
  }
  
  /// Reset only the last stable letter (allows same letter to be detected again)
  void resetStableLetter() {
    _lastStableLetter = null;
  }
  
  /// Check if buffer is full
  bool get isFull => _buffer.length >= windowSize;
  
  /// Get current buffer size
  int get size => _buffer.length;
  
  /// Get buffer contents (for debugging)
  List<RecognitionResult> get contents => List.unmodifiable(_buffer);
  
  /// Get statistics about current buffer
  Map<String, dynamic> getStatistics() {
    final counts = <String, int>{};
    final confidences = <String, List<double>>{};
    
    for (final result in _buffer) {
      if (result.isValid) {
        counts[result.letter] = (counts[result.letter] ?? 0) + 1;
        confidences.putIfAbsent(result.letter, () => []).add(result.confidence);
      }
    }
    
    return {
      'bufferSize': _buffer.length,
      'windowSize': windowSize,
      'isFull': isFull,
      'validResults': counts.values.fold(0, (sum, count) => sum + count),
      'uniqueLetters': counts.length,
      'letterCounts': counts,
      'averageConfidence': getAverageConfidence(),
      'mostCommon': getMostCommonLetter(),
      'lastStable': _lastStableLetter,
    };
  }
}
import 'package:flutter/services.dart';
import '../utils/logger.dart';

/// Service for providing haptic feedback to users
/// Critical for deaf users who rely on tactile feedback
class HapticFeedbackService {
  /// Recognition successful - medium impact
  static Future<void> onRecognitionSuccess() async {
    try {
      await HapticFeedback.mediumImpact();
      Logger.info('Haptic feedback: Recognition success');
    } catch (e) {
      Logger.error('Failed to provide haptic feedback', error: e);
    }
  }

  /// Recognition failed - double heavy impact
  static Future<void> onRecognitionFailed() async {
    try {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.heavyImpact();
      Logger.info('Haptic feedback: Recognition failed');
    } catch (e) {
      Logger.error('Failed to provide haptic feedback', error: e);
    }
  }

  /// Word completed - light impact
  static Future<void> onWordCompleted() async {
    try {
      await HapticFeedback.lightImpact();
      Logger.info('Haptic feedback: Word completed');
    } catch (e) {
      Logger.error('Failed to provide haptic feedback', error: e);
    }
  }

  /// Sentence completed - double medium impact
  static Future<void> onSentenceCompleted() async {
    try {
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.mediumImpact();
      Logger.info('Haptic feedback: Sentence completed');
    } catch (e) {
      Logger.error('Failed to provide haptic feedback', error: e);
    }
  }

  /// Button press - selection click
  static Future<void> onButtonPress() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      Logger.error('Failed to provide haptic feedback', error: e);
    }
  }

  /// Error occurred - vibration pattern
  static Future<void> onError() async {
    try {
      await HapticFeedback.vibrate();
      Logger.info('Haptic feedback: Error');
    } catch (e) {
      Logger.error('Failed to provide haptic feedback', error: e);
    }
  }

  /// SOS pattern - ... --- ... (short-long-short)
  static Future<void> sosPattern() async {
    try {
      // Short (3 times)
      for (int i = 0; i < 3; i++) {
        await HapticFeedback.lightImpact();
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      await Future.delayed(const Duration(milliseconds: 200));
      
      // Long (3 times)
      for (int i = 0; i < 3; i++) {
        await HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 300));
      }
      
      await Future.delayed(const Duration(milliseconds: 200));
      
      // Short (3 times)
      for (int i = 0; i < 3; i++) {
        await HapticFeedback.lightImpact();
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      Logger.info('Haptic feedback: SOS pattern');
    } catch (e) {
      Logger.error('Failed to provide SOS haptic feedback', error: e);
    }
  }
}
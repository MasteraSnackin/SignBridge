import 'package:flutter/foundation.dart';

class Logger {
  static const String _tag = 'SignBridge';
  
  static void log(String message, {String? tag}) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      final logTag = tag ?? _tag;
      debugPrint('[$timestamp][$logTag] $message');
    }
  }
  
  static void info(String message, {String? tag}) {
    log('ℹ️ INFO: $message', tag: tag);
  }
  
  static void success(String message, {String? tag}) {
    log('✅ SUCCESS: $message', tag: tag);
  }
  
  static void warning(String message, {String? tag}) {
    log('⚠️ WARNING: $message', tag: tag);
  }
  
  static void error(String message, {Object? error, StackTrace? stackTrace, String? tag}) {
    log('❌ ERROR: $message', tag: tag);
    if (error != null) {
      debugPrint('Error details: $error');
    }
    if (stackTrace != null) {
      debugPrint('Stack trace: $stackTrace');
    }
  }
  
  static void debug(String message, {String? tag}) {
    if (kDebugMode) {
      log('🐛 DEBUG: $message', tag: tag);
    }
  }
  
  static void performance(String operation, int milliseconds, {String? tag}) {
    log('⚡ PERFORMANCE: $operation took ${milliseconds}ms', tag: tag);
  }
}
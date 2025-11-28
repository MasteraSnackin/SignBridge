enum TranslationMode {
  signToSpeech,
  speechToSign,
}

enum ProcessingSource {
  local,
  cloud,
  localFallback,
}

enum RecognitionStatus {
  idle,
  processing,
  success,
  error,
}

extension TranslationModeExtension on TranslationMode {
  String get displayName {
    switch (this) {
      case TranslationMode.signToSpeech:
        return 'Sign to Speech';
      case TranslationMode.speechToSign:
        return 'Speech to Sign';
    }
  }
  
  String get description {
    switch (this) {
      case TranslationMode.signToSpeech:
        return 'Use camera to recognize sign language and convert to speech';
      case TranslationMode.speechToSign:
        return 'Speak into microphone and see sign language animations';
    }
  }
}
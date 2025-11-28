# SignBridge - Technical Architecture Document

## Executive Summary

SignBridge is a Flutter Android application providing real-time, fully offline, bidirectional sign language translation using on-device AI via Cactus SDK. This document outlines the complete technical architecture, data flows, and implementation strategy.

---

## System Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     SIGNBRIDGE APP                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────┐  │
│  │              UI LAYER (Presentation)                 │  │
│  │  • HomeScreen (mode selection)                       │  │
│  │  • SignToSpeechScreen (camera + real-time feedback)  │  │
│  │  • SpeechToSignScreen (mic + avatar animation)       │  │
│  │  • SettingsScreen (performance dashboard)            │  │
│  └─────────────────────────────────────────────────────┘  │
│                          ↕                                  │
│  ┌─────────────────────────────────────────────────────┐  │
│  │         BUSINESS LOGIC LAYER (Services)              │  │
│  │  • SignRecognitionService (vision pipeline)          │  │
│  │  • SpeechRecognitionService (audio → text)           │  │
│  │  • SignAnimationService (text → animation)           │  │
│  │  • TTSService (text → speech)                        │  │
│  │  • GestureClassifier (ML inference)                  │  │
│  │  • HybridRouter (optional cloud fallback)            │  │
│  └─────────────────────────────────────────────────────┘  │
│                          ↕                                  │
│  ┌─────────────────────────────────────────────────────┐  │
│  │           DATA LAYER (Models & Repos)                │  │
│  │  • CactusModelService (AI model management)          │  │
│  │  • SignDictionaryRepository (word mappings)          │  │
│  │  • CameraService (frame capture)                     │  │
│  │  • PermissionService (runtime permissions)           │  │
│  │  • ASL Gesture Database (36 reference vectors)       │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                          ↕
┌─────────────────────────────────────────────────────────────┐
│                   CACTUS SDK (AI Engine)                    │
│  • LFM2-VL-450M (vision - hand landmark detection)          │
│  • Qwen3-0.6B (text processing & routing logic)             │
│  • Whisper-Tiny (speech-to-text transcription)              │
└─────────────────────────────────────────────────────────────┘
```

---

## Data Flow Pipelines

### Pipeline 1: Sign Language → Speech

```
┌──────────────┐
│ Camera Frame │ (30 FPS capture)
└──────┬───────┘
       │
       ↓ (Throttle to 10 FPS)
┌──────────────────────┐
│ Image Preprocessing  │
│ • Resize to 224x224  │
│ • Normalize RGB      │
│ • Convert to tensor  │
└──────┬───────────────┘
       │
       ↓
┌─────────────────────────────┐
│ Hand Landmark Detection     │
│ (LFM2-VL-450M)              │
│ • Detect 21 points per hand │
│ • Output: 63D vector        │
│   (21 landmarks × 3 coords) │
└──────┬──────────────────────┘
       │
       ↓
┌─────────────────────────────┐
│ Gesture Classification      │
│ • Cosine similarity match   │
│ • Compare to 36 ASL signs   │
│ • Threshold: 75% confidence │
└──────┬──────────────────────┘
       │
       ↓
┌─────────────────────────────┐
│ Letter Buffering            │
│ • 5-frame stability window  │
│ • Majority vote algorithm   │
│ • Debounce rapid changes    │
└──────┬──────────────────────┘
       │
       ↓
┌─────────────────────────────┐
│ Word Assembly               │
│ • Accumulate letters        │
│ • Space detection (pause)   │
│ • Word completion trigger   │
└──────┬──────────────────────┘
       │
       ↓
┌─────────────────────────────┐
│ Text-to-Speech Output       │
│ (flutter_tts)               │
│ • Speak assembled text      │
│ • Latency target: <500ms    │
└─────────────────────────────┘
```

### Pipeline 2: Speech → Sign Language

```
┌──────────────────┐
│ Microphone Input │
└────────┬─────────┘
         │
         ↓
┌─────────────────────────────┐
│ Audio Preprocessing         │
│ • 16kHz sampling rate       │
│ • Mono channel              │
│ • Noise reduction (optional)│
└────────┬────────────────────┘
         │
         ↓
┌─────────────────────────────┐
│ Speech-to-Text              │
│ (Whisper-Tiny)              │
│ • Real-time transcription   │
│ • Output: text string       │
└────────┬────────────────────┘
         │
         ↓
┌─────────────────────────────┐
│ Text Tokenization           │
│ • Split into words          │
│ • Normalize (lowercase)     │
│ • Remove punctuation        │
└────────┬────────────────────┘
         │
         ↓
┌─────────────────────────────┐
│ Dictionary Lookup           │
│ • Check word → animation    │
│ • 200-500 common words      │
│ • Fallback: fingerspell     │
└────────┬────────────────────┘
         │
         ↓
┌─────────────────────────────┐
│ Animation Playback          │
│ • Lottie/programmatic       │
│ • Sequential display        │
│ • 500ms pause between words │
└─────────────────────────────┘
```

---

## Core Components Specification

### 1. CactusModelService (Singleton)

**Purpose**: Centralized AI model management

**Responsibilities**:
- Download models on first launch (with progress indicator)
- Initialize all 3 models (LFM2-VL, Qwen3, Whisper)
- Configure GPU acceleration
- Provide global access to model instances
- Handle model lifecycle (load/unload)

**Key Methods**:
```dart
class CactusModelService {
  static final CactusModelService _instance = CactusModelService._internal();
  factory CactusModelService() => _instance;
  
  Future<void> initialize() async;
  Future<bool> areModelsReady() async;
  VisionModel get visionModel;
  TextModel get textModel;
  AudioModel get audioModel;
  Future<void> dispose();
}
```

**Implementation Notes**:
- Use SharedPreferences to track model download status
- Implement retry logic for failed downloads
- Show download progress in UI (MB downloaded / total MB)
- Estimated total size: ~800MB-1GB for all models

---

### 2. SignRecognitionService (State Management)

**Purpose**: Real-time sign language recognition from camera

**State Properties**:
```dart
class SignRecognitionState {
  bool isProcessing;
  String currentLetter;
  double confidence;
  String assembledText;
  List<HandLandmark> landmarks;
  int fps;
  int latencyMs;
}
```

**Key Methods**:
```dart
class SignRecognitionService extends ChangeNotifier {
  Future<void> startRecognition();
  Future<void> stopRecognition();
  void _processFrame(CameraImage image);
  void _classifyGesture(List<double> landmarks);
  void _bufferLetter(String letter, double confidence);
  void _assembleWord();
  void clearText();
}
```

**Processing Flow**:
1. Capture frame from camera (30 FPS)
2. Throttle to 10 FPS for processing
3. Preprocess image (resize, normalize)
4. Call LFM2-VL for landmark detection
5. Extract 63D vector (21 points × 3 coords)
6. Pass to GestureClassifier
7. Buffer result in 5-frame window
8. Update UI with recognized letter
9. Assemble into words on pause detection

**Performance Optimizations**:
- Frame skipping (process every 3rd frame)
- Async processing with isolates
- GPU delegation for model inference
- Landmark caching for repeated gestures

---

### 3. GestureClassifier (Algorithm)

**Purpose**: Match detected landmarks to ASL alphabet/numbers

**ASL Gesture Database Structure**:
```dart
class ASLGesture {
  final String label;           // 'A', 'B', ..., 'Z', '0', ..., '9'
  final List<double> landmarks; // 63D normalized vector
  final String description;     // Human-readable description
}
```

**Classification Algorithm**:
```dart
class GestureClassifier {
  final List<ASLGesture> _database = []; // 36 reference gestures
  
  RecognitionResult classify(List<double> inputLandmarks) {
    // 1. Normalize input vector
    final normalized = _normalize(inputLandmarks);
    
    // 2. Calculate cosine similarity with all database entries
    double maxSimilarity = 0.0;
    String bestMatch = '';
    
    for (final gesture in _database) {
      final similarity = _cosineSimilarity(normalized, gesture.landmarks);
      if (similarity > maxSimilarity) {
        maxSimilarity = similarity;
        bestMatch = gesture.label;
      }
    }
    
    // 3. Return match if confidence > 75%
    if (maxSimilarity > 0.75) {
      return RecognitionResult(
        letter: bestMatch,
        confidence: maxSimilarity,
        timestamp: DateTime.now(),
      );
    }
    
    return RecognitionResult.unknown();
  }
  
  double _cosineSimilarity(List<double> a, List<double> b) {
    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;
    
    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    
    return dotProduct / (sqrt(normA) * sqrt(normB));
  }
  
  List<double> _normalize(List<double> landmarks) {
    // Normalize to unit vector
    final norm = sqrt(landmarks.fold(0.0, (sum, val) => sum + val * val));
    return landmarks.map((val) => val / norm).toList();
  }
}
```

**Database Creation Strategy**:
Since we don't have pre-recorded ASL gestures, we'll use:
1. **Synthetic data generation**: Create reference vectors based on ASL hand shape descriptions
2. **Calibration mode**: Allow users to record their own gestures for personalization
3. **Open dataset**: Use MediaPipe ASL dataset if available

---

### 4. SpeechRecognitionService (State Management)

**Purpose**: Convert speech to text using Whisper

**State Properties**:
```dart
class SpeechRecognitionState {
  bool isListening;
  String transcribedText;
  List<String> words;
  double confidence;
  int latencyMs;
}
```

**Key Methods**:
```dart
class SpeechRecognitionService extends ChangeNotifier {
  Future<void> startListening();
  Future<void> stopListening();
  void _processAudio(List<int> audioData);
  List<String> _tokenizeText(String text);
}
```

**Implementation Notes**:
- Use streaming audio capture (16kHz, mono)
- Process in chunks (1-2 second windows)
- Real-time transcription display
- Word-by-word output for animation triggering

---

### 5. SignAnimationService (State Management)

**Purpose**: Display sign language animations for words

**Animation Strategy** (since we don't have pre-made assets):

**Option A: Programmatic Avatar (Recommended for MVP)**
```dart
class SignAvatar extends StatelessWidget {
  // Simple stick figure that animates hand positions
  // Use CustomPainter to draw:
  // - Body outline
  // - Arms/hands that move to positions
  // - Fingerspelling animations (letter-by-letter)
}
```

**Option B: Lottie JSON Generation**
- Create basic Lottie animations programmatically
- 26 letter animations (fingerspelling)
- 10 number animations
- 50-100 common word animations (simplified)

**Option C: Static Image Sequence**
- Use ASL alphabet chart images
- Display letter-by-letter with transitions
- Simpler but less engaging

**Recommended Approach for Hackathon**:
Start with **Option A** (programmatic avatar) for fingerspelling, then add Option B for common words if time permits.

**Key Methods**:
```dart
class SignAnimationService extends ChangeNotifier {
  Future<void> displayWord(String word);
  Future<void> fingerspellWord(String word);
  void _playAnimation(String animationPath);
  bool _hasAnimation(String word);
}
```

**Dictionary Structure**:
```dart
class SignDictionary {
  final Map<String, String> wordToAnimation = {
    'hello': 'assets/animations/hello.json',
    'thank': 'assets/animations/thank.json',
    'you': 'assets/animations/you.json',
    // ... 200-500 common words
  };
  
  String? getAnimation(String word) => wordToAnimation[word.toLowerCase()];
}
```

---

### 6. Letter Buffering Algorithm

**Purpose**: Stabilize gesture recognition (reduce jitter)

**Implementation**:
```dart
class LetterBuffer {
  final int windowSize = 5;
  final Queue<RecognitionResult> _buffer = Queue();
  
  String? getStableLetter() {
    if (_buffer.length < windowSize) return null;
    
    // Count occurrences of each letter
    final counts = <String, int>{};
    for (final result in _buffer) {
      counts[result.letter] = (counts[result.letter] ?? 0) + 1;
    }
    
    // Return letter with majority vote (>60% of frames)
    final threshold = (windowSize * 0.6).ceil();
    for (final entry in counts.entries) {
      if (entry.value >= threshold) {
        return entry.key;
      }
    }
    
    return null; // No stable letter yet
  }
  
  void add(RecognitionResult result) {
    _buffer.add(result);
    if (_buffer.length > windowSize) {
      _buffer.removeFirst();
    }
  }
  
  void clear() => _buffer.clear();
}
```

---

## Data Models

### Core Models

```dart
// Hand landmark representation
class HandLandmarks {
  final List<Point3D> points; // 21 landmarks
  final double confidence;
  final DateTime timestamp;
  
  HandLandmarks({
    required this.points,
    required this.confidence,
    required this.timestamp,
  });
  
  List<double> toVector() {
    // Flatten to 63D vector (21 × 3)
    return points.expand((p) => [p.x, p.y, p.z]).toList();
  }
}

class Point3D {
  final double x;
  final double y;
  final double z;
  
  Point3D(this.x, this.y, this.z);
}

// Recognition result
class RecognitionResult {
  final String letter;
  final double confidence;
  final DateTime timestamp;
  final ProcessingSource source;
  final int latencyMs;
  
  RecognitionResult({
    required this.letter,
    required this.confidence,
    required this.timestamp,
    this.source = ProcessingSource.local,
    this.latencyMs = 0,
  });
  
  factory RecognitionResult.unknown() {
    return RecognitionResult(
      letter: '',
      confidence: 0.0,
      timestamp: DateTime.now(),
    );
  }
}

// Enums
enum TranslationMode {
  signToSpeech,
  speechToSign,
}

enum ProcessingSource {
  local,
  cloud,
  localFallback,
}

// Sign gesture database entry
class SignGesture {
  final String label;
  final List<double> landmarks;
  final String description;
  final String category; // 'letter', 'number', 'word'
  
  SignGesture({
    required this.label,
    required this.landmarks,
    required this.description,
    required this.category,
  });
}
```

---

## Directory Structure

```
signbridge/
├── android/
│   ├── app/
│   │   ├── src/main/
│   │   │   ├── AndroidManifest.xml
│   │   │   └── res/
│   │   └── build.gradle
│   └── build.gradle
├── assets/
│   ├── animations/          # Lottie JSON files (if used)
│   │   ├── letters/
│   │   │   ├── a.json
│   │   │   ├── b.json
│   │   │   └── ...
│   │   └── words/
│   │       ├── hello.json
│   │       ├── thank.json
│   │       └── ...
│   └── images/              # Static images (fallback)
│       └── asl_alphabet.png
├── lib/
│   ├── main.dart
│   ├── config/
│   │   ├── app_config.dart
│   │   ├── permissions_config.dart
│   │   └── theme_config.dart
│   ├── core/
│   │   ├── models/
│   │   │   ├── hand_landmarks.dart
│   │   │   ├── sign_gesture.dart
│   │   │   ├── recognition_result.dart
│   │   │   └── enums.dart
│   │   ├── services/
│   │   │   ├── cactus_model_service.dart
│   │   │   ├── camera_service.dart
│   │   │   └── permission_service.dart
│   │   └── utils/
│   │       ├── logger.dart
│   │       ├── performance_monitor.dart
│   │       └── math_utils.dart
│   ├── features/
│   │   ├── sign_recognition/
│   │   │   ├── services/
│   │   │   │   └── sign_recognition_service.dart
│   │   │   ├── models/
│   │   │   │   ├── gesture_classifier.dart
│   │   │   │   ├── letter_buffer.dart
│   │   │   │   └── asl_database.dart
│   │   │   └── widgets/
│   │   │       ├── camera_preview_widget.dart
│   │   │       └── recognition_overlay.dart
│   │   ├── speech_recognition/
│   │   │   ├── services/
│   │   │   │   └── speech_recognition_service.dart
│   │   │   └── models/
│   │   │       └── word_mapper.dart
│   │   ├── sign_animation/
│   │   │   ├── services/
│   │   │   │   └── sign_animation_service.dart
│   │   │   ├── widgets/
│   │   │   │   ├── sign_avatar.dart
│   │   │   │   └── animation_player.dart
│   │   │   └── models/
│   │   │       └── sign_dictionary.dart
│   │   ├── text_to_speech/
│   │   │   └── services/
│   │   │       └── tts_service.dart
│   │   └── hybrid_routing/
│   │       ├── services/
│   │       │   ├── hybrid_router.dart
│   │       │   └── confidence_scorer.dart
│   │       └── models/
│   │           └── routing_metrics.dart
│   ├── ui/
│   │   ├── screens/
│   │   │   ├── home_screen.dart
│   │   │   ├── sign_to_speech_screen.dart
│   │   │   ├── speech_to_sign_screen.dart
│   │   │   └── settings_screen.dart
│   │   ├── widgets/
│   │   │   ├── mode_selector.dart
│   │   │   ├── confidence_indicator.dart
│   │   │   ├── fps_counter.dart
│   │   │   └── latency_display.dart
│   │   └── theme/
│   │       └── app_theme.dart
│   └── data/
│       └── repositories/
│           ├── sign_dictionary_repository.dart
│           └── model_cache_repository.dart
├── test/
│   ├── unit/
│   ├── widget/
│   └── integration/
├── pubspec.yaml
└── README.md
```

---

## Android Configuration

### AndroidManifest.xml

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Required permissions -->
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.INTERNET" />
    
    <!-- Camera features -->
    <uses-feature android:name="android.hardware.camera" android:required="true" />
    <uses-feature android:name="android.hardware.camera.autofocus" android:required="false" />
    
    <application
        android:label="SignBridge"
        android:icon="@mipmap/ic_launcher"
        android:usesCleartextTraffic="true">
        
        <activity
            android:name=".MainActivity"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|locale|layoutDirection"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
    </application>
</manifest>
```

### build.gradle (app level)

```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        applicationId "com.signbridge.app"
        minSdkVersion 24
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
        
        // Prevent model compression
        aaptOptions {
            noCompress 'tflite'
            noCompress 'onnx'
        }
        
        // Enable GPU acceleration
        ndk {
            abiFilters 'armeabi-v7a', 'arm64-v8a', 'x86', 'x86_64'
        }
    }
    
    buildTypes {
        release {
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
    
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
}
```

### pubspec.yaml

```yaml
name: signbridge
description: Real-time offline sign language translation app
version: 1.0.0+1

environment:
  sdk: ">=3.0.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  
  # AI/ML
  cactus: ^1.0.0  # Cactus SDK for AI models
  
  # Camera & Media
  camera: ^0.10.5
  image: ^4.0.17
  
  # Audio
  flutter_tts: ^3.8.3
  speech_to_text: ^6.3.0  # Fallback if Whisper needs wrapper
  
  # Animations
  lottie: ^2.7.0
  
  # State Management
  provider: ^6.1.1
  
  # Permissions
  permission_handler: ^11.0.1
  
  # Storage
  shared_preferences: ^2.2.2
  path_provider: ^2.1.1
  
  # Utilities
  http: ^1.1.0  # For hybrid mode cloud calls
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
  
  assets:
    - assets/animations/
    - assets/images/
```

---

## Performance Optimization Strategy

### Target Metrics
- **Latency**: <500ms from gesture to audio output
- **Frame Rate**: 10 FPS camera processing
- **Accuracy**: >90% for ASL alphabet recognition
- **Battery**: Optimize with GPU delegation, frame throttling
- **APK Size**: ~1-1.2GB (includes models + animations)
- **Memory**: <2GB RAM usage during operation

### Optimization Techniques

1. **Frame Processing**
   - Throttle camera capture to 10 FPS
   - Use isolates for parallel processing
   - Skip frames during high load

2. **Model Inference**
   - Enable GPU acceleration via Cactus SDK
   - Batch processing where possible
   - Model quantization (if supported)

3. **Memory Management**
   - Lazy load animations
   - Clear buffers after word completion
   - Dispose camera controller when not in use

4. **Battery Optimization**
   - Reduce frame rate when idle
   - Pause processing when app in background
   - Use efficient image preprocessing

---

## Implementation Phases

### Phase 1: Foundation (8 hours)
**Goal**: Project setup and core infrastructure

- [ ] Create Flutter project structure
- [ ] Configure Android manifest and build.gradle
- [ ] Add all dependencies to pubspec.yaml
- [ ] Implement PermissionService
- [ ] Create core data models
- [ ] Implement CactusModelService skeleton
- [ ] Build basic UI navigation (HomeScreen)
- [ ] Test model download and initialization

**Deliverable**: App launches, requests permissions, downloads models

---

### Phase 2: Sign-to-Speech Pipeline (8 hours)
**Goal**: Complete vision → audio translation

- [ ] Implement CameraService
- [ ] Build SignRecognitionService
- [ ] Create ASL gesture database (36 signs)
- [ ] Implement GestureClassifier with cosine similarity
- [ ] Add letter buffering logic
- [ ] Implement TTSService
- [ ] Build SignToSpeechScreen UI
- [ ] Add real-time feedback (confidence, FPS, latency)
- [ ] Test complete pipeline

**Deliverable**: User can sign letters, app speaks them

---

### Phase 3: Speech-to-Sign Pipeline (4 hours)
**Goal**: Complete audio → animation translation

- [ ] Implement SpeechRecognitionService
- [ ] Create SignAnimationService
- [ ] Build programmatic SignAvatar widget
- [ ] Implement fingerspelling animations
- [ ] Create SignDictionaryRepository
- [ ] Build SpeechToSignScreen UI
- [ ] Test complete pipeline

**Deliverable**: User can speak, app displays signs

---

### Phase 4: Polish & Testing (3 hours)
**Goal**: UI improvements and bug fixes

- [ ] Implement SettingsScreen with metrics
- [ ] Add confidence indicators
- [ ] Implement performance monitoring
- [ ] Create app theme
- [ ] Test on emulator thoroughly
- [ ] Fix bugs and edge cases
- [ ] Optimize performance

**Deliverable**: Polished, stable app

---

### Phase 5: Bonus Features (1 hour)
**Goal**: Optional enhancements

- [ ] Implement HybridRouter for cloud fallback
- [ ] Add privacy dashboard
- [ ] Create demo video
- [ ] Write comprehensive README

**Deliverable**: Complete hackathon submission

---

## Testing Strategy

### Unit Tests
- GestureClassifier cosine similarity
- Letter buffering algorithm
- Word tokenization
- Confidence scoring

### Integration Tests
- Camera → landmark detection → classification
- Speech → transcription → animation
- End-to-end pipelines

### Manual Testing Checklist
- [ ] Permissions granted correctly
- [ ] Models download successfully
- [ ] Camera preview displays
- [ ] Gestures recognized accurately
- [ ] TTS speaks correctly
- [ ] Speech transcription works
- [ ] Animations display smoothly
- [ ] App handles errors gracefully
- [ ] Performance meets targets
- [ ] Battery usage acceptable

---

## Risk Mitigation

### Technical Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| Cactus SDK integration issues | High | Review documentation early, test model loading first |
| Poor gesture recognition accuracy | High | Use calibration mode, allow user training |
| High latency (>500ms) | Medium | Optimize frame rate, use GPU acceleration |
| Large APK size (>1.5GB) | Medium | Model compression, lazy loading |
| Animation assets missing | Medium | Use programmatic avatar as fallback |
| Emulator performance issues | Low | Test on physical device if available |

### Timeline Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| Cactus SDK learning curve | High | Allocate 2 hours for documentation review |
| Animation creation time | Medium | Use simple programmatic approach |
| Debugging time overrun | Medium | Implement logging early, test incrementally |
| Feature creep | Low | Stick to MVP, defer bonus features |

---

## Success Criteria

### Functional Requirements
✅ Recognizes 26 ASL letters + 10 numbers  
✅ Real-time sign-to-speech (<500ms)  
✅ Real-time speech-to-sign display  
✅ Works completely offline  
✅ Bidirectional conversation flow  

### Technical Requirements
✅ Uses Cactus SDK (LFM2-VL, Qwen3, Whisper)  
✅ Flutter Android APK  
✅ Clean architecture, testable code  
✅ Runs on standard Android devices (minSdk 24)  

### Deliverables
✅ Installable .apk file  
✅ Demo video showing both directions  
✅ README with setup instructions  

---

## Next Steps

1. **Review Cactus SDK documentation** (Notion link provided)
2. **Set up Flutter project** with proper structure
3. **Implement Phase 1** (foundation)
4. **Test model integration** early
5. **Build incrementally**, testing each component
6. **Switch to Code mode** when ready to implement

---

## Additional Resources

- Cactus SDK: https://www.notion.so/Cactus-Hackathon-Quickstart-2afd8e920c9780379d62ef0cc0d11e30
- ASL Alphabet Reference: [MediaPipe Hands](https://developers.google.com/mediapipe/solutions/vision/hand_landmarker)
- Flutter Camera Plugin: https://pub.dev/packages/camera
- Lottie Animations: https://pub.dev/packages/lottie

---

**Document Version**: 1.0  
**Last Updated**: 2025-11-27  
**Author**: Kilo Code (Architect Mode)
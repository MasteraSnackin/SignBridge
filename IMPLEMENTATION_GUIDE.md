# SignBridge - Implementation Guide

This document provides detailed code templates, algorithms, and step-by-step implementation instructions for building SignBridge.

---

## Table of Contents

1. [Project Setup](#project-setup)
2. [Core Data Models](#core-data-models)
3. [Cactus SDK Integration](#cactus-sdk-integration)
4. [Sign Recognition Pipeline](#sign-recognition-pipeline)
5. [Speech Recognition Pipeline](#speech-recognition-pipeline)
6. [Animation System](#animation-system)
7. [UI Implementation](#ui-implementation)
8. [Performance Optimization](#performance-optimization)

---

## 1. Project Setup

### Step 1.1: Create Flutter Project

```bash
flutter create signbridge
cd signbridge
```

### Step 1.2: Update pubspec.yaml

```yaml
name: signbridge
description: Real-time offline sign language translation app
version: 1.0.0+1

environment:
  sdk: ">=3.0.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  
  # AI/ML - Replace with actual Cactus SDK package
  # cactus: ^1.0.0
  
  # Camera & Media
  camera: ^0.10.5
  image: ^4.0.17
  
  # Audio
  flutter_tts: ^3.8.3
  
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
  http: ^1.1.0

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

### Step 1.3: Create Directory Structure

```bash
mkdir -p lib/config
mkdir -p lib/core/models
mkdir -p lib/core/services
mkdir -p lib/core/utils
mkdir -p lib/features/sign_recognition/services
mkdir -p lib/features/sign_recognition/models
mkdir -p lib/features/sign_recognition/widgets
mkdir -p lib/features/speech_recognition/services
mkdir -p lib/features/speech_recognition/models
mkdir -p lib/features/sign_animation/services
mkdir -p lib/features/sign_animation/widgets
mkdir -p lib/features/sign_animation/models
mkdir -p lib/features/text_to_speech/services
mkdir -p lib/features/hybrid_routing/services
mkdir -p lib/features/hybrid_routing/models
mkdir -p lib/ui/screens
mkdir -p lib/ui/widgets
mkdir -p lib/ui/theme
mkdir -p lib/data/repositories
mkdir -p assets/animations
mkdir -p assets/images
```

---

## 2. Core Data Models

### 2.1: Point3D Model

**File**: `lib/core/models/point_3d.dart`

```dart
class Point3D {
  final double x;
  final double y;
  final double z;
  
  const Point3D(this.x, this.y, this.z);
  
  Point3D operator +(Point3D other) {
    return Point3D(x + other.x, y + other.y, z + other.z);
  }
  
  Point3D operator -(Point3D other) {
    return Point3D(x - other.x, y - other.y, z - other.z);
  }
  
  Point3D operator *(double scalar) {
    return Point3D(x * scalar, y * scalar, z * scalar);
  }
  
  double distanceTo(Point3D other) {
    final dx = x - other.x;
    final dy = y - other.y;
    final dz = z - other.z;
    return sqrt(dx * dx + dy * dy + dz * dz);
  }
  
  Map<String, dynamic> toJson() => {
    'x': x,
    'y': y,
    'z': z,
  };
  
  factory Point3D.fromJson(Map<String, dynamic> json) {
    return Point3D(
      json['x'] as double,
      json['y'] as double,
      json['z'] as double,
    );
  }
  
  @override
  String toString() => 'Point3D($x, $y, $z)';
}
```

### 2.2: Hand Landmarks Model

**File**: `lib/core/models/hand_landmarks.dart`

```dart
import 'point_3d.dart';

class HandLandmarks {
  final List<Point3D> points; // 21 landmarks
  final double confidence;
  final DateTime timestamp;
  
  HandLandmarks({
    required this.points,
    required this.confidence,
    required this.timestamp,
  }) : assert(points.length == 21, 'Must have exactly 21 landmarks');
  
  /// Convert to 63-dimensional vector (21 points × 3 coordinates)
  List<double> toVector() {
    return points.expand((p) => [p.x, p.y, p.z]).toList();
  }
  
  /// Normalize landmarks relative to wrist (point 0)
  HandLandmarks normalize() {
    if (points.isEmpty) return this;
    
    final wrist = points[0];
    final normalizedPoints = points.map((p) => p - wrist).toList();
    
    return HandLandmarks(
      points: normalizedPoints,
      confidence: confidence,
      timestamp: timestamp,
    );
  }
  
  /// Calculate bounding box
  Map<String, double> getBoundingBox() {
    if (points.isEmpty) {
      return {'minX': 0, 'minY': 0, 'maxX': 0, 'maxY': 0};
    }
    
    double minX = points[0].x;
    double minY = points[0].y;
    double maxX = points[0].x;
    double maxY = points[0].y;
    
    for (final point in points) {
      if (point.x < minX) minX = point.x;
      if (point.y < minY) minY = point.y;
      if (point.x > maxX) maxX = point.x;
      if (point.y > maxY) maxY = point.y;
    }
    
    return {
      'minX': minX,
      'minY': minY,
      'maxX': maxX,
      'maxY': maxY,
      'width': maxX - minX,
      'height': maxY - minY,
    };
  }
  
  Map<String, dynamic> toJson() => {
    'points': points.map((p) => p.toJson()).toList(),
    'confidence': confidence,
    'timestamp': timestamp.toIso8601String(),
  };
  
  factory HandLandmarks.fromJson(Map<String, dynamic> json) {
    return HandLandmarks(
      points: (json['points'] as List)
          .map((p) => Point3D.fromJson(p as Map<String, dynamic>))
          .toList(),
      confidence: json['confidence'] as double,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
```

### 2.3: Enums

**File**: `lib/core/models/enums.dart`

```dart
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
```

### 2.4: Recognition Result Model

**File**: `lib/core/models/recognition_result.dart`

```dart
import 'enums.dart';

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
  
  bool get isValid => letter.isNotEmpty && confidence > 0.75;
  
  Map<String, dynamic> toJson() => {
    'letter': letter,
    'confidence': confidence,
    'timestamp': timestamp.toIso8601String(),
    'source': source.toString(),
    'latencyMs': latencyMs,
  };
  
  factory RecognitionResult.fromJson(Map<String, dynamic> json) {
    return RecognitionResult(
      letter: json['letter'] as String,
      confidence: json['confidence'] as double,
      timestamp: DateTime.parse(json['timestamp'] as String),
      source: ProcessingSource.values.firstWhere(
        (e) => e.toString() == json['source'],
        orElse: () => ProcessingSource.local,
      ),
      latencyMs: json['latencyMs'] as int? ?? 0,
    );
  }
  
  @override
  String toString() => 'RecognitionResult($letter, ${(confidence * 100).toStringAsFixed(1)}%)';
}
```

### 2.5: Sign Gesture Model

**File**: `lib/core/models/sign_gesture.dart`

```dart
class SignGesture {
  final String label;
  final List<double> landmarks; // 63D normalized vector
  final String description;
  final String category; // 'letter', 'number', 'word'
  
  SignGesture({
    required this.label,
    required this.landmarks,
    required this.description,
    required this.category,
  }) : assert(landmarks.length == 63, 'Landmarks must be 63-dimensional');
  
  Map<String, dynamic> toJson() => {
    'label': label,
    'landmarks': landmarks,
    'description': description,
    'category': category,
  };
  
  factory SignGesture.fromJson(Map<String, dynamic> json) {
    return SignGesture(
      label: json['label'] as String,
      landmarks: (json['landmarks'] as List).cast<double>(),
      description: json['description'] as String,
      category: json['category'] as String,
    );
  }
}
```

---

## 3. Cactus SDK Integration

### 3.1: Cactus Model Service

**File**: `lib/core/services/cactus_model_service.dart`

```dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:cactus/cactus.dart'; // Replace with actual import

class CactusModelService {
  static final CactusModelService _instance = CactusModelService._internal();
  factory CactusModelService() => _instance;
  CactusModelService._internal();
  
  // Model instances (replace with actual Cactus SDK types)
  dynamic _visionModel;
  dynamic _textModel;
  dynamic _audioModel;
  
  bool _isInitialized = false;
  double _downloadProgress = 0.0;
  
  // Getters
  dynamic get visionModel => _visionModel;
  dynamic get textModel => _textModel;
  dynamic get audioModel => _audioModel;
  bool get isInitialized => _isInitialized;
  double get downloadProgress => _downloadProgress;
  
  /// Initialize all AI models
  Future<void> initialize({
    Function(double)? onProgress,
  }) async {
    if (_isInitialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final modelsDownloaded = prefs.getBool('models_downloaded') ?? false;
      
      if (!modelsDownloaded) {
        await _downloadModels(onProgress);
        await prefs.setBool('models_downloaded', true);
      }
      
      // Initialize models
      await _initializeVisionModel();
      await _initializeTextModel();
      await _initializeAudioModel();
      
      _isInitialized = true;
      debugPrint('✅ All Cactus models initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing Cactus models: $e');
      rethrow;
    }
  }
  
  Future<void> _downloadModels(Function(double)? onProgress) async {
    debugPrint('📥 Downloading AI models...');
    
    // TODO: Implement actual model download using Cactus SDK
    // This is a placeholder implementation
    
    final models = [
      {'name': 'LFM2-VL-450M', 'size': 450},
      {'name': 'Qwen3-0.6B', 'size': 600},
      {'name': 'Whisper-Tiny', 'size': 150},
    ];
    
    double totalSize = models.fold(0.0, (sum, m) => sum + (m['size'] as int));
    double downloaded = 0.0;
    
    for (final model in models) {
      debugPrint('Downloading ${model['name']}...');
      
      // Simulate download progress
      final size = model['size'] as int;
      for (int i = 0; i <= 10; i++) {
        await Future.delayed(const Duration(milliseconds: 100));
        downloaded += size / 10;
        _downloadProgress = downloaded / totalSize;
        onProgress?.call(_downloadProgress);
      }
    }
    
    debugPrint('✅ All models downloaded');
  }
  
  Future<void> _initializeVisionModel() async {
    debugPrint('Initializing LFM2-VL-450M...');
    
    // TODO: Replace with actual Cactus SDK initialization
    // _visionModel = await CactusVision.load(
    //   modelPath: 'models/lfm2-vl-450m',
    //   useGpu: true,
    // );
    
    await Future.delayed(const Duration(milliseconds: 500));
    debugPrint('✅ Vision model initialized');
  }
  
  Future<void> _initializeTextModel() async {
    debugPrint('Initializing Qwen3-0.6B...');
    
    // TODO: Replace with actual Cactus SDK initialization
    // _textModel = await CactusText.load(
    //   modelPath: 'models/qwen3-0.6b',
    //   useGpu: true,
    // );
    
    await Future.delayed(const Duration(milliseconds: 500));
    debugPrint('✅ Text model initialized');
  }
  
  Future<void> _initializeAudioModel() async {
    debugPrint('Initializing Whisper-Tiny...');
    
    // TODO: Replace with actual Cactus SDK initialization
    // _audioModel = await CactusAudio.load(
    //   modelPath: 'models/whisper-tiny',
    //   useGpu: true,
    // );
    
    await Future.delayed(const Duration(milliseconds: 500));
    debugPrint('✅ Audio model initialized');
  }
  
  /// Check if models are ready
  Future<bool> areModelsReady() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('models_downloaded') ?? false;
  }
  
  /// Dispose all models
  Future<void> dispose() async {
    // TODO: Implement actual disposal
    // _visionModel?.dispose();
    // _textModel?.dispose();
    // _audioModel?.dispose();
    
    _isInitialized = false;
    debugPrint('🗑️ Cactus models disposed');
  }
}
```

---

## 4. Sign Recognition Pipeline

### 4.1: Gesture Classifier

**File**: `lib/features/sign_recognition/models/gesture_classifier.dart`

```dart
import 'dart:math';
import '../../../core/models/sign_gesture.dart';
import '../../../core/models/recognition_result.dart';

class GestureClassifier {
  final List<SignGesture> _database = [];
  
  GestureClassifier() {
    _initializeDatabase();
  }
  
  /// Initialize ASL gesture database
  void _initializeDatabase() {
    // TODO: Load actual ASL gesture data
    // For now, create placeholder data
    
    // Letters A-Z
    for (int i = 0; i < 26; i++) {
      final letter = String.fromCharCode(65 + i); // A-Z
      _database.add(SignGesture(
        label: letter,
        landmarks: _generatePlaceholderLandmarks(i),
        description: 'ASL letter $letter',
        category: 'letter',
      ));
    }
    
    // Numbers 0-9
    for (int i = 0; i < 10; i++) {
      _database.add(SignGesture(
        label: i.toString(),
        landmarks: _generatePlaceholderLandmarks(26 + i),
        description: 'ASL number $i',
        category: 'number',
      ));
    }
  }
  
  /// Generate placeholder landmarks (replace with real data)
  List<double> _generatePlaceholderLandmarks(int seed) {
    final random = Random(seed);
    return List.generate(63, (_) => random.nextDouble());
  }
  
  /// Classify gesture using cosine similarity
  RecognitionResult classify(List<double> inputLandmarks) {
    if (inputLandmarks.length != 63) {
      return RecognitionResult.unknown();
    }
    
    final startTime = DateTime.now();
    
    // Normalize input vector
    final normalized = _normalize(inputLandmarks);
    
    // Find best match
    double maxSimilarity = 0.0;
    String bestMatch = '';
    
    for (final gesture in _database) {
      final similarity = _cosineSimilarity(normalized, gesture.landmarks);
      if (similarity > maxSimilarity) {
        maxSimilarity = similarity;
        bestMatch = gesture.label;
      }
    }
    
    final latency = DateTime.now().difference(startTime).inMilliseconds;
    
    // Return match if confidence > 75%
    if (maxSimilarity > 0.75) {
      return RecognitionResult(
        letter: bestMatch,
        confidence: maxSimilarity,
        timestamp: DateTime.now(),
        latencyMs: latency,
      );
    }
    
    return RecognitionResult.unknown();
  }
  
  /// Calculate cosine similarity between two vectors
  double _cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length) return 0.0;
    
    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;
    
    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    
    if (normA == 0.0 || normB == 0.0) return 0.0;
    
    return dotProduct / (sqrt(normA) * sqrt(normB));
  }
  
  /// Normalize vector to unit length
  List<double> _normalize(List<double> vector) {
    final norm = sqrt(vector.fold(0.0, (sum, val) => sum + val * val));
    if (norm == 0.0) return vector;
    return vector.map((val) => val / norm).toList();
  }
  
  /// Get all gestures in database
  List<SignGesture> get allGestures => List.unmodifiable(_database);
  
  /// Get gestures by category
  List<SignGesture> getGesturesByCategory(String category) {
    return _database.where((g) => g.category == category).toList();
  }
}
```

### 4.2: Letter Buffer

**File**: `lib/features/sign_recognition/models/letter_buffer.dart`

```dart
import 'dart:collection';
import '../../../core/models/recognition_result.dart';

class LetterBuffer {
  final int windowSize;
  final Queue<RecognitionResult> _buffer = Queue();
  
  LetterBuffer({this.windowSize = 5});
  
  /// Add recognition result to buffer
  void add(RecognitionResult result) {
    _buffer.add(result);
    if (_buffer.length > windowSize) {
      _buffer.removeFirst();
    }
  }
  
  /// Get stable letter using majority vote
  String? getStableLetter() {
    if (_buffer.length < windowSize) return null;
    
    // Count occurrences of each letter
    final counts = <String, int>{};
    for (final result in _buffer) {
      if (result.isValid) {
        counts[result.letter] = (counts[result.letter] ?? 0) + 1;
      }
    }
    
    if (counts.isEmpty) return null;
    
    // Return letter with majority vote (>60% of frames)
    final threshold = (windowSize * 0.6).ceil();
    for (final entry in counts.entries) {
      if (entry.value >= threshold) {
        return entry.key;
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
  
  /// Clear buffer
  void clear() => _buffer.clear();
  
  /// Check if buffer is full
  bool get isFull => _buffer.length >= windowSize;
  
  /// Get current buffer size
  int get size => _buffer.length;
}
```

### 4.3: Sign Recognition Service

**File**: `lib/features/sign_recognition/services/sign_recognition_service.dart`

```dart
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import '../../../core/models/hand_landmarks.dart';
import '../../../core/models/recognition_result.dart';
import '../../../core/services/cactus_model_service.dart';
import '../models/gesture_classifier.dart';
import '../models/letter_buffer.dart';

class SignRecognitionService extends ChangeNotifier {
  final CactusModelService _cactusService = CactusModelService();
  final GestureClassifier _classifier = GestureClassifier();
  final LetterBuffer _buffer = LetterBuffer(windowSize: 5);
  
  CameraController? _cameraController;
  bool _isProcessing = false;
  String _currentLetter = '';
  double _confidence = 0.0;
  String _assembledText = '';
  int _fps = 0;
  int _latencyMs = 0;
  
  // Getters
  bool get isProcessing => _isProcessing;
  String get currentLetter => _currentLetter;
  double get confidence => _confidence;
  String get assembledText => _assembledText;
  int get fps => _fps;
  int get latencyMs => _latencyMs;
  
  /// Start sign recognition
  Future<void> startRecognition(CameraController controller) async {
    _cameraController = controller;
    _isProcessing = true;
    _buffer.clear();
    
    // Start processing frames
    await _cameraController?.startImageStream(_processFrame);
    
    notifyListeners();
  }
  
  /// Stop sign recognition
  Future<void> stopRecognition() async {
    _isProcessing = false;
    await _cameraController?.stopImageStream();
    notifyListeners();
  }
  
  /// Process camera frame
  void _processFrame(CameraImage image) async {
    if (!_isProcessing) return;
    
    try {
      final startTime = DateTime.now();
      
      // TODO: Preprocess image and extract landmarks using Cactus SDK
      // For now, use placeholder
      final landmarks = await _extractLandmarks(image);
      
      if (landmarks != null) {
        // Classify gesture
        final result = _classifier.classify(landmarks.toVector());
        
        // Buffer result
        _buffer.add(result);
        
        // Get stable letter
        final stableLetter = _buffer.getStableLetter();
        if (stableLetter != null && stableLetter != _currentLetter) {
          _currentLetter = stableLetter;
          _confidence = _buffer.getAverageConfidence();
          
          // Add to assembled text
          _assembledText += stableLetter;
          
          notifyListeners();
        }
      }
      
      // Update metrics
      _latencyMs = DateTime.now().difference(startTime).inMilliseconds;
      _fps = (1000 / _latencyMs).round();
      
    } catch (e) {
      debugPrint('Error processing frame: $e');
    }
  }
  
  /// Extract hand landmarks from camera image
  Future<HandLandmarks?> _extractLandmarks(CameraImage image) async {
    // TODO: Implement actual landmark extraction using Cactus SDK
    // This is a placeholder
    
    await Future.delayed(const Duration(milliseconds: 50));
    
    // Return placeholder landmarks
    return HandLandmarks(
      points: List.generate(21, (i) => Point3D(0.0, 0.0, 0.0)),
      confidence: 0.9,
      timestamp: DateTime.now(),
    );
  }
  
  /// Clear assembled text
  void clearText() {
    _assembledText = '';
    _currentLetter = '';
    _confidence = 0.0;
    _buffer.clear();
    notifyListeners();
  }
  
  /// Add space to text
  void addSpace() {
    _assembledText += ' ';
    notifyListeners();
  }
  
  @override
  void dispose() {
    stopRecognition();
    super.dispose();
  }
}
```

---

## 5. Speech Recognition Pipeline

### 5.1: Speech Recognition Service

**File**: `lib/features/speech_recognition/services/speech_recognition_service.dart`

```dart
import 'package:flutter/foundation.dart';
import '../../../core/services/cactus_model_service.dart';

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
  
  /// Start listening for speech
  Future<void> startListening() async {
    _isListening = true;
    _transcribedText = '';
    _words = [];
    
    // TODO: Start audio capture and processing
    
    notifyListeners();
  }
  
  /// Stop listening
  Future<void> stopListening() async {
    _isListening = false;
    notifyListeners();
  }
  
  /// Process audio data
  Future<void> _processAudio(List<int> audioData) async {
    try {
      final startTime = DateTime.now();
      
      // TODO: Use Whisper model from Cactus SDK
      // final result = await _cactusService.audioModel.transcribe(audioData);
      
      // Placeholder implementation
      await Future.delayed(const Duration(milliseconds: 100));
      
      _latencyMs = DateTime.now().difference(startTime).inMilliseconds;
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error processing audio: $e');
    }
  }
  
  /// Tokenize text into words
  List<String> _tokenizeText(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
  }
  
  /// Clear transcription
  void clear() {
    _transcribedText = '';
    _words = [];
    _confidence = 0.0;
    notifyListeners();
  }
}
```

---

## 6. Animation System

### 6.1: Sign Avatar Widget (Programmatic Approach)

**File**: `lib/features/sign_animation/widgets/sign_avatar.dart`

```dart
import 'package:flutter/material.dart';
import 'dart:math';

class SignAvatar extends StatefulWidget {
  final String currentLetter;
  final double size;
  
  const SignAvatar({
    Key? key,
    required this.currentLetter,
    this.size = 300,
  }) : super(key: key);
  
  @override
  State<SignAvatar> createState() => _SignAvatarState();
}

class _SignAvatarState extends State<SignAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }
  
  @override
  void didUpdateWidget(SignAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentLetter != widget.currentLetter) {
      _controller.forward(from: 0.0);
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: SignAvatarPainter(
            letter: widget.currentLetter,
            animationValue: _controller.value,
          ),
        );
      },
    );
  }
}

class SignAvatarPainter extends CustomPainter {
  final String letter;
  final double animationValue;
  
  SignAvatarPainter({
    required this.letter,
    required this.animationValue,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    
    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw body
    _drawBody(canvas, center, paint);
    
    // Draw hands based on letter
    _drawHands(canvas, center, paint);
    
    // Draw letter label
    _drawLabel(canvas, size);
  }
  
  void _drawBody(Canvas canvas, Offset center, Paint paint) {
    // Head
    canvas.drawCircle(
      Offset(center.dx, center.dy - 80),
      20,
      paint,
    );
    
    // Body
    canvas.drawLine(
      Offset(center.dx, center.dy - 60),
      Offset(center.dx, center.dy + 40),
      paint,
    );
  }
  
  void _drawHands(Canvas canvas, Offset center, Paint paint) {
    // Get hand positions based on letter
    final positions = _getHandPositions(letter);
    
    // Left arm
    canvas.drawLine(
      Offset(center.dx, center.dy - 40),
      Offset(center.dx + positions['leftX']!, center.dy + positions['leftY']!),
      paint,
    );
    
    // Right arm
    canvas.drawLine(
      Offset(center.dx, center.dy - 40),
      Offset(center.dx + positions['rightX']!, center.dy + positions['rightY']!),
      paint,
    );
    
    // Hands (circles)
    canvas.drawCircle(
      Offset(center.dx + positions['leftX']!, center.dy + positions['leftY']!),
      8,
      paint..style = PaintingStyle.fill,
    );
    
    canvas.drawCircle(
      Offset(center.dx + positions['rightX']!, center.dy + positions['rightY']!),
      8,
      paint..style = PaintingStyle.fill,
    );
    
    paint.style = PaintingStyle.stroke;
  }
  
  Map<String, double> _getHandPositions(String letter) {
    // Simplified hand positions for each letter
    // TODO: Replace with actual ASL hand positions
    
    final positions = <String, Map<String, double>>{
      'A': {'leftX': -40.0, 'leftY': -20.0, 'rightX': 40.0, 'rightY': -20.0},
      'B': {'leftX': -50.0, 'leftY': -30.0, 'rightX': 50.0, 'rightY': -30.0},
      'C': {'leftX': -45.0, 'leftY': -10.0, 'rightX': 45.0, 'rightY': -10.0},
      // Add more letters...
    };
    
    return positions[letter] ?? {
      'leftX': -40.0,
      'leftY': 0.0,
      'rightX': 40.0,
      'rightY': 0.0,
    };
  }
  
  void _drawLabel(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: letter,
        style: const TextStyle(
          color: Colors.blue,
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        size.height - 60,
      ),
    );
  }
  
  @override
  bool shouldRepaint(SignAvatarPainter oldDelegate) {
    return oldDelegate.letter != letter ||
        oldDelegate.animationValue != animationValue;
  }
}
```

---

## 7. UI Implementation

### 7.1: Home Screen

**File**: `lib/ui/screens/home_screen.dart`

```dart
import 'package:flutter/material.dart';
import '../../core/models/enums.dart';
import 'sign_to_speech_screen.dart';
import 'speech_to_sign_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SignBridge'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Choose Translation Mode',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48),
            _ModeCard(
              mode: TranslationMode.signToSpeech,
              icon: Icons.sign_language,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SignToSpeechScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            _ModeCard(
              mode: TranslationMode.speechToSign,
              icon: Icons.mic,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SpeechToSignScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final TranslationMode mode;
  final IconData icon;
  final VoidCallback onTap;
  
  const _ModeCard({
    required this.mode,
    required this.icon,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(icon, size: 64, color: Theme.of(context).primaryColor),
              const SizedBox(height: 16),
              Text(
                mode.displayName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                mode.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## 8. Performance Optimization

### 8.1: Performance Monitor

**File**: `lib/core/utils/performance_monitor.dart`

```dart
import 'package:flutter/foundation.dart';

class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();
  
  final List<int> _latencies = [];
  final List<int> _fpsSamples = [];
  int _frameCount = 0;
  DateTime? _lastFrameTime;
  
  /// Record frame processing latency
  void recordLatency(int milliseconds) {
    _latencies.add(milliseconds);
    if (_latencies.length > 100) {
      _latencies.removeAt(0);
    }
  }
  
  /// Record frame
  void recordFrame() {
    _frameCount++;
    final now = DateTime.now();
    
    if (_lastFrameTime != null) {
      final delta = now.difference(_lastFrameTime!).inMilliseconds;
      if (delta > 0) {
        final fps = (1000 / delta).round();
        _fpsSamples.add(fps);
        if (_fpsSamples.length > 30) {
          _fpsSamples.removeAt(0);
        }
      }
    }
    
    _lastFrameTime = now;
  }
  
  /// Get average latency
  double get averageLatency {
    if (_latencies.isEmpty) return 0.0;
    return _latencies.reduce((a, b) => a + b) / _latencies.length;
  }
  
  /// Get average FPS
  double get averageFps {
    if (_fpsSamples.isEmpty) return 0.0;
    return _fpsSamples.reduce((a, b) => a + b) / _fpsSamples.length;
  }
  
  /// Get total frames processed
  int get totalFrames => _frameCount;
  
  /// Reset metrics
  void reset() {
    _latencies.clear();
    _fpsSamples.clear();
    _frameCount = 0;
    _lastFrameTime = null;
  }
  
  /// Print performance report
  void printReport() {
    debugPrint('=== Performance Report ===');
    debugPrint('Average Latency: ${averageLatency.toStringAsFixed(2)}ms');
    debugPrint('Average FPS: ${averageFps.toStringAsFixed(2)}');
    debugPrint('Total Frames: $totalFrames');
  }
}
```

---

## Next Steps

1. **Review Cactus SDK Documentation**: Study the actual API and integration patterns
2. **Replace Placeholders**: Update all `TODO` comments with actual Cactus SDK calls
3. **Test Incrementally**: Build and test each component before moving to the next
4. **Optimize Performance**: Profile and optimize based on actual device performance
5. **Add Error Handling**: Implement comprehensive error handling throughout

---

**Ready to implement?** Switch to Code mode to start building!
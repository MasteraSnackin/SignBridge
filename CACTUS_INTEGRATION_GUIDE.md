# Cactus SDK Integration Guide

This guide provides step-by-step instructions for integrating Cactus SDK into SignBridge.

## 🎯 Overview

SignBridge uses three AI models from Cactus SDK:
1. **LFM2-VL-450M** - Vision model for hand landmark detection
2. **Qwen3-0.6B** - Text processing model
3. **Whisper-Tiny** - Speech-to-text model

## 📋 Prerequisites

1. **Cactus SDK Account**
   - Sign up at [Cactus SDK website]
   - Obtain API credentials
   - Download model files

2. **Development Environment**
   - Flutter 3.0.0+
   - Android Studio
   - Android device/emulator with API 24+

## 🔧 Integration Steps

### Step 1: Add Cactus SDK Dependency

Update [`pubspec.yaml`](pubspec.yaml:1):

```yaml
dependencies:
  # Add actual Cactus SDK package
  cactus: ^x.x.x  # Replace with actual version
  
  # Or if using local SDK
  cactus:
    path: ./cactus_sdk
```

### Step 2: Configure Android

Update [`android/app/build.gradle`](android/app/build.gradle:1):

```gradle
android {
    // Ensure these settings are present
    aaptOptions {
        noCompress 'tflite'
        noCompress 'onnx'
        noCompress 'bin'
    }
    
    packagingOptions {
        pickFirst 'lib/x86/libc++_shared.so'
        pickFirst 'lib/x86_64/libc++_shared.so'
        pickFirst 'lib/armeabi-v7a/libc++_shared.so'
        pickFirst 'lib/arm64-v8a/libc++_shared.so'
    }
}
```

### Step 3: Add Model Files

Create directory structure:
```
android/app/src/main/assets/models/
├── lfm2_vl_450m/
│   ├── model.tflite (or .onnx)
│   └── config.json
├── qwen3_0.6b/
│   ├── model.tflite (or .onnx)
│   └── config.json
└── whisper_tiny/
    ├── model.tflite (or .onnx)
    └── config.json
```

### Step 4: Implement CactusModelService

Update [`lib/core/services/cactus_model_service.dart`](lib/core/services/cactus_model_service.dart:1):

```dart
import 'package:cactus/cactus.dart'; // Import actual Cactus SDK

class CactusModelService {
  // Add Cactus SDK instances
  late CactusVisionModel _visionModel;
  late CactusTextModel _textModel;
  late CactusSpeechModel _speechModel;
  
  Future<void> initialize() async {
    try {
      Logger.info('Initializing Cactus SDK models');
      final startTime = DateTime.now();
      
      // Initialize Vision Model (LFM2-VL-450M)
      _visionModel = await CactusVisionModel.load(
        modelPath: 'assets/models/lfm2_vl_450m/model.tflite',
        configPath: 'assets/models/lfm2_vl_450m/config.json',
        useGpu: true, // Enable GPU acceleration
      );
      _visionModelLoaded = true;
      Logger.success('Vision model loaded');
      
      // Initialize Text Model (Qwen3-0.6B)
      _textModel = await CactusTextModel.load(
        modelPath: 'assets/models/qwen3_0.6b/model.tflite',
        configPath: 'assets/models/qwen3_0.6b/config.json',
        useGpu: true,
      );
      _textModelLoaded = true;
      Logger.success('Text model loaded');
      
      // Initialize Speech Model (Whisper-Tiny)
      _speechModel = await CactusSpeechModel.load(
        modelPath: 'assets/models/whisper_tiny/model.tflite',
        configPath: 'assets/models/whisper_tiny/config.json',
        useGpu: true,
      );
      _speechModelLoaded = true;
      Logger.success('Speech model loaded');
      
      _isInitialized = true;
      _initTimeMs = DateTime.now().difference(startTime).inMilliseconds;
      
      Logger.success('All Cactus models initialized in ${_initTimeMs}ms');
    } catch (e, stackTrace) {
      Logger.error('Failed to initialize Cactus models', 
                   error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  Future<HandLandmarks?> detectHandLandmarks(dynamic imageData) async {
    if (!_isInitialized) {
      throw StateError('CactusModelService not initialized');
    }
    
    try {
      final startTime = DateTime.now();
      
      // Convert image data to format expected by Cactus SDK
      final input = _prepareImageInput(imageData);
      
      // Run inference
      final result = await _visionModel.detectHandLandmarks(input);
      
      // Convert result to HandLandmarks
      final landmarks = _convertToHandLandmarks(result);
      
      // Update statistics
      _totalInferences++;
      final latency = DateTime.now().difference(startTime).inMilliseconds;
      _updateAverageLatency(latency);
      
      return landmarks;
    } catch (e, stackTrace) {
      Logger.error('Hand landmark detection failed', 
                   error: e, stackTrace: stackTrace);
      return null;
    }
  }
  
  Future<String?> transcribeAudio(List<int> audioData) async {
    if (!_isInitialized) {
      throw StateError('CactusModelService not initialized');
    }
    
    try {
      final startTime = DateTime.now();
      
      // Convert audio data to format expected by Cactus SDK
      final input = _prepareAudioInput(audioData);
      
      // Run inference
      final result = await _speechModel.transcribe(input);
      
      // Update statistics
      _totalInferences++;
      final latency = DateTime.now().difference(startTime).inMilliseconds;
      _updateAverageLatency(latency);
      
      return result.text;
    } catch (e, stackTrace) {
      Logger.error('Audio transcription failed', 
                   error: e, stackTrace: stackTrace);
      return null;
    }
  }
  
  // Helper methods
  dynamic _prepareImageInput(dynamic imageData) {
    // Convert camera frame to format expected by vision model
    // This depends on Cactus SDK's input format
    // Example: Convert to tensor, normalize, resize, etc.
    return imageData; // Placeholder
  }
  
  dynamic _prepareAudioInput(List<int> audioData) {
    // Convert audio data to format expected by speech model
    // This depends on Cactus SDK's input format
    // Example: Convert to float array, apply preprocessing, etc.
    return audioData; // Placeholder
  }
  
  HandLandmarks? _convertToHandLandmarks(dynamic result) {
    // Convert Cactus SDK result to HandLandmarks model
    // This depends on the SDK's output format
    
    // Example structure:
    final points = <Point3D>[];
    for (var i = 0; i < 21; i++) {
      points.add(Point3D(
        x: result.landmarks[i].x,
        y: result.landmarks[i].y,
        z: result.landmarks[i].z,
      ));
    }
    
    return HandLandmarks(points: points);
  }
}
```

### Step 5: Test Integration

Create a test file `test/cactus_integration_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:signbridge/core/services/cactus_model_service.dart';

void main() {
  group('Cactus SDK Integration', () {
    late CactusModelService service;
    
    setUp(() {
      service = CactusModelService();
    });
    
    test('Models initialize successfully', () async {
      await service.initialize();
      expect(service.isInitialized, true);
    });
    
    test('Vision model detects hand landmarks', () async {
      await service.initialize();
      
      // Load test image
      final testImage = await loadTestImage();
      
      // Detect landmarks
      final landmarks = await service.detectHandLandmarks(testImage);
      
      expect(landmarks, isNotNull);
      expect(landmarks!.points.length, 21);
    });
    
    test('Speech model transcribes audio', () async {
      await service.initialize();
      
      // Load test audio
      final testAudio = await loadTestAudio();
      
      // Transcribe
      final text = await service.transcribeAudio(testAudio);
      
      expect(text, isNotNull);
      expect(text!.isNotEmpty, true);
    });
  });
}
```

## 🔍 Debugging Tips

### Enable Verbose Logging

Update [`lib/core/utils/logger.dart`](lib/core/utils/logger.dart:1):

```dart
class Logger {
  static const bool _verbose = true; // Enable for debugging
  
  static void debug(String message) {
    if (_verbose) {
      print('[DEBUG] $message');
    }
  }
}
```

### Monitor Performance

Use the built-in performance monitoring:

```dart
// In SignRecognitionService
final stats = getStatistics();
print('FPS: ${stats['fps']}');
print('Latency: ${stats['averageLatencyMs']}ms');
print('Confidence: ${stats['averageConfidence']}');
```

### Check Model Loading

```dart
// Verify models are loaded
final cactusService = CactusModelService();
await cactusService.initialize();

final stats = cactusService.getStatistics();
print('Vision Model: ${stats['visionModelLoaded']}');
print('Text Model: ${stats['textModelLoaded']}');
print('Speech Model: ${stats['speechModelLoaded']}');
```

## 🚨 Common Issues

### Issue 1: Model Files Not Found

**Error**: `FileNotFoundException: model.tflite not found`

**Solution**:
1. Verify model files are in `android/app/src/main/assets/models/`
2. Check file names match exactly
3. Rebuild the app: `flutter clean && flutter build apk`

### Issue 2: Out of Memory

**Error**: `OutOfMemoryError` during model loading

**Solution**:
1. Reduce model size (use quantized versions)
2. Load models sequentially instead of parallel
3. Increase heap size in `android/app/build.gradle`:
   ```gradle
   android {
       dexOptions {
           javaMaxHeapSize "4g"
       }
   }
   ```

### Issue 3: Slow Inference

**Problem**: Inference takes >500ms

**Solution**:
1. Enable GPU acceleration (already configured)
2. Reduce input resolution
3. Use model quantization
4. Profile with Android Profiler

### Issue 4: Incorrect Predictions

**Problem**: Low accuracy or wrong predictions

**Solution**:
1. Verify input preprocessing matches model training
2. Check normalization values
3. Validate input dimensions
4. Test with known good samples

## 📊 Performance Benchmarks

### Target Metrics
- Model loading: <5 seconds
- Hand detection: <100ms per frame
- Speech transcription: <300ms per second of audio
- Total latency: <500ms end-to-end

### Optimization Checklist
- [ ] GPU acceleration enabled
- [ ] Models quantized (INT8 or FP16)
- [ ] Input preprocessing optimized
- [ ] Batch processing where applicable
- [ ] Memory pooling for tensors
- [ ] Async inference for non-blocking UI

## 🔗 Resources

### Cactus SDK Documentation
- Official docs: [Link to Cactus SDK docs]
- API reference: [Link to API docs]
- Examples: [Link to examples]

### Model Information
- **LFM2-VL-450M**: Vision model for hand landmark detection
  - Input: 224x224 RGB image
  - Output: 21 landmarks × 3 coordinates
  - Size: ~450MB
  
- **Qwen3-0.6B**: Text processing model
  - Input: Text tokens
  - Output: Processed text
  - Size: ~600MB
  
- **Whisper-Tiny**: Speech recognition model
  - Input: 16kHz audio
  - Output: Transcribed text
  - Size: ~75MB

## ✅ Integration Checklist

- [ ] Cactus SDK dependency added to pubspec.yaml
- [ ] Model files downloaded and placed in assets
- [ ] Android configuration updated
- [ ] CactusModelService methods implemented
- [ ] Input preprocessing implemented
- [ ] Output conversion implemented
- [ ] Error handling added
- [ ] Performance monitoring enabled
- [ ] Unit tests written
- [ ] Integration tests passing
- [ ] Tested on real device
- [ ] Performance benchmarks met

## 🎓 Next Steps

After successful integration:

1. **Test on Real Device**
   ```bash
   flutter run --release
   ```

2. **Profile Performance**
   - Use Android Profiler
   - Monitor CPU, memory, GPU usage
   - Optimize bottlenecks

3. **Build Release APK**
   ```bash
   flutter build apk --release --split-per-abi
   ```

4. **Create Demo Video**
   - Record sign-to-speech demo
   - Record speech-to-sign demo
   - Show performance metrics

---

**Need Help?**
- Check Cactus SDK documentation
- Review error logs in Android Studio
- Test with provided sample code
- Contact Cactus SDK support
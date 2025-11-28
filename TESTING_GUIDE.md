# SignBridge Testing Guide

Complete guide for testing SignBridge application with mock Cactus SDK implementation.

## 🎯 Testing Overview

SignBridge can be tested immediately with the mock implementation. This guide covers:
- Unit testing
- Integration testing
- Manual testing
- Performance testing
- Device testing

## 🧪 Unit Testing

### Setup Test Environment

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/core/models/point_3d_test.dart

# Watch mode (re-run on changes)
flutter test --watch
```

### Test Structure

```
test/
├── core/
│   ├── models/
│   │   ├── point_3d_test.dart
│   │   ├── hand_landmarks_test.dart
│   │   └── recognition_result_test.dart
│   ├── services/
│   │   ├── cactus_model_service_test.dart
│   │   └── camera_service_test.dart
│   └── utils/
│       └── logger_test.dart
├── features/
│   ├── sign_recognition/
│   │   ├── gesture_classifier_test.dart
│   │   └── letter_buffer_test.dart
│   ├── speech_recognition/
│   │   └── speech_recognition_service_test.dart
│   └── sign_animation/
│       └── sign_animation_service_test.dart
└── integration/
    ├── sign_to_speech_flow_test.dart
    └── speech_to_sign_flow_test.dart
```

### Example Unit Tests

Create `test/core/models/point_3d_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:signbridge/core/models/point_3d.dart';

void main() {
  group('Point3D', () {
    test('creates point with correct coordinates', () {
      final point = Point3D(1.0, 2.0, 3.0);
      
      expect(point.x, 1.0);
      expect(point.y, 2.0);
      expect(point.z, 3.0);
    });
    
    test('calculates distance correctly', () {
      final p1 = Point3D(0.0, 0.0, 0.0);
      final p2 = Point3D(3.0, 4.0, 0.0);
      
      expect(p1.distanceTo(p2), 5.0);
    });
    
    test('adds points correctly', () {
      final p1 = Point3D(1.0, 2.0, 3.0);
      final p2 = Point3D(4.0, 5.0, 6.0);
      final result = p1 + p2;
      
      expect(result.x, 5.0);
      expect(result.y, 7.0);
      expect(result.z, 9.0);
    });
  });
}
```

Create `test/features/sign_recognition/gesture_classifier_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:signbridge/features/sign_recognition/models/gesture_classifier.dart';
import 'package:signbridge/core/models/hand_landmarks.dart';
import 'package:signbridge/core/models/point_3d.dart';

void main() {
  group('GestureClassifier', () {
    late GestureClassifier classifier;
    
    setUp(() {
      classifier = GestureClassifier();
    });
    
    test('initializes with 36 gestures', () {
      expect(classifier.gestureCount, 36);
    });
    
    test('recognizes letter A', () {
      // Create test landmarks for letter A
      final landmarks = _createTestLandmarks('A');
      
      final result = classifier.classify(landmarks);
      
      expect(result, isNotNull);
      expect(result!.letter, 'A');
      expect(result.confidence, greaterThan(0.75));
    });
    
    test('returns null for invalid landmarks', () {
      final landmarks = HandLandmarks(
        points: List.generate(21, (i) => Point3D(0, 0, 0)),
      );
      
      final result = classifier.classify(landmarks);
      
      expect(result, isNull);
    });
  });
}

HandLandmarks _createTestLandmarks(String letter) {
  // Create realistic test data
  // This would use actual gesture data
  return HandLandmarks(
    points: List.generate(21, (i) => Point3D(
      0.5 + (i * 0.01),
      0.5 + (i * 0.02),
      0.0,
    )),
  );
}
```

## 🔄 Integration Testing

### Sign-to-Speech Flow Test

Create `test/integration/sign_to_speech_flow_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:signbridge/core/services/cactus_model_service.dart';
import 'package:signbridge/features/sign_recognition/services/sign_recognition_service.dart';
import 'package:signbridge/features/text_to_speech/services/tts_service.dart';

void main() {
  group('Sign-to-Speech Integration', () {
    late CactusModelService cactusService;
    late SignRecognitionService recognitionService;
    late TTSService ttsService;
    
    setUp(() async {
      cactusService = CactusModelService();
      await cactusService.initialize();
      
      recognitionService = SignRecognitionService();
      await recognitionService.initialize();
      
      ttsService = TTSService();
      await ttsService.initialize();
    });
    
    test('complete pipeline processes frame to speech', () async {
      // Start recognition
      await recognitionService.startRecognition();
      
      // Wait for processing
      await Future.delayed(Duration(seconds: 2));
      
      // Check results
      expect(recognitionService.isProcessing, true);
      expect(recognitionService.recognizedText.isNotEmpty, true);
    });
    
    tearDown(() async {
      await recognitionService.stopRecognition();
      await cactusService.dispose();
    });
  });
}
```

## 📱 Manual Testing Checklist

### Pre-Testing Setup

- [ ] Device/emulator running Android 7.0+ (API 24+)
- [ ] Camera available (physical or virtual)
- [ ] Microphone available
- [ ] At least 2GB free storage
- [ ] Good lighting conditions (for camera testing)

### Sign-to-Speech Mode Testing

**1. Launch and Permissions**
- [ ] App launches successfully
- [ ] Camera permission requested
- [ ] Permission granted successfully
- [ ] Camera preview displays

**2. Hand Detection**
- [ ] Place hand in camera view
- [ ] Hand landmarks detected (check overlay)
- [ ] Detection works at different distances
- [ ] Detection works at different angles
- [ ] Detection works with different lighting

**3. Gesture Recognition**
- [ ] Make letter 'A' sign
- [ ] Letter recognized and displayed
- [ ] Confidence score shown (>75%)
- [ ] Recognition stable (not flickering)
- [ ] Try all 26 letters
- [ ] Try numbers 0-9

**4. Letter Buffering**
- [ ] Hold sign for 1 second
- [ ] Letter appears in text panel
- [ ] Quick gestures don't register
- [ ] Stable recognition after buffer

**5. Word Assembly**
- [ ] Spell simple word (e.g., "HI")
- [ ] Letters combine into word
- [ ] Word displayed correctly
- [ ] Clear button works

**6. Text-to-Speech**
- [ ] Assembled text spoken aloud
- [ ] Audio clear and understandable
- [ ] Volume adjustable
- [ ] Speech rate appropriate

**7. Performance Metrics**
- [ ] FPS counter displays (~10 FPS)
- [ ] Latency shown (<500ms)
- [ ] Confidence scores displayed
- [ ] No lag or stuttering

**8. Camera Controls**
- [ ] Switch camera button works
- [ ] Front/back camera both functional
- [ ] Camera preview maintains aspect ratio

### Speech-to-Sign Mode Testing

**1. Launch and Permissions**
- [ ] Navigate to speech-to-sign mode
- [ ] Microphone permission requested
- [ ] Permission granted successfully

**2. Voice Input**
- [ ] Tap "Start Listening"
- [ ] Microphone indicator shows
- [ ] Speak clearly: "Hello world"
- [ ] Tap "Stop & Play"
- [ ] Text transcribed correctly

**3. Text Input (Alternative)**
- [ ] Type text in input field
- [ ] Text accepts input
- [ ] Tap "Play Signs"
- [ ] Animation starts

**4. Sign Animation**
- [ ] Avatar displays sign
- [ ] Animation smooth
- [ ] Correct sign shown
- [ ] Animation queue visible

**5. Dictionary Lookup**
- [ ] Common words show full sign
- [ ] Unknown words fingerspelled
- [ ] Fingerspelling letter-by-letter
- [ ] Pause between words

**6. Animation Controls**
- [ ] Play/pause works
- [ ] Stop button works
- [ ] Replay works
- [ ] Speed control (if implemented)

**7. Statistics**
- [ ] Words displayed count
- [ ] Letters fingerspelled count
- [ ] Total animations count
- [ ] Dictionary size shown

### Settings Screen Testing

**1. Model Status**
- [ ] Vision model status shown
- [ ] Text model status shown
- [ ] Speech model status shown
- [ ] Mock mode indicator visible

**2. Dictionary Info**
- [ ] Total words count correct
- [ ] Category breakdown shown
- [ ] View all words button works
- [ ] Word list displays

**3. Performance Targets**
- [ ] Target metrics displayed
- [ ] Current performance shown
- [ ] Offline indicator present

**4. About Section**
- [ ] Version number shown
- [ ] Platform info correct
- [ ] Feature chips displayed

### Error Handling Testing

**1. Permission Denied**
- [ ] Deny camera permission
- [ ] Error message shown
- [ ] Settings button works
- [ ] Graceful degradation

**2. No Camera/Microphone**
- [ ] Test without camera
- [ ] Appropriate error shown
- [ ] App doesn't crash

**3. Low Light Conditions**
- [ ] Test in dark environment
- [ ] Detection still attempts
- [ ] User feedback provided

**4. Network Offline**
- [ ] Disable network
- [ ] App still functions
- [ ] No errors shown

## 📊 Performance Testing

### Metrics to Monitor

**1. Latency**
```bash
# Monitor frame processing time
# Target: <500ms per gesture
# Check: Performance overlay in app
```

**2. Frame Rate**
```bash
# Monitor FPS counter
# Target: 10 FPS
# Check: Top-right corner of sign-to-speech screen
```

**3. Memory Usage**
```bash
# Monitor with Android Studio Profiler
adb shell dumpsys meminfo com.signbridge

# Target: <2GB RAM
```

**4. Battery Usage**
```bash
# Monitor battery drain
adb shell dumpsys batterystats

# Target: Reasonable drain for camera app
```

**5. APK Size**
```bash
# Check APK size
ls -lh build/app/outputs/flutter-apk/

# Target: ~1-1.2GB (with models)
```

### Performance Test Scenarios

**1. Continuous Use**
- Run sign-to-speech for 5 minutes
- Monitor memory leaks
- Check for slowdowns
- Verify stability

**2. Mode Switching**
- Switch between modes 10 times
- Check for memory leaks
- Verify smooth transitions
- No crashes

**3. Background/Foreground**
- Send app to background
- Return to foreground
- Camera resumes correctly
- No data loss

## 🔧 Debugging Tips

### Enable Verbose Logging

Edit `lib/core/utils/logger.dart`:
```dart
static const bool _verbose = true;
```

### View Logs

```bash
# Flutter logs
flutter logs

# Android logs
adb logcat | grep SignBridge

# Filter by level
adb logcat *:E  # Errors only
```

### Common Issues

**Issue: Camera not working**
```bash
# Check permissions
adb shell pm list permissions -d -g

# Grant manually
adb shell pm grant com.signbridge android.permission.CAMERA
```

**Issue: Low FPS**
```bash
# Check GPU rendering
adb shell dumpsys gfxinfo com.signbridge

# Enable GPU profiling
adb shell setprop debug.hwui.profile visual_bars
```

**Issue: High memory usage**
```bash
# Dump heap
adb shell am dumpheap com.signbridge /data/local/tmp/heap.hprof
adb pull /data/local/tmp/heap.hprof

# Analyze with Android Studio Memory Profiler
```

## 📋 Test Report Template

```markdown
# SignBridge Test Report

**Date**: YYYY-MM-DD
**Tester**: Name
**Device**: Model (Android Version)
**Build**: Version

## Test Results

### Sign-to-Speech Mode
- [ ] PASS / FAIL - Camera preview
- [ ] PASS / FAIL - Hand detection
- [ ] PASS / FAIL - Gesture recognition
- [ ] PASS / FAIL - Text-to-speech

**Issues Found**:
1. Description
2. Description

### Speech-to-Sign Mode
- [ ] PASS / FAIL - Voice input
- [ ] PASS / FAIL - Text input
- [ ] PASS / FAIL - Sign animation
- [ ] PASS / FAIL - Fingerspelling

**Issues Found**:
1. Description
2. Description

### Performance
- FPS: X fps (target: 10)
- Latency: X ms (target: <500)
- Memory: X MB (target: <2GB)
- Battery: X% per hour

### Overall Assessment
- [ ] Ready for release
- [ ] Needs fixes
- [ ] Requires major work

**Notes**:
Additional observations...
```

## 🚀 Automated Testing

### CI/CD Integration

Create `.github/workflows/test.yml`:

```yaml
name: Test

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v2
    
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.0.0'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Analyze code
      run: flutter analyze
    
    - name: Run tests
      run: flutter test --coverage
    
    - name: Upload coverage
      uses: codecov/codecov-action@v2
      with:
        files: ./coverage/lcov.info
```

## ✅ Testing Checklist Summary

Before release, ensure:

- [ ] All unit tests passing
- [ ] Integration tests passing
- [ ] Manual testing completed
- [ ] Performance targets met
- [ ] No critical bugs
- [ ] Tested on multiple devices
- [ ] Tested in various conditions
- [ ] Error handling verified
- [ ] Documentation updated
- [ ] Test report completed

---

**Happy Testing!** 🧪

*Ensuring quality and reliability for all users.*
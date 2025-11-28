# SignBridge - Quick Reference Guide

This document provides quick reference information, troubleshooting tips, and common solutions for SignBridge development.

---

## 🚀 Quick Start Commands

### Project Setup
```bash
# Create project
flutter create signbridge
cd signbridge

# Install dependencies
flutter pub get

# Run on device/emulator
flutter run

# Build APK
flutter build apk --release

# Run tests
flutter test
```

### Development Commands
```bash
# Clean build
flutter clean && flutter pub get

# Check for issues
flutter doctor

# Analyze code
flutter analyze

# Format code
dart format lib/

# Generate code coverage
flutter test --coverage
```

---

## 📋 Implementation Checklist

### Phase 1: Foundation (8 hours)
- [ ] Create Flutter project structure
- [ ] Configure `pubspec.yaml` with dependencies
- [ ] Set up Android manifest permissions
- [ ] Configure `build.gradle` for optimization
- [ ] Create core data models
- [ ] Implement `PermissionService`
- [ ] Implement `CactusModelService` skeleton
- [ ] Build basic UI navigation

### Phase 2: Sign-to-Speech (8 hours)
- [ ] Implement `CameraService`
- [ ] Build `SignRecognitionService`
- [ ] Create ASL gesture database
- [ ] Implement `GestureClassifier`
- [ ] Add letter buffering logic
- [ ] Implement `TTSService`
- [ ] Build `SignToSpeechScreen`
- [ ] Add performance monitoring

### Phase 3: Speech-to-Sign (4 hours)
- [ ] Implement `SpeechRecognitionService`
- [ ] Create `SignAnimationService`
- [ ] Build `SignAvatar` widget
- [ ] Implement fingerspelling
- [ ] Create `SignDictionaryRepository`
- [ ] Build `SpeechToSignScreen`

### Phase 4: Polish (3 hours)
- [ ] Implement `SettingsScreen`
- [ ] Add confidence indicators
- [ ] Create app theme
- [ ] Test on emulator
- [ ] Fix bugs
- [ ] Optimize performance

### Phase 5: Bonus (1 hour)
- [ ] Implement `HybridRouter`
- [ ] Add privacy dashboard
- [ ] Create demo video
- [ ] Write documentation

---

## 🔧 Common Issues & Solutions

### Issue: Models Not Downloading

**Symptoms**: App stuck on "Downloading models..." screen

**Solutions**:
1. Check internet connection
2. Clear app data: `flutter clean`
3. Verify Cactus SDK credentials
4. Check storage space (need ~1GB free)
5. Try manual model download

```dart
// Force re-download
final prefs = await SharedPreferences.getInstance();
await prefs.setBool('models_downloaded', false);
```

---

### Issue: Camera Not Working

**Symptoms**: Black screen or "Camera error" message

**Solutions**:
1. Check permissions in Android settings
2. Restart app
3. Check camera availability:

```dart
final cameras = await availableCameras();
if (cameras.isEmpty) {
  print('No cameras available');
}
```

4. Verify AndroidManifest.xml has camera permission
5. Test on physical device (emulator cameras are limited)

---

### Issue: Poor Recognition Accuracy

**Symptoms**: Letters not recognized or wrong letters detected

**Solutions**:
1. Improve lighting conditions
2. Center hand in frame
3. Hold gesture longer (>0.5 seconds)
4. Adjust confidence threshold:

```dart
// In GestureClassifier
if (maxSimilarity > 0.70) { // Lower from 0.75
  return RecognitionResult(...);
}
```

5. Calibrate gesture database
6. Increase buffer window size:

```dart
final _buffer = LetterBuffer(windowSize: 7); // Increase from 5
```

---

### Issue: High Latency (>500ms)

**Symptoms**: Slow response time, laggy recognition

**Solutions**:
1. Reduce frame rate:

```dart
// Process every 4th frame instead of 3rd
if (frameCount % 4 == 0) {
  _processFrame(image);
}
```

2. Enable GPU acceleration
3. Use isolates for processing:

```dart
final result = await compute(_processFrameIsolate, image);
```

4. Optimize image preprocessing:

```dart
// Reduce image size
final resized = img.copyResize(image, width: 224, height: 224);
```

5. Profile and optimize hot paths

---

### Issue: App Crashes on Launch

**Symptoms**: App closes immediately after opening

**Solutions**:
1. Check logcat for errors:

```bash
flutter logs
```

2. Verify all dependencies are compatible
3. Check for null safety issues
4. Ensure models are properly initialized
5. Add error handling:

```dart
try {
  await CactusModelService().initialize();
} catch (e) {
  print('Initialization error: $e');
  // Show error dialog
}
```

---

### Issue: Memory Leak

**Symptoms**: App slows down over time, eventually crashes

**Solutions**:
1. Dispose controllers properly:

```dart
@override
void dispose() {
  _cameraController?.dispose();
  _buffer.clear();
  super.dispose();
}
```

2. Clear buffers periodically:

```dart
if (_assembledText.length > 1000) {
  _assembledText = _assembledText.substring(_assembledText.length - 500);
}
```

3. Monitor memory usage:

```dart
import 'dart:developer' as developer;

developer.Timeline.startSync('processFrame');
// ... processing code ...
developer.Timeline.finishSync();
```

---

## 🎯 Performance Optimization Tips

### 1. Frame Processing
```dart
// Throttle frame processing
int _frameCount = 0;
void _onCameraFrame(CameraImage image) {
  _frameCount++;
  if (_frameCount % 3 != 0) return; // Process every 3rd frame
  
  _processFrame(image);
}
```

### 2. Image Preprocessing
```dart
// Efficient image conversion
import 'package:image/image.dart' as img;

img.Image convertCameraImage(CameraImage image) {
  // Use efficient conversion
  return img.Image.fromBytes(
    image.width,
    image.height,
    image.planes[0].bytes,
    format: img.Format.bgra,
  );
}
```

### 3. Async Processing
```dart
// Use isolates for heavy computation
Future<RecognitionResult> _processInIsolate(List<double> landmarks) async {
  return await compute(_classifyGesture, landmarks);
}

static RecognitionResult _classifyGesture(List<double> landmarks) {
  // Heavy computation here
}
```

### 4. Caching
```dart
// Cache frequently used data
final Map<String, List<double>> _gestureCache = {};

List<double>? getCachedGesture(String letter) {
  return _gestureCache[letter];
}
```

### 5. Lazy Loading
```dart
// Load animations on demand
Future<void> _loadAnimation(String word) async {
  if (!_loadedAnimations.contains(word)) {
    final animation = await _loadAnimationFile(word);
    _animations[word] = animation;
    _loadedAnimations.add(word);
  }
}
```

---

## 📊 Debugging Tools

### 1. Performance Overlay
```dart
// In main.dart
MaterialApp(
  showPerformanceOverlay: true, // Enable FPS overlay
  // ...
)
```

### 2. Custom Logger
```dart
// lib/core/utils/logger.dart
class Logger {
  static void log(String message, {String tag = 'SignBridge'}) {
    final timestamp = DateTime.now().toIso8601String();
    print('[$timestamp][$tag] $message');
  }
  
  static void error(String message, {Object? error, StackTrace? stack}) {
    log('ERROR: $message', tag: 'ERROR');
    if (error != null) print('Error: $error');
    if (stack != null) print('Stack: $stack');
  }
}
```

### 3. Performance Monitor Widget
```dart
class PerformanceDisplay extends StatelessWidget {
  final int fps;
  final int latency;
  final double confidence;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      color: Colors.black54,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('FPS: $fps', style: TextStyle(color: Colors.white)),
          Text('Latency: ${latency}ms', style: TextStyle(color: Colors.white)),
          Text('Confidence: ${(confidence * 100).toStringAsFixed(1)}%',
               style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
```

---

## 🧪 Testing Strategies

### Unit Test Example
```dart
// test/gesture_classifier_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:signbridge/features/sign_recognition/models/gesture_classifier.dart';

void main() {
  group('GestureClassifier', () {
    late GestureClassifier classifier;
    
    setUp(() {
      classifier = GestureClassifier();
    });
    
    test('should classify known gesture', () {
      final landmarks = List.filled(63, 0.5);
      final result = classifier.classify(landmarks);
      
      expect(result.letter, isNotEmpty);
      expect(result.confidence, greaterThan(0.0));
    });
    
    test('should return unknown for invalid input', () {
      final landmarks = List.filled(10, 0.5); // Wrong size
      final result = classifier.classify(landmarks);
      
      expect(result.letter, isEmpty);
      expect(result.confidence, equals(0.0));
    });
  });
}
```

### Widget Test Example
```dart
// test/home_screen_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:signbridge/ui/screens/home_screen.dart';

void main() {
  testWidgets('HomeScreen displays mode options', (tester) async {
    await tester.pumpWidget(MaterialApp(home: HomeScreen()));
    
    expect(find.text('Sign to Speech'), findsOneWidget);
    expect(find.text('Speech to Sign'), findsOneWidget);
  });
}
```

---

## 📱 Device-Specific Considerations

### Emulator Limitations
- Camera may not work properly
- GPU acceleration limited
- Performance slower than physical device
- Use x86_64 emulator for better performance

### Physical Device Requirements
- Android 7.0+ (API 24+)
- 2GB+ RAM
- 2GB+ free storage
- Camera with autofocus
- Decent CPU (Snapdragon 600+ or equivalent)

### Recommended Test Devices
- Google Pixel 4+
- Samsung Galaxy S10+
- OnePlus 7+
- Any device with Snapdragon 700+ series

---

## 🔐 Security Best Practices

### 1. Permission Handling
```dart
// Always check permissions before use
Future<bool> checkCameraPermission() async {
  final status = await Permission.camera.status;
  if (status.isDenied) {
    final result = await Permission.camera.request();
    return result.isGranted;
  }
  return status.isGranted;
}
```

### 2. Data Privacy
```dart
// Never log sensitive data
void processFrame(CameraImage image) {
  // DON'T: Logger.log('Processing image: $image');
  // DO: Logger.log('Processing frame ${image.width}x${image.height}');
}
```

### 3. Secure Storage
```dart
// Use encrypted storage for sensitive data
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();
await storage.write(key: 'api_key', value: apiKey);
```

---

## 🎨 UI/UX Best Practices

### 1. Loading States
```dart
// Always show loading indicators
if (_isLoading) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text('Downloading models...'),
        Text('${(_progress * 100).toStringAsFixed(0)}%'),
      ],
    ),
  );
}
```

### 2. Error Messages
```dart
// User-friendly error messages
void showError(BuildContext context, String error) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Oops! $error'),
      action: SnackBarAction(
        label: 'Retry',
        onPressed: () => _retry(),
      ),
    ),
  );
}
```

### 3. Feedback
```dart
// Provide visual feedback
void onGestureRecognized(String letter) {
  // Haptic feedback
  HapticFeedback.lightImpact();
  
  // Visual feedback
  setState(() {
    _highlightLetter = letter;
  });
  
  // Audio feedback (optional)
  _playBeep();
}
```

---

## 📚 Useful Resources

### Documentation
- [Flutter Docs](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Camera Plugin](https://pub.dev/packages/camera)
- [Provider State Management](https://pub.dev/packages/provider)

### ASL Resources
- [ASL Alphabet Chart](https://www.lifeprint.com/asl101/fingerspelling/abc.htm)
- [MediaPipe Hands](https://developers.google.com/mediapipe/solutions/vision/hand_landmarker)
- [ASL Dictionary](https://www.handspeak.com/)

### Performance Tools
- [Flutter DevTools](https://flutter.dev/docs/development/tools/devtools/overview)
- [Android Profiler](https://developer.android.com/studio/profile/android-profiler)
- [Dart Observatory](https://dart-lang.github.io/observatory/)

---

## 🐛 Common Error Messages

### "Camera permission denied"
**Solution**: Request permission in AndroidManifest.xml and at runtime

### "Model not found"
**Solution**: Ensure models are downloaded and paths are correct

### "Out of memory"
**Solution**: Reduce image size, clear buffers, optimize processing

### "GPU acceleration not available"
**Solution**: Fall back to CPU, or use a device with GPU support

### "Frame processing timeout"
**Solution**: Reduce frame rate, optimize processing pipeline

---

## 💡 Pro Tips

1. **Test Early, Test Often**: Don't wait until the end to test on device
2. **Profile First, Optimize Second**: Use profiling tools to find bottlenecks
3. **Keep It Simple**: Start with basic features, add complexity later
4. **Document As You Go**: Write comments and docs while coding
5. **Version Control**: Commit frequently with clear messages
6. **Error Handling**: Add try-catch blocks around critical code
7. **User Feedback**: Show progress, errors, and success states
8. **Performance Monitoring**: Track metrics from day one
9. **Code Reviews**: Have someone review your code
10. **Stay Updated**: Keep dependencies and SDK up to date

---

## 🎯 Success Metrics

Track these metrics to ensure quality:

- **Recognition Accuracy**: >90% for ASL alphabet
- **Latency**: <500ms end-to-end
- **Frame Rate**: Stable 10 FPS
- **Memory Usage**: <2GB RAM
- **Battery Drain**: <10% per hour of use
- **Crash Rate**: <1% of sessions
- **User Satisfaction**: >4.5/5 stars

---

## 📞 Getting Help

If you're stuck:

1. Check this guide first
2. Review ARCHITECTURE.md and IMPLEMENTATION_GUIDE.md
3. Search Flutter documentation
4. Check Stack Overflow
5. Review Cactus SDK documentation
6. Ask in Flutter community forums
7. File an issue on GitHub

---

**Remember**: Building SignBridge is an iterative process. Start simple, test frequently, and improve gradually. Good luck! 🚀
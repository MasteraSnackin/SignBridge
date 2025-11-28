# SignBridge Deployment Guide

Complete guide for building, testing, and deploying SignBridge to production.

## 📋 Pre-Deployment Checklist

### Code Quality
- [ ] All TODO comments addressed
- [ ] Cactus SDK integrated and tested
- [ ] No debug print statements in production code
- [ ] Error handling implemented
- [ ] Logging configured appropriately
- [ ] Code reviewed and approved

### Testing
- [ ] Unit tests passing
- [ ] Integration tests passing
- [ ] Manual testing completed
- [ ] Performance benchmarks met
- [ ] Memory leaks checked
- [ ] Battery usage optimized

### Configuration
- [ ] Release signing configured
- [ ] ProGuard rules added (if needed)
- [ ] App icons added (all sizes)
- [ ] Splash screen configured
- [ ] Version number updated
- [ ] Build number incremented

## 🔧 Build Configuration

### 1. Update Version

Edit [`pubspec.yaml`](pubspec.yaml:1):

```yaml
version: 1.0.0+1  # version+build_number
```

### 2. Configure Signing

Create `android/key.properties`:

```properties
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=signbridge
storeFile=<path-to-keystore>
```

Update `android/app/build.gradle`:

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

### 3. Create ProGuard Rules

Create `android/app/proguard-rules.pro`:

```proguard
# Keep Cactus SDK classes
-keep class com.cactus.** { *; }

# Keep TensorFlow Lite
-keep class org.tensorflow.** { *; }

# Keep Flutter
-keep class io.flutter.** { *; }

# Keep camera plugin
-keep class io.flutter.plugins.camera.** { *; }

# Keep model classes
-keep class com.signbridge.core.models.** { *; }

# Prevent obfuscation of native methods
-keepclasseswithmembernames class * {
    native <methods>;
}
```

## 🏗️ Build Process

### Development Build

```bash
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Run code generation (if using build_runner)
flutter pub run build_runner build --delete-conflicting-outputs

# Build debug APK
flutter build apk --debug

# Install on connected device
flutter install
```

### Release Build

```bash
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Analyze code
flutter analyze

# Run tests
flutter test

# Build release APK (single APK)
flutter build apk --release

# Build release APK (split by ABI - recommended)
flutter build apk --release --split-per-abi

# Output location:
# build/app/outputs/flutter-apk/app-release.apk
# build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
# build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
# build/app/outputs/flutter-apk/app-x86_64-release.apk
```

### App Bundle (for Google Play)

```bash
# Build app bundle
flutter build appbundle --release

# Output location:
# build/app/outputs/bundle/release/app-release.aab
```

## 📦 APK Optimization

### Reduce APK Size

1. **Split by ABI**
   ```bash
   flutter build apk --release --split-per-abi
   ```
   This creates separate APKs for different CPU architectures, reducing size by ~30%.

2. **Enable ProGuard**
   Already configured in `build.gradle` with `minifyEnabled true`.

3. **Compress Assets**
   ```bash
   # Optimize images
   find assets -name "*.png" -exec optipng -o7 {} \;
   
   # Compress JSON files
   find assets -name "*.json" -exec gzip {} \;
   ```

4. **Remove Unused Resources**
   ```gradle
   android {
       buildTypes {
           release {
               shrinkResources true
           }
       }
   }
   ```

### Expected APK Sizes

- **Single APK**: ~1.2GB (includes all ABIs + models)
- **Split APKs**: 
  - arm64-v8a: ~800MB (most common)
  - armeabi-v7a: ~750MB
  - x86_64: ~850MB (emulator)

## 🧪 Testing

### Pre-Release Testing

1. **Install on Test Devices**
   ```bash
   # Install specific ABI
   adb install build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
   ```

2. **Test Checklist**
   - [ ] App launches successfully
   - [ ] Permissions requested correctly
   - [ ] Camera works in sign-to-speech mode
   - [ ] Microphone works in speech-to-sign mode
   - [ ] Models download/load correctly
   - [ ] Recognition accuracy acceptable
   - [ ] Performance meets targets (<500ms)
   - [ ] No crashes or ANRs
   - [ ] Battery usage reasonable
   - [ ] Works offline
   - [ ] Settings screen accessible
   - [ ] All UI elements responsive

3. **Performance Testing**
   ```bash
   # Profile release build
   flutter run --release --profile
   
   # Use DevTools for profiling
   flutter pub global activate devtools
   flutter pub global run devtools
   ```

4. **Memory Testing**
   ```bash
   # Monitor memory usage
   adb shell dumpsys meminfo com.signbridge
   
   # Check for memory leaks
   # Use Android Studio Profiler
   ```

## 🚀 Distribution

### Direct Distribution (APK)

1. **Upload to File Hosting**
   - Google Drive
   - Dropbox
   - GitHub Releases
   - Your own server

2. **Create Download Page**
   ```html
   <a href="signbridge-v1.0.0-arm64-v8a.apk" download>
     Download SignBridge for Android (ARM64)
   </a>
   ```

3. **Installation Instructions**
   - Enable "Install from Unknown Sources"
   - Download APK
   - Tap to install
   - Grant permissions

### Google Play Store

1. **Create Developer Account**
   - Pay $25 one-time fee
   - Complete registration

2. **Prepare Store Listing**
   - App name: SignBridge
   - Short description (80 chars)
   - Full description (4000 chars)
   - Screenshots (minimum 2)
   - Feature graphic (1024x500)
   - App icon (512x512)
   - Privacy policy URL
   - Category: Communication

3. **Upload App Bundle**
   ```bash
   # Build app bundle
   flutter build appbundle --release
   
   # Upload to Play Console
   # build/app/outputs/bundle/release/app-release.aab
   ```

4. **Configure Release**
   - Set countries/regions
   - Set pricing (Free)
   - Set content rating
   - Add release notes

5. **Submit for Review**
   - Review can take 1-7 days
   - Address any issues raised
   - App goes live after approval

## 📊 Post-Deployment

### Monitoring

1. **Crash Reporting**
   - Integrate Firebase Crashlytics
   - Monitor crash-free rate
   - Fix critical issues quickly

2. **Analytics**
   - Track user engagement
   - Monitor feature usage
   - Identify bottlenecks

3. **Performance Monitoring**
   - App startup time
   - Frame rendering time
   - Network requests (if any)
   - Battery usage

### Updates

1. **Version Numbering**
   - Major.Minor.Patch+Build
   - Example: 1.0.0+1 → 1.0.1+2

2. **Release Process**
   ```bash
   # Update version in pubspec.yaml
   version: 1.0.1+2
   
   # Build new release
   flutter build apk --release --split-per-abi
   
   # Test thoroughly
   # Upload to distribution channel
   ```

3. **Release Notes Template**
   ```
   Version 1.0.1
   
   New Features:
   - Added feature X
   - Improved feature Y
   
   Bug Fixes:
   - Fixed crash in scenario Z
   - Improved performance
   
   Known Issues:
   - Issue A (workaround: ...)
   ```

## 🔒 Security

### Best Practices

1. **API Keys**
   - Never commit API keys to git
   - Use environment variables
   - Use Android Keystore for sensitive data

2. **Code Obfuscation**
   - ProGuard enabled in release builds
   - Obfuscates class and method names
   - Makes reverse engineering harder

3. **Network Security**
   - Use HTTPS only
   - Implement certificate pinning
   - Validate all inputs

4. **Data Privacy**
   - No data collection (fully offline)
   - Clear privacy policy
   - GDPR compliant

## 📝 Documentation

### Required Documents

1. **Privacy Policy**
   - What data is collected (none)
   - How data is used (N/A)
   - User rights
   - Contact information

2. **Terms of Service**
   - Acceptable use
   - Disclaimers
   - Liability limitations

3. **User Guide**
   - How to use the app
   - Troubleshooting
   - FAQ

4. **Developer Documentation**
   - Architecture overview
   - API documentation
   - Contributing guidelines

## 🆘 Troubleshooting

### Common Build Issues

**Issue**: Build fails with "Execution failed for task ':app:lintVitalRelease'"
```bash
# Solution: Disable lint checks
android {
    lintOptions {
        checkReleaseBuilds false
    }
}
```

**Issue**: APK too large (>100MB)
```bash
# Solution: Use app bundle or split APKs
flutter build apk --release --split-per-abi
```

**Issue**: Models not included in APK
```bash
# Solution: Check assets configuration
flutter:
  assets:
    - assets/models/
```

### Deployment Issues

**Issue**: App crashes on startup
- Check ProGuard rules
- Verify all dependencies included
- Test on multiple devices

**Issue**: Poor performance
- Profile with DevTools
- Check for memory leaks
- Optimize heavy operations

**Issue**: Play Store rejection
- Review rejection reason
- Fix issues
- Resubmit

## ✅ Final Checklist

Before releasing to production:

- [ ] All features working correctly
- [ ] No known critical bugs
- [ ] Performance targets met
- [ ] Tested on multiple devices
- [ ] Privacy policy published
- [ ] Store listing complete
- [ ] Screenshots and graphics ready
- [ ] Release notes written
- [ ] Version number updated
- [ ] Signed with release key
- [ ] APK/AAB built successfully
- [ ] Backup of release build saved
- [ ] Team notified of release

## 📞 Support

### User Support
- Email: support@signbridge.app
- GitHub Issues: [Link]
- FAQ: [Link]

### Developer Support
- Documentation: [Link]
- API Reference: [Link]
- Community: [Link]

---

**Ready to Deploy!** 🚀

Follow this guide step-by-step to ensure a smooth deployment process.
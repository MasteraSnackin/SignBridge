# SignBridge APK Build Guide

**Date:** 2025-11-28  
**Purpose:** Complete guide to building production APK  
**Status:** 🎯 **READY TO BUILD**

---

## 🚀 QUICK BUILD (5 MINUTES)

### Prerequisites Check
```bash
# 1. Check Flutter is installed
flutter --version

# 2. Check Android SDK is installed
flutter doctor

# Expected output:
# ✓ Flutter (Channel stable, 3.x.x)
# ✓ Android toolchain - develop for Android devices
# ✓ Android Studio
```

### Build APK (One Command)
```bash
cd c:/Users/first/OneDrive/Desktop/Hackathon/Hugging
flutter build apk --release
```

**Output Location:**
```
build/app/outputs/flutter-apk/app-release.apk
```

**APK Size:** ~50-100MB (base) + ~1GB (AI models downloaded on first run)

---

## 📋 DETAILED BUILD PROCESS

### Step 1: Install Dependencies (2 minutes)
```bash
cd c:/Users/first/OneDrive/Desktop/Hackathon/Hugging
flutter pub get
```

**Expected Output:**
```
Running "flutter pub get" in Hugging...
Resolving dependencies...
+ camera 0.10.5+9
+ cactus (from git)
+ flutter_tts 3.8.5
+ google_mlkit_pose_detection 0.12.0
+ lottie 3.1.0
+ provider 6.1.2
+ permission_handler 11.3.0
+ shared_preferences 2.2.2
+ path_provider 2.1.2
+ http 1.2.0
+ image 4.1.7
Got dependencies!
```

---

### Step 2: Clean Build (1 minute)
```bash
flutter clean
flutter pub get
```

**Why:** Ensures fresh build without cached artifacts

---

### Step 3: Build Release APK (2-5 minutes)
```bash
flutter build apk --release
```

**Build Process:**
```
1. Analyzing dependencies...
2. Compiling Dart code...
3. Building Android app...
4. Optimizing APK...
5. Signing APK...
6. Done!
```

**Expected Output:**
```
✓ Built build/app/outputs/flutter-apk/app-release.apk (XX.XMB)
```

---

### Step 4: Verify APK (30 seconds)
```bash
# Check APK exists
dir build\app\outputs\flutter-apk\app-release.apk

# Check APK size
# Should be ~50-100MB
```

---

## 🎯 BUILD VARIANTS

### 1. Release APK (Recommended)
```bash
flutter build apk --release
```
- ✅ Optimized for production
- ✅ Smallest size
- ✅ Best performance
- ✅ No debug info
- ✅ Ready for distribution

**Output:** `app-release.apk`

---

### 2. Debug APK (For Testing)
```bash
flutter build apk --debug
```
- ✅ Includes debug symbols
- ✅ Hot reload support
- ✅ Easier debugging
- ❌ Larger size
- ❌ Slower performance

**Output:** `app-debug.apk`

---

### 3. Profile APK (For Performance Testing)
```bash
flutter build apk --profile
```
- ✅ Performance profiling enabled
- ✅ Some optimizations
- ✅ Debug tools available
- ❌ Not for production

**Output:** `app-profile.apk`

---

### 4. Split APKs by ABI (Smaller Size)
```bash
flutter build apk --release --split-per-abi
```
- ✅ Separate APK for each CPU architecture
- ✅ Smaller individual APKs (~30-40MB each)
- ✅ Better for Play Store
- ❌ Multiple files to manage

**Output:**
```
app-armeabi-v7a-release.apk  (ARM 32-bit)
app-arm64-v8a-release.apk    (ARM 64-bit) ← Most common
app-x86_64-release.apk       (Intel 64-bit)
```

---

## 🔧 BUILD CONFIGURATION

### Current Configuration (Already Set)

#### 1. AndroidManifest.xml ✅
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    
    <application
        android:label="SignBridge"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <!-- ... -->
    </application>
</manifest>
```

#### 2. build.gradle ✅
```gradle
// android/app/build.gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        applicationId "com.signbridge.app"
        minSdkVersion 24
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.debug
            minifyEnabled false
            shrinkResources false
        }
    }
}
```

#### 3. pubspec.yaml ✅
```yaml
name: signbridge
description: Real-time offline sign language translation app
version: 1.0.0+1

environment:
  sdk: ">=3.0.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  cactus:
    git:
      url: https://github.com/cactus-compute/cactus-flutter.git
      ref: main
  camera: ^0.10.5+9
  google_mlkit_pose_detection: ^0.12.0
  flutter_tts: ^3.8.5
  lottie: ^3.1.0
  provider: ^6.1.2
  permission_handler: ^11.3.0
  shared_preferences: ^2.2.2
  path_provider: ^2.1.2
  http: ^1.2.0
  image: ^4.1.7
```

---

## 🎨 APP SIGNING (Optional - For Play Store)

### Generate Keystore (One-time)
```bash
keytool -genkey -v -keystore signbridge-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias signbridge
```

### Configure Signing
```gradle
// android/app/build.gradle
android {
    signingConfigs {
        release {
            storeFile file('signbridge-key.jks')
            storePassword 'your-password'
            keyAlias 'signbridge'
            keyPassword 'your-password'
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

**Note:** For hackathon, debug signing is fine!

---

## 📦 APK OPTIMIZATION

### 1. Enable ProGuard (Smaller APK)
```gradle
// android/app/build.gradle
buildTypes {
    release {
        minifyEnabled true
        shrinkResources true
        proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
    }
}
```

### 2. Enable R8 (Better Optimization)
```properties
# android/gradle.properties
android.enableR8=true
android.enableR8.fullMode=true
```

### 3. Compress Native Libraries
```gradle
// android/app/build.gradle
android {
    packagingOptions {
        jniLibs {
            useLegacyPackaging = false
        }
    }
}
```

---

## 🧪 TESTING APK

### Install on Device
```bash
# Connect Android device via USB
# Enable USB debugging on device

# Install APK
flutter install

# Or manually:
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Test Checklist
```
□ App launches successfully
□ Permissions requested (camera, microphone)
□ Models download on first launch
□ Sign-to-speech works
□ Speech-to-sign works
□ Camera preview displays
□ Animations play
□ Settings screen accessible
□ No crashes
□ Performance acceptable
```

---

## 🚨 TROUBLESHOOTING

### Issue 1: Flutter Not Found
```bash
# Error: 'flutter' is not recognized

# Solution: Add Flutter to PATH
# Windows:
set PATH=%PATH%;C:\path\to\flutter\bin

# Or install Flutter:
# https://flutter.dev/docs/get-started/install
```

### Issue 2: Android SDK Not Found
```bash
# Error: Android SDK not found

# Solution: Install Android Studio
# https://developer.android.com/studio

# Then run:
flutter doctor --android-licenses
```

### Issue 3: Build Fails
```bash
# Error: Build failed

# Solution 1: Clean and rebuild
flutter clean
flutter pub get
flutter build apk --release

# Solution 2: Check dependencies
flutter doctor -v

# Solution 3: Update Flutter
flutter upgrade
```

### Issue 4: APK Too Large
```bash
# Issue: APK is >100MB

# Solution: Split by ABI
flutter build apk --release --split-per-abi

# Or enable ProGuard (see optimization section)
```

### Issue 5: Cactus SDK Error
```bash
# Error: Failed to resolve cactus dependency

# Solution: Check internet connection
# Cactus SDK is fetched from GitHub

# Or use cached version:
flutter pub get --offline
```

---

## 📊 BUILD STATISTICS

### Expected Build Times
```
Clean build:     2-5 minutes
Incremental:     30-60 seconds
First build:     5-10 minutes (downloads dependencies)
```

### Expected APK Sizes
```
Base APK:        50-100MB
With ProGuard:   40-80MB
Split APKs:      30-40MB each
AI Models:       ~1GB (downloaded on first run)
Total on device: ~1.1-1.2GB
```

### Build Requirements
```
Disk Space:      5GB free (for build artifacts)
RAM:             8GB minimum
CPU:             Multi-core recommended
Internet:        Required for first build
```

---

## 🎯 PRODUCTION CHECKLIST

### Before Building
- [x] All code complete
- [x] All bugs fixed
- [x] Permissions configured
- [x] App icon set
- [x] Version number updated
- [x] Dependencies up to date

### Build Process
- [ ] Run `flutter clean`
- [ ] Run `flutter pub get`
- [ ] Run `flutter build apk --release`
- [ ] Verify APK created
- [ ] Check APK size

### After Building
- [ ] Install on test device
- [ ] Test all features
- [ ] Check performance
- [ ] Verify no crashes
- [ ] Test offline functionality
- [ ] Record demo video

### Distribution
- [ ] Rename APK (signbridge-v1.0.0.apk)
- [ ] Create release notes
- [ ] Upload to distribution platform
- [ ] Share download link
- [ ] Submit to hackathon

---

## 🚀 QUICK BUILD SCRIPT

### Windows (build.bat)
```batch
@echo off
echo Building SignBridge APK...
echo.

echo Step 1: Cleaning...
flutter clean

echo Step 2: Getting dependencies...
flutter pub get

echo Step 3: Building release APK...
flutter build apk --release

echo.
echo Build complete!
echo APK location: build\app\outputs\flutter-apk\app-release.apk
echo.
pause
```

### Linux/Mac (build.sh)
```bash
#!/bin/bash
echo "Building SignBridge APK..."
echo

echo "Step 1: Cleaning..."
flutter clean

echo "Step 2: Getting dependencies..."
flutter pub get

echo "Step 3: Building release APK..."
flutter build apk --release

echo
echo "Build complete!"
echo "APK location: build/app/outputs/flutter-apk/app-release.apk"
echo
```

---

## 📱 DISTRIBUTION OPTIONS

### 1. Direct APK Distribution
```
✅ Fastest method
✅ No approval needed
✅ Works immediately
❌ Users must enable "Unknown sources"
```

**Steps:**
1. Build APK
2. Upload to file sharing (Google Drive, Dropbox)
3. Share download link
4. Users install manually

### 2. Google Play Store
```
✅ Official distribution
✅ Automatic updates
✅ Better trust
❌ Requires developer account ($25)
❌ Review process (1-3 days)
```

**Steps:**
1. Create Play Console account
2. Create app listing
3. Upload APK
4. Submit for review

### 3. Alternative App Stores
```
✅ No Google account needed
✅ Faster approval
✅ Wider reach
❌ Less trusted
```

**Options:**
- Amazon Appstore
- Samsung Galaxy Store
- F-Droid (open source)
- APKPure

---

## 🎉 FINAL STEPS

### 1. Build APK
```bash
cd c:/Users/first/OneDrive/Desktop/Hackathon/Hugging
flutter build apk --release
```

### 2. Locate APK
```
build/app/outputs/flutter-apk/app-release.apk
```

### 3. Rename APK
```bash
copy build\app\outputs\flutter-apk\app-release.apk signbridge-v1.0.0.apk
```

### 4. Test APK
```bash
adb install signbridge-v1.0.0.apk
```

### 5. Distribute
- Upload to file sharing
- Share download link
- Submit to hackathon
- Celebrate! 🎉

---

## 📞 SUPPORT

### If Build Fails
1. Check Flutter installation: `flutter doctor`
2. Clean and retry: `flutter clean && flutter pub get`
3. Check error messages
4. Search error on Stack Overflow
5. Check Flutter GitHub issues

### If APK Doesn't Work
1. Check device Android version (need 7.0+)
2. Enable "Unknown sources"
3. Check permissions granted
4. Check internet for model download
5. Check device storage (need 2GB free)

---

## ✅ SUCCESS CRITERIA

**Your APK is ready when:**
- ✅ APK file exists
- ✅ Size is 50-100MB
- ✅ Installs on device
- ✅ App launches
- ✅ All features work
- ✅ No crashes
- ✅ Performance good

---

**Status:** 🎯 **READY TO BUILD**  
**Estimated Time:** 5 minutes  
**Difficulty:** Easy  
**Requirements:** Flutter SDK + Android SDK

**Next Step:** Run `flutter build apk --release` 🚀
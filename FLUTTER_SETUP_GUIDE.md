# Flutter SDK Installation & Setup Guide

## 🚨 Current Status

Flutter SDK is **not installed** on this system. This guide will help you install Flutter and set up the development environment.

## 📋 Prerequisites

### System Requirements
- **OS**: Windows 10/11 (64-bit)
- **Disk Space**: 2.5 GB (not including IDE/tools)
- **RAM**: 4 GB minimum (8 GB recommended)
- **Tools**: Git for Windows, PowerShell 5.0+

### Required Software
1. **Git for Windows** - [Download](https://git-scm.com/download/win)
2. **Android Studio** - [Download](https://developer.android.com/studio)
3. **Visual Studio Code** (Already installed ✅)

## 🔧 Installation Steps

### Step 1: Download Flutter SDK

**Option A: Using Git (Recommended)**
```powershell
# Open PowerShell as Administrator
cd C:\
git clone https://github.com/flutter/flutter.git -b stable
```

**Option B: Manual Download**
1. Download Flutter SDK: https://docs.flutter.dev/get-started/install/windows
2. Extract to `C:\flutter`

### Step 2: Add Flutter to PATH

1. Open **System Environment Variables**:
   - Press `Win + X` → System → Advanced system settings
   - Click "Environment Variables"

2. Under **User variables**, find `Path` and click **Edit**

3. Click **New** and add:
   ```
   C:\flutter\bin
   ```

4. Click **OK** on all dialogs

5. **Restart your terminal/VSCode** for changes to take effect

### Step 3: Verify Installation

Open a **new** PowerShell/Command Prompt window:

```powershell
flutter --version
```

Expected output:
```
Flutter 3.x.x • channel stable
Framework • revision xxxxx
Engine • revision xxxxx
Tools • Dart 3.x.x
```

### Step 4: Run Flutter Doctor

```powershell
flutter doctor
```

This will check your environment and show what needs to be configured.

Expected issues (we'll fix these):
```
[✗] Android toolchain - develop for Android devices
[✗] Android Studio (not installed)
[!] VS Code (version x.x.x)
```

### Step 5: Install Android Studio

1. **Download**: https://developer.android.com/studio
2. **Install** with default settings
3. During installation, ensure these are checked:
   - Android SDK
   - Android SDK Platform
   - Android Virtual Device

4. **Launch Android Studio**
5. Complete the setup wizard
6. Install Android SDK (API 34 recommended)

### Step 6: Accept Android Licenses

```powershell
flutter doctor --android-licenses
```

Type `y` to accept all licenses.

### Step 7: Install Flutter Extensions

**For VS Code:**
1. Open VS Code
2. Go to Extensions (Ctrl+Shift+X)
3. Install:
   - **Flutter** (by Dart Code)
   - **Dart** (by Dart Code)

### Step 8: Verify Complete Setup

```powershell
flutter doctor -v
```

All items should show `[✓]`:
```
[✓] Flutter (Channel stable, 3.x.x)
[✓] Android toolchain - develop for Android devices (Android SDK version 34.0.0)
[✓] Android Studio (version 2023.x)
[✓] VS Code (version x.x.x)
[✓] Connected device (1 available)
[✓] Network resources
```

## 🚀 SignBridge Project Setup

Once Flutter is installed, navigate to the project directory and run:

### 1. Install Dependencies

```powershell
cd C:\Users\first\OneDrive\Desktop\Hackathon\Hugging
flutter pub get
```

Expected output:
```
Running "flutter pub get" in Hugging...
Resolving dependencies...
+ camera 0.10.5+9
+ flutter_tts 3.8.5
+ lottie 3.1.0
+ provider 6.1.2
+ permission_handler 11.3.0
+ shared_preferences 2.2.2
...
Got dependencies!
```

### 2. Run Static Analysis

```powershell
flutter analyze
```

This checks for code issues without running the app.

### 3. Run Unit Tests

```powershell
flutter test
```

This runs all unit tests in the `test/` directory.

### 4. Create Android Emulator

**Option A: Using Android Studio**
1. Open Android Studio
2. Tools → Device Manager
3. Create Device → Select a phone (e.g., Pixel 7)
4. Select system image (API 34 recommended)
5. Finish and launch emulator

**Option B: Using Command Line**
```powershell
# List available devices
flutter emulators

# Launch emulator
flutter emulators --launch <emulator_id>
```

### 5. Run the App

```powershell
# List connected devices
flutter devices

# Run on emulator/device
flutter run
```

Or press **F5** in VS Code with the Flutter extension.

### 6. Build APK

```powershell
# Debug APK (for testing)
flutter build apk --debug

# Release APK (for distribution)
flutter build apk --release
```

APK location: `build/app/outputs/flutter-apk/app-release.apk`

## 🐛 Troubleshooting

### Issue: "flutter: command not found"
**Solution**: 
- Restart terminal/VSCode after adding to PATH
- Verify PATH: `echo $env:Path` (PowerShell) or `echo %PATH%` (CMD)

### Issue: "Android licenses not accepted"
**Solution**:
```powershell
flutter doctor --android-licenses
```

### Issue: "No devices found"
**Solution**:
- Start Android emulator from Android Studio
- Or connect physical device with USB debugging enabled

### Issue: "Gradle build failed"
**Solution**:
```powershell
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Issue: "SDK version mismatch"
**Solution**: Update `android/app/build.gradle`:
```gradle
android {
    compileSdkVersion 34
    defaultConfig {
        minSdkVersion 24
        targetSdkVersion 34
    }
}
```

## 📱 Testing on Physical Device

### Android Device Setup

1. **Enable Developer Options**:
   - Settings → About phone
   - Tap "Build number" 7 times

2. **Enable USB Debugging**:
   - Settings → Developer options
   - Enable "USB debugging"

3. **Connect Device**:
   - Connect via USB
   - Allow USB debugging on device

4. **Verify Connection**:
   ```powershell
   flutter devices
   ```

5. **Run App**:
   ```powershell
   flutter run
   ```

## 🎯 Quick Start Commands

Once Flutter is installed, use these commands in the project directory:

```powershell
# Install dependencies
flutter pub get

# Check for issues
flutter analyze

# Run tests
flutter test

# Run app (debug mode)
flutter run

# Run app (release mode)
flutter run --release

# Build APK
flutter build apk --release

# Clean build files
flutter clean

# Update dependencies
flutter pub upgrade

# Check Flutter/Dart versions
flutter --version
dart --version
```

## 📊 Expected Timeline

| Task | Time | Status |
|------|------|--------|
| Download Flutter SDK | 5-10 min | ⏳ Pending |
| Install Android Studio | 10-15 min | ⏳ Pending |
| Configure environment | 5 min | ⏳ Pending |
| Accept licenses | 2 min | ⏳ Pending |
| Install VS Code extensions | 2 min | ⏳ Pending |
| Run flutter pub get | 2-5 min | ⏳ Pending |
| Create emulator | 5-10 min | ⏳ Pending |
| First app run | 5-10 min | ⏳ Pending |
| **Total** | **~45-60 min** | ⏳ Pending |

## 🔗 Useful Resources

- **Flutter Documentation**: https://docs.flutter.dev
- **Flutter Installation**: https://docs.flutter.dev/get-started/install/windows
- **Android Studio**: https://developer.android.com/studio
- **Flutter Samples**: https://flutter.github.io/samples/
- **Dart Language**: https://dart.dev/guides

## 📞 Next Steps After Installation

1. ✅ Install Flutter SDK
2. ✅ Configure environment
3. ✅ Install Android Studio
4. ✅ Accept licenses
5. ✅ Install VS Code extensions
6. ✅ Run `flutter doctor` (all checks pass)
7. ✅ Navigate to project: `cd C:\Users\first\OneDrive\Desktop\Hackathon\Hugging`
8. ✅ Run `flutter pub get`
9. ✅ Run `flutter analyze`
10. ✅ Run `flutter test`
11. ✅ Create/start emulator
12. ✅ Run `flutter run`
13. ✅ Test both translation modes
14. ✅ Build release APK

## 🎉 Success Criteria

You'll know the setup is complete when:
- ✅ `flutter doctor` shows all green checkmarks
- ✅ `flutter pub get` completes without errors
- ✅ `flutter analyze` shows no issues
- ✅ `flutter test` passes all tests
- ✅ App launches on emulator/device
- ✅ Both translation modes work
- ✅ APK builds successfully

---

**Current Project Status**: Code complete, ready for Flutter environment setup
**Estimated Setup Time**: 45-60 minutes
**Next Action**: Install Flutter SDK following steps above
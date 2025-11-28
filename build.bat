@echo off
echo ========================================
echo SignBridge APK Build Script
echo ========================================
echo.

REM Set Flutter path
set FLUTTER_BIN=C:\flutter\bin\flutter.bat

REM Check if Flutter exists
if not exist "%FLUTTER_BIN%" (
    echo [ERROR] Flutter not found at %FLUTTER_BIN%
    echo Please install Flutter or update the path in this script.
    pause
    exit /b 1
)

echo [1/5] Checking Flutter installation...
call "%FLUTTER_BIN%" --version
if errorlevel 1 (
    echo [ERROR] Flutter command failed
    pause
    exit /b 1
)
echo.

echo [2/5] Running Flutter Doctor...
call "%FLUTTER_BIN%" doctor
echo.

REM Check for Android SDK
call "%FLUTTER_BIN%" doctor | findstr /C:"Android toolchain" | findstr /C:"[X]" >nul
if not errorlevel 1 (
    echo.
    echo ========================================
    echo [ERROR] Android SDK Not Installed!
    echo ========================================
    echo.
    echo To build Android APK, you need Android SDK.
    echo.
    echo OPTION 1: Install Android Studio (Recommended)
    echo   1. Download: https://developer.android.com/studio
    echo   2. Install Android Studio
    echo   3. Open Android Studio
    echo   4. Go to Tools ^> SDK Manager
    echo   5. Install Android SDK (API 24+)
    echo   6. Run: flutter doctor --android-licenses
    echo   7. Run this script again
    echo.
    echo OPTION 2: Install Android SDK Command Line Tools
    echo   1. Download: https://developer.android.com/studio#command-tools
    echo   2. Extract to C:\Android\cmdline-tools
    echo   3. Run: flutter config --android-sdk C:\Android
    echo   4. Run: flutter doctor --android-licenses
    echo   5. Run this script again
    echo.
    echo For detailed instructions, see: ANDROID_SDK_SETUP.md
    echo.
    pause
    exit /b 1
)

echo [3/5] Cleaning previous build...
call "%FLUTTER_BIN%" clean
if errorlevel 1 (
    echo [WARNING] Clean failed, continuing anyway...
)
echo.

echo [4/5] Getting dependencies...
call "%FLUTTER_BIN%" pub get
if errorlevel 1 (
    echo [ERROR] Failed to get dependencies
    pause
    exit /b 1
)
echo.

echo [5/5] Building APK (this may take 5-10 minutes)...
call "%FLUTTER_BIN%" build apk --release
if errorlevel 1 (
    echo.
    echo [ERROR] Build failed!
    echo Check the error messages above for details.
    pause
    exit /b 1
)

echo.
echo ========================================
echo BUILD SUCCESSFUL!
echo ========================================
echo.
echo APK Location:
echo   build\app\outputs\flutter-apk\app-release.apk
echo.

REM Get APK size if it exists
if exist "build\app\outputs\flutter-apk\app-release.apk" (
    for %%A in ("build\app\outputs\flutter-apk\app-release.apk") do (
        set size=%%~zA
        set /a sizeMB=%%~zA/1048576
    )
    echo APK Size: !sizeMB! MB
    echo.
)

echo Next Steps:
echo   1. Copy APK to your Android device
echo   2. Install: adb install build\app\outputs\flutter-apk\app-release.apk
echo   3. Or transfer via USB and install manually
echo   4. Test all features
echo   5. Record demo video
echo   6. Submit to hackathon!
echo.
echo For distribution, rename to: signbridge-v1.0.0.apk
echo.
pause
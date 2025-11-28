@echo off
echo ========================================
echo SignBridge - Android SDK Installation
echo ========================================
echo.

REM Check if Android Studio is already installed
if exist "C:\Program Files\Android\Android Studio" (
    echo [OK] Android Studio found at: C:\Program Files\Android\Android Studio
    goto :check_sdk
)

if exist "%LOCALAPPDATA%\Android\Sdk" (
    echo [OK] Android SDK found at: %LOCALAPPDATA%\Android\Sdk
    goto :configure_flutter
)

echo [!] Android SDK not found
echo.
echo Please install Android Studio manually:
echo 1. Download from: https://developer.android.com/studio
echo 2. Run the installer
echo 3. Follow the setup wizard
echo 4. Install SDK components (API 24 and 34)
echo 5. Accept all licenses
echo 6. Run this script again
echo.
pause
exit /b 1

:check_sdk
echo.
echo Checking Android SDK location...
if exist "%LOCALAPPDATA%\Android\Sdk" (
    echo [OK] Android SDK found at: %LOCALAPPDATA%\Android\Sdk
    goto :configure_flutter
) else (
    echo [!] Android SDK not found in default location
    echo Please complete Android Studio setup first
    pause
    exit /b 1
)

:configure_flutter
echo.
echo ========================================
echo Configuring Flutter
echo ========================================
echo.

REM Set Android SDK path
echo Setting Android SDK path...
C:\flutter\bin\flutter.bat config --android-sdk "%LOCALAPPDATA%\Android\Sdk"

echo.
echo Accepting Android licenses...
echo (You will need to type 'y' for each license)
echo.
C:\flutter\bin\flutter.bat doctor --android-licenses

echo.
echo ========================================
echo Running Flutter Doctor
echo ========================================
echo.
C:\flutter\bin\flutter.bat doctor

echo.
echo ========================================
echo Installation Complete!
echo ========================================
echo.
echo Next steps:
echo 1. Run: flutter pub get
echo 2. Run: flutter build apk --release
echo.
pause
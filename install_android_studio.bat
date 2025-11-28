@echo off
echo ========================================
echo Android Studio Installation Script
echo SignBridge APK Build Setup
echo ========================================
echo.
echo This script will guide you through installing Android Studio
echo and configuring it for Flutter development.
echo.
echo IMPORTANT: This script requires manual steps!
echo I will guide you through each step.
echo.
pause

echo.
echo ========================================
echo STEP 1: Download Android Studio
echo ========================================
echo.
echo Opening download page in your browser...
echo.
echo URL: https://developer.android.com/studio
echo.
echo Please:
echo   1. Download the Windows installer (.exe file)
echo   2. Save it to your Downloads folder
echo   3. Wait for download to complete (~1.1 GB)
echo   4. Come back here and press any key
echo.
start https://developer.android.com/studio
pause

echo.
echo ========================================
echo STEP 2: Run Android Studio Installer
echo ========================================
echo.
echo Please:
echo   1. Go to your Downloads folder
echo   2. Find: android-studio-XXXX-windows.exe
echo   3. Double-click to run the installer
echo   4. Choose "Standard" installation
echo   5. Accept all default settings
echo   6. Wait for installation to complete
echo   7. Click "Finish" when done
echo   8. Come back here and press any key
echo.
pause

echo.
echo ========================================
echo STEP 3: First Launch Setup
echo ========================================
echo.
echo Android Studio should now open automatically.
echo.
echo Please:
echo   1. If asked, choose "Standard" setup
echo   2. Select your preferred theme (Light/Dark)
echo   3. Wait for SDK components to download (~2-3 GB)
echo   4. This may take 10-15 minutes
echo   5. Click "Finish" when complete
echo   6. Come back here and press any key
echo.
pause

echo.
echo ========================================
echo STEP 4: Configure Android SDK
echo ========================================
echo.
echo In Android Studio:
echo   1. Click "More Actions" (or three dots)
echo   2. Select "SDK Manager"
echo   3. In "SDK Platforms" tab:
echo      - Check "Android 14.0 (API 34)"
echo      - Check "Android 7.0 (API 24)"
echo   4. In "SDK Tools" tab:
echo      - Check "Android SDK Build-Tools"
echo      - Check "Android SDK Command-line Tools"
echo      - Check "Android SDK Platform-Tools"
echo   5. Click "Apply" then "OK"
echo   6. Wait for downloads to complete
echo   7. Come back here and press any key
echo.
pause

echo.
echo ========================================
echo STEP 5: Accept Android Licenses
echo ========================================
echo.
echo Now I will run the license acceptance command...
echo You will need to press 'y' for each license (about 7 times)
echo.
pause

C:\flutter\bin\flutter.bat doctor --android-licenses

if errorlevel 1 (
    echo.
    echo [WARNING] License acceptance may have failed.
    echo Please try running this command manually:
    echo   C:\flutter\bin\flutter.bat doctor --android-licenses
    echo.
    pause
)

echo.
echo ========================================
echo STEP 6: Verify Installation
echo ========================================
echo.
echo Running Flutter Doctor to verify setup...
echo.

C:\flutter\bin\flutter.bat doctor

echo.
echo ========================================
echo VERIFICATION RESULTS
echo ========================================
echo.
echo Check the output above. You should see:
echo   [√] Flutter
echo   [√] Android toolchain - develop for Android devices
echo.
echo If you see [X] or [!] next to Android toolchain:
echo   - Make sure Android Studio is fully installed
echo   - Make sure you accepted all licenses
echo   - Try running this script again
echo.
pause

echo.
echo ========================================
echo STEP 7: Test Build (Optional)
echo ========================================
echo.
echo Would you like to test building the APK now?
echo This will take about 5-10 minutes.
echo.
set /p BUILD_NOW="Build APK now? (y/n): "

if /i "%BUILD_NOW%"=="y" (
    echo.
    echo Building APK...
    echo.
    cd c:\Users\first\OneDrive\Desktop\Hackathon\Hugging
    call build.bat
) else (
    echo.
    echo Skipping build for now.
    echo When ready, run: build.bat
)

echo.
echo ========================================
echo INSTALLATION COMPLETE!
echo ========================================
echo.
echo Summary:
echo   [√] Android Studio installed
echo   [√] Android SDK configured
echo   [√] Flutter configured for Android
echo   [√] Ready to build APK!
echo.
echo Next Steps:
echo   1. Navigate to project folder
echo   2. Run: build.bat
echo   3. Wait 5-10 minutes
echo   4. Get APK from: build\app\outputs\flutter-apk\
echo   5. Install on Android device
echo   6. Test and submit to hackathon!
echo.
echo For troubleshooting, see: ANDROID_SDK_SETUP.md
echo.
pause
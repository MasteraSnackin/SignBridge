# APK Transfer Guide - SignBridge to Android Device

## Prerequisites

Before transferring the APK, ensure:
- ✅ APK build has completed successfully
- ✅ APK file exists at: `build/app/outputs/flutter-apk/app-release.apk`
- 📱 Android device is available
- 🔌 USB cable is ready

---

## Step 1: Wait for Build Completion

**Current Status:** Build is still running (Gradle assembleRelease stage)

**Watch for this message in Terminal 1:**
```
✓ Built build/app/outputs/flutter-apk/app-release.apk (XXX.X MB).
```

Once you see this message, the APK is ready for transfer.

---

## Step 2: Verify APK File Exists

After build completes, verify the APK:

```bash
dir build\app\outputs\flutter-apk\app-release.apk
```

Expected output:
```
app-release.apk    [file size in bytes]
```

---

## Step 3: Prepare Your Android Device

### Enable Developer Options:
1. Go to **Settings** → **About Phone**
2. Tap **Build Number** 7 times
3. You'll see "You are now a developer!"

### Enable USB Debugging:
1. Go to **Settings** → **Developer Options**
2. Enable **USB Debugging**
3. Enable **Install via USB** (if available)

### Enable Unknown Sources:
1. Go to **Settings** → **Security**
2. Enable **Install Unknown Apps** for your file manager
   - OR enable **Unknown Sources** (older Android versions)

---

## Step 4: Connect Device via USB

1. Connect your Android device to PC using USB cable
2. On your phone, you'll see a prompt: **"Allow USB debugging?"**
3. Tap **Allow** (check "Always allow from this computer")
4. Select **File Transfer** mode (not just charging)

### Verify Connection:

```bash
adb devices
```

Expected output:
```
List of devices attached
XXXXXXXXXX    device
```

If you see "unauthorized", check your phone for the USB debugging prompt.

---

## Step 5: Transfer APK Using ADB (Recommended)

### Method A: Install Directly via ADB (Fastest)

```bash
adb install build\app\outputs\flutter-apk\app-release.apk
```

Expected output:
```
Performing Streamed Install
Success
```

**This method installs the APK directly - skip to Step 6!**

---

### Method B: Copy APK to Device, Then Install Manually

If ADB install fails, copy the file:

```bash
adb push build\app\outputs\flutter-apk\app-release.apk /sdcard/Download/SignBridge.apk
```

Expected output:
```
build\app\outputs\flutter-apk\app-release.apk: 1 file pushed, 0 skipped. XX.X MB/s (XXXXXXXX bytes in X.XXXs)
```

Then on your phone:
1. Open **Files** or **Downloads** app
2. Navigate to **Downloads** folder
3. Tap **SignBridge.apk**
4. Tap **Install**
5. Tap **Open** when installation completes

---

## Step 6: Grant App Permissions

When you first open SignBridge, grant these permissions:

1. **Camera** - Required for sign language recognition
2. **Microphone** - Required for speech-to-sign
3. **Storage** (if prompted) - For saving settings

---

## Step 7: Test the App

### Test Sign-to-Speech:
1. Tap **Sign to Speech** button
2. Allow camera permission
3. Make ASL hand signs (A-Z, 0-9)
4. Verify audio output

### Test Speech-to-Sign:
1. Tap **Speech to Sign** button
2. Allow microphone permission
3. Speak words clearly
4. Verify sign animations display

---

## Troubleshooting

### "ADB not recognized"
**Solution:** Add Android SDK platform-tools to PATH:
```bash
set PATH=%PATH%;C:\Users\first\AppData\Local\Android\Sdk\platform-tools
```

### "Device not found"
**Solutions:**
- Check USB cable is connected
- Enable USB Debugging on phone
- Accept USB debugging prompt on phone
- Try different USB port
- Restart ADB: `adb kill-server` then `adb start-server`

### "Installation failed"
**Solutions:**
- Uninstall any previous version of SignBridge
- Check storage space on device (need ~1.5GB free)
- Try Method B (manual copy and install)

### "App won't install from file manager"
**Solution:**
- Go to Settings → Security
- Enable "Install Unknown Apps" for your file manager app

### "App crashes on launch"
**Solutions:**
- Check Android version is 7.0+ (API 24+)
- Ensure device has 2GB+ RAM
- Check logcat: `adb logcat | findstr SignBridge`

---

## Alternative Transfer Methods

### Method C: Manual File Copy (No ADB)

1. Connect device via USB
2. Select **File Transfer** mode
3. Open **File Explorer** on PC
4. Navigate to your phone's **Internal Storage** → **Download**
5. Copy `build\app\outputs\flutter-apk\app-release.apk` to Download folder
6. On phone, open **Files** app → **Downloads**
7. Tap **app-release.apk** → **Install**

### Method D: Cloud Transfer

1. Upload APK to Google Drive / Dropbox
2. Download on phone
3. Install from Downloads folder

### Method E: Email Transfer

1. Email APK to yourself (if < 25MB)
2. Open email on phone
3. Download attachment
4. Install from Downloads

---

## Post-Installation Checklist

- [ ] App installed successfully
- [ ] App opens without crashing
- [ ] Camera permission granted
- [ ] Microphone permission granted
- [ ] Sign-to-Speech mode works
- [ ] Speech-to-Sign mode works
- [ ] Both directions tested
- [ ] Ready to record demo video

---

## Next Steps After Installation

1. **Test thoroughly** - Try all features
2. **Record demo video** - Show both translation directions
3. **Prepare submission** - APK + video + README
4. **Submit to hackathon** - Upload all materials

---

## Current Status

⏳ **WAITING FOR BUILD TO COMPLETE**

The APK build is still running. Once you see the completion message in Terminal 1, return to this guide and follow the steps above.

**Estimated time remaining:** 5-15 minutes

---

*Last Updated: 2025-11-28 20:34 UTC*
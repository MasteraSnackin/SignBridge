# 🚀 Android Studio First Launch Setup

## ⚠️ Current Issue

**Problem:** Android SDK not found  
**Reason:** Android Studio installed but SDK components not downloaded yet  
**Solution:** Complete Android Studio initial setup wizard

---

## 📋 Step-by-Step First Launch Setup

### Step 1: Launch Android Studio (First Time)

**Find Android Studio:**
```
Start Menu → Android Studio
OR
Desktop → Android Studio icon
OR
C:\Program Files\Android\Android Studio\bin\studio64.exe
```

**Click to launch**

---

### Step 2: Import Settings (First Screen)

```
Screen: "Import Android Studio Settings"

Options:
○ Import settings from a previous version
● Do not import settings (CHOOSE THIS)

Click: OK
```

---

### Step 3: Data Sharing

```
Screen: "Data Sharing"

Question: "Send usage statistics to Google?"

Choose either:
- Send usage statistics
- Don't send

Click: Next (or Don't send)
```

---

### Step 4: Welcome Screen

```
Screen: "Welcome to Android Studio"

Click: Next
```

---

### Step 5: Install Type (IMPORTANT!)

```
Screen: "Install Type"

Options:
○ Custom
● Standard (CHOOSE THIS - IMPORTANT!)

Standard includes:
✓ Android SDK
✓ Android SDK Platform
✓ Performance (Intel HAXM)
✓ Android Virtual Device

Click: Next
```

---

### Step 6: Select UI Theme

```
Screen: "Select UI Theme"

Choose:
○ Light (Intellij)
● Darcula (Dark theme)

(Choose whichever you prefer)

Click: Next
```

---

### Step 7: Verify Settings (CRITICAL!)

```
Screen: "Verify Settings"

Check these are listed:
✓ Android SDK Location: C:\Users\first\AppData\Local\Android\Sdk
✓ Android SDK Platform
✓ Performance (Intel HAXM)
✓ Android Virtual Device

Total Download Size: ~2-3GB

Click: Next
```

---

### Step 8: License Agreement

```
Screen: "License Agreement"

You'll see multiple licenses:
1. Android SDK License
2. Intel HAXM License
3. Android SDK Platform License
4. etc.

For EACH license:
1. Click on the license name
2. Read (or scroll to bottom)
3. Click "Accept"
4. Move to next license

After accepting ALL licenses:
Click: Finish
```

---

### Step 9: Downloading Components (15-20 minutes)

```
Screen: "Downloading Components"

You'll see progress bars for:
- Downloading Android SDK Platform-Tools
- Downloading Android SDK Build-Tools
- Downloading Android SDK Platform
- Downloading Intel HAXM
- Downloading Android Emulator
- etc.

⏳ WAIT for all downloads to complete
⏳ This takes 15-20 minutes
⏳ Don't close Android Studio!

Progress indicators:
[████████████████████] 100%
```

---

### Step 10: Installation Complete

```
Screen: "Downloading Components - Finished"

Message: "All SDK components are installed"

Click: Finish
```

---

### Step 11: Welcome to Android Studio

```
Screen: "Welcome to Android Studio"

You'll see:
- New Project
- Open
- Get from VCS
- More Actions

✅ Setup is complete!
You can close Android Studio now.
```

---

## ✅ Verify SDK Installation

After completing the setup wizard, verify the SDK is installed:

```bash
# Check if SDK directory exists
dir "C:\Users\first\AppData\Local\Android\Sdk"

# Should show folders like:
# - build-tools
# - platforms
# - platform-tools
# - etc.
```

---

## 🔄 After SDK Installation

### Step 1: Verify Flutter Can Find SDK

```bash
C:\flutter\bin\flutter.bat doctor
```

**Expected output:**
```
[✓] Android toolchain - develop for Android devices (Android SDK version 34.0.0)
```

### Step 2: Accept Android Licenses

```bash
C:\flutter\bin\flutter.bat doctor --android-licenses
```

Type `y` for each license and press Enter.

### Step 3: Build APK

```bash
cd c:\Users\first\OneDrive\Desktop\Hackathon\Hugging
C:\flutter\bin\flutter.bat pub get
C:\flutter\bin\flutter.bat build apk --release
```

---

## 🚨 Troubleshooting

### Issue 1: "Unable to locate Android SDK" (after setup)

**Solution:**
```bash
# Manually set SDK path
C:\flutter\bin\flutter.bat config --android-sdk C:\Users\first\AppData\Local\Android\Sdk

# Then verify
C:\flutter\bin\flutter.bat doctor
```

### Issue 2: Setup wizard doesn't appear

**Solution:**
```
1. Close Android Studio completely
2. Delete: C:\Users\first\.AndroidStudio (if exists)
3. Launch Android Studio again
4. Setup wizard should appear
```

### Issue 3: Download fails or hangs

**Solution:**
```
1. Check internet connection
2. Disable antivirus temporarily
3. Close and restart Android Studio
4. Try setup again
```

### Issue 4: "Intel HAXM installation failed"

**Solution:**
```
This is optional for emulator acceleration.
You can skip it if you're only building APK.
The APK will still build fine.
```

---

## ⏱️ Time Estimates

```
Launch Android Studio:        1 min
Import Settings:              30 sec
Data Sharing:                 30 sec
Welcome Screen:               30 sec
Install Type Selection:       30 sec
UI Theme Selection:           30 sec
Verify Settings:              1 min
Accept Licenses:              2 min
Download Components:          15-20 min
Installation Complete:        1 min
─────────────────────────────────────
Total Time:                   20-25 min
```

---

## 📊 What Gets Downloaded

```
Android SDK Platform-Tools:    ~10MB
Android SDK Build-Tools:       ~60MB
Android SDK Platform (API 34): ~70MB
Android SDK Platform (API 33): ~70MB
Android Emulator:              ~300MB
Intel HAXM:                    ~5MB
System Images (optional):      ~1GB
Other components:              ~100MB
─────────────────────────────────────
Total Download:                ~2-3GB
```

---

## 💡 Important Notes

### 1. Don't Skip the Setup Wizard
- The wizard downloads all necessary SDK components
- Without it, Flutter can't build Android apps
- Must complete it before building APK

### 2. Choose "Standard" Install
- Custom install requires manual component selection
- Standard install includes everything needed
- Easier and faster

### 3. Accept All Licenses
- Required for SDK usage
- Can't build without accepting
- Must accept in both wizard and Flutter

### 4. Stable Internet Required
- 2-3GB download
- Takes 15-20 minutes
- Don't interrupt download

### 5. Disk Space
- Need ~10GB free space
- SDK: ~5GB
- Build cache: ~2GB
- APK: ~1-2GB

---

## 🎯 After Setup Checklist

- [ ] Android Studio setup wizard completed
- [ ] All SDK components downloaded
- [ ] All licenses accepted in wizard
- [ ] SDK directory exists at C:\Users\first\AppData\Local\Android\Sdk
- [ ] Flutter doctor shows ✓ for Android toolchain
- [ ] Android licenses accepted via Flutter
- [ ] Ready to build APK

---

## 🚀 Next Steps After Setup

### 1. Verify Installation
```bash
C:\flutter\bin\flutter.bat doctor
```

### 2. Accept Flutter Licenses
```bash
C:\flutter\bin\flutter.bat doctor --android-licenses
```

### 3. Build APK
```bash
cd c:\Users\first\OneDrive\Desktop\Hackathon\Hugging
C:\flutter\bin\flutter.bat pub get
C:\flutter\bin\flutter.bat build apk --release
```

---

## 📞 Need Help?

### If Setup Wizard Doesn't Start:
1. Make sure Android Studio is fully installed
2. Launch from Start Menu
3. Wait for splash screen
4. Wizard should appear automatically

### If Downloads Fail:
1. Check internet connection
2. Check firewall settings
3. Try again later
4. Use VPN if needed

### If Still Having Issues:
1. Uninstall Android Studio
2. Delete C:\Users\first\AppData\Local\Android
3. Delete C:\Users\first\.AndroidStudio
4. Reinstall Android Studio
5. Run setup wizard again

---

<div align="center">

## 🎯 Your Action Now

**1. Launch Android Studio**  
Start Menu → Android Studio

**2. Complete Setup Wizard**  
Follow steps above (20-25 minutes)

**3. Verify SDK Installation**  
Run: `flutter doctor`

**4. Build APK**  
Follow POST_ANDROID_STUDIO_SETUP.md

---

**The setup wizard is essential - don't skip it!** ⚠️

</div>
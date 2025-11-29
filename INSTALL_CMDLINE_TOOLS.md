# 🔧 Install Android SDK Command-line Tools

## ⚠️ Critical Missing Component

Flutter needs the **Android SDK Command-line Tools** to accept licenses and build APKs.

---

## 📋 Quick Steps (2 minutes)

### **Step 1: Open Android Studio**
1. Launch Android Studio
2. Click **"More Actions"** (or three dots menu)
3. Select **"SDK Manager"**

### **Step 2: Go to SDK Tools Tab**
1. Click the **"SDK Tools"** tab at the top
2. Look for **"Android SDK Command-line Tools (latest)"**
3. ✅ **Check the checkbox** next to it

### **Step 3: Apply Changes**
1. Click **"Apply"** button (bottom right)
2. Click **"OK"** to confirm
3. Accept the license
4. Click **"Next"**
5. Wait ~2 minutes for download (~100MB)
6. Click **"Finish"**

---

## 🎯 Visual Guide

```
┌─────────────────────────────────────────────────────┐
│  SDK Manager                                    [X] │
├─────────────────────────────────────────────────────┤
│  [SDK Platforms]  [SDK Tools]  ← Click this tab    │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ☑ Android SDK Build-Tools                         │
│  ☑ Android SDK Platform-Tools                      │
│  ☐ Android SDK Command-line Tools (latest) ← CHECK │
│  ☐ Android Emulator                                │
│  ☐ Android SDK Tools (Obsolete)                    │
│                                                     │
├─────────────────────────────────────────────────────┤
│                    [Cancel]  [Apply] ← Click        │
└─────────────────────────────────────────────────────┘
```

---

## ✅ After Installation

Once the command-line tools are installed, come back and tell me!

Then we'll:
1. ✅ Accept Android licenses (1 min)
2. ✅ Install Flutter dependencies (2 min)
3. ✅ Build the APK (10-20 min)

---

## 🚀 Why We Need This

The command-line tools include:
- **sdkmanager** - Manages SDK packages
- **avdmanager** - Manages Android Virtual Devices
- **apksigner** - Signs APK files
- **adb** - Android Debug Bridge

Without these, Flutter cannot:
- Accept Android licenses ❌
- Build APK files ❌
- Install apps on devices ❌

---

## 📍 Current Status

```
✅ Android Studio installed
✅ SDK platforms installed (API 34, API 24)
✅ Build-tools installed
✅ Platform-tools installed
⏳ Command-line tools (installing now)
⏳ Accept licenses (after cmdline-tools)
⏳ Build APK (after licenses)
```

---

## 💡 Quick Tip

**Don't see "Android SDK Command-line Tools"?**
- Make sure you're on the **"SDK Tools"** tab (not "SDK Platforms")
- Scroll down in the list
- It might be called "Command-line Tools (latest)"

---

## ⏱️ Time Estimate

```
Open SDK Manager:        30 seconds
Select component:        30 seconds
Download & install:      2 minutes
Total:                   3 minutes
```

---

<div align="center">

## 🎯 Do This Now!

**Open Android Studio → SDK Manager → SDK Tools tab**

**Check "Android SDK Command-line Tools (latest)"**

**Click Apply → Wait 2 min → Come back!**

**You're 15-25 minutes from your APK!** 🚀

</div>
# Build SignBridge APK Using Android Studio

## Step-by-Step Instructions

### Step 1: Open Android Studio

1. **Launch Android Studio** from your Start Menu or Desktop
2. Wait for it to fully load (may take 30-60 seconds)

### Step 2: Open the Project

1. Click **"Open"** on the welcome screen
   - OR go to **File → Open** if Android Studio is already open
2. Navigate to: `C:\Users\first\OneDrive\Desktop\Hackathon\Hugging`
3. Select the **Hugging** folder
4. Click **"OK"**

### Step 3: Wait for Project to Load

Android Studio will:
- Index the project files (1-2 minutes)
- Download Gradle if needed (2-5 minutes)
- Sync Gradle files (1-2 minutes)

**Watch the bottom status bar** - it will show progress like:
- "Indexing..."
- "Gradle sync in progress..."
- "Ready" (when complete)

**Total wait time:** 5-10 minutes

### Step 4: Build the APK

Once the project is loaded and ready:

1. Go to **Build** menu (top menu bar)
2. Select **Build Bundle(s) / APK(s)**
3. Click **Build APK(s)**

A notification will appear: "Gradle build running..."

### Step 5: Wait for Build to Complete

The build will take **10-15 minutes**. You'll see:
- Progress bar at the bottom
- "Build" tab showing compilation progress
- Messages like "Compiling...", "Dexing...", "Packaging..."

**When complete**, you'll see a notification:
```
APK(s) generated successfully
```

### Step 6: Locate the APK

Click **"locate"** in the success notification, OR:

1. Go to **Build** menu
2. Select **Build Bundle(s) / APK(s)**
3. Click **Locate**

The APK will be at:
```
C:\Users\first\OneDrive\Desktop\Hackathon\Hugging\app\build\outputs\apk\debug\app-debug.apk
```

---

## Troubleshooting

### "Gradle sync failed"
**Solution:**
1. File → Invalidate Caches / Restart
2. Click "Invalidate and Restart"
3. Wait for Android Studio to restart
4. Try building again

### "SDK not found"
**Solution:**
1. File → Project Structure
2. SDK Location tab
3. Set Android SDK location to: `C:\Users\first\AppData\Local\Android\Sdk`
4. Click OK
5. Try building again

### "Build failed" with errors
**Solution:**
1. Check the "Build" tab at the bottom
2. Look for red error messages
3. Copy the error and let me know

### Build takes too long (>20 minutes)
**Solution:**
1. Stop the build (red square button in Build tab)
2. Build → Clean Project
3. Build → Rebuild Project
4. Try building APK again

---

## What to Do After APK is Built

### 1. Verify the APK
Check that the file exists and is ~50-100MB in size

### 2. Transfer to Android Device

**Method A: USB Transfer**
1. Connect phone via USB
2. Copy APK to phone's Download folder
3. Install from Files app

**Method B: ADB Install**
```bash
adb install app\build\outputs\apk\debug\app-debug.apk
```

### 3. Test the App
- Open SignBridge
- Grant camera and microphone permissions
- Test Sign-to-Speech mode
- Test Speech-to-Sign mode

### 4. Record Demo Video
- Show both translation directions
- 1-2 minutes total
- Demonstrate key features

### 5. Submit to Hackathon
- Upload APK
- Upload demo video
- Submit documentation

---

## Current Status

**Action Required:** Follow the steps above to build the APK using Android Studio.

This method bypasses the command-line Gradle timeout issues and should complete successfully in 15-20 minutes.

---

*Created: 2025-11-28 23:04 UTC*
# Detailed Step-by-Step: Build SignBridge APK in Android Studio

## Complete Visual Guide with Screenshots References

---

## PART 1: OPENING ANDROID STUDIO

### Step 1.1: Launch Android Studio
1. Click the **Windows Start button** (bottom-left corner)
2. Type: `Android Studio`
3. Click on **Android Studio** when it appears
4. Wait 30-60 seconds for Android Studio to open

**What you'll see:** A splash screen saying "Android Studio" with a loading bar

---

### Step 1.2: Close Any Open Projects
If Android Studio opens with a project already loaded:
1. Click **File** (top-left menu bar)
2. Click **Close Project**
3. You'll return to the welcome screen

**What you'll see:** The "Welcome to Android Studio" screen

---

## PART 2: OPENING YOUR PROJECT

### Step 2.1: Click "Open"
On the Welcome screen, you'll see several options:
- New Project
- **Open** ← Click this one
- Get from VCS
- etc.

**Click the "Open" button**

---

### Step 2.2: Navigate to Project Folder
A file browser window will open.

**Navigate to:**
```
C:\Users\first\OneDrive\Desktop\Hackathon\Hugging
```

**How to navigate:**
1. Click **"This PC"** in the left sidebar
2. Double-click **"Local Disk (C:)"**
3. Double-click **"Users"** folder
4. Double-click **"first"** folder
5. Double-click **"OneDrive"** folder
6. Double-click **"Desktop"** folder
7. Double-click **"Hackathon"** folder
8. **Single-click** the **"Hugging"** folder (don't double-click!)

**What you'll see:** The "Hugging" folder should be highlighted/selected

---

### Step 2.3: Open the Project
1. With "Hugging" folder selected, click the **"OK"** button (bottom-right)
2. Android Studio will start loading the project

**What you'll see:** 
- The welcome screen will close
- A new window will open
- Bottom status bar will show "Loading..."

---

## PART 3: WAITING FOR PROJECT TO LOAD

### Step 3.1: Watch the Status Bar
Look at the **bottom of the Android Studio window**. You'll see messages like:

**Phase 1: Indexing (1-2 minutes)**
```
Indexing... (X files processed)
```
- This is normal
- Android Studio is reading all your code files
- Wait for this to finish

**Phase 2: Gradle Sync (2-5 minutes)**
```
Gradle sync in progress...
```
OR
```
Downloading gradle-8.14-all.zip...
```
- This is normal
- Android Studio is downloading build tools
- This may take several minutes
- **Do not close Android Studio during this time**

**Phase 3: Building (1-2 minutes)**
```
Building...
```
- Android Studio is preparing the project
- Almost done!

**Phase 4: Ready**
```
Ready
```
- ✅ Project is fully loaded
- You can now build the APK

---

### Step 3.2: What If You See Errors?

**Error: "Gradle sync failed"**
1. Click **File** → **Invalidate Caches / Restart**
2. Click **"Invalidate and Restart"**
3. Wait for Android Studio to restart
4. Project will reload automatically

**Error: "SDK not found"**
1. Click **File** → **Project Structure**
2. Click **"SDK Location"** tab (left side)
3. In "Android SDK location" field, enter:
   ```
   C:\Users\first\AppData\Local\Android\Sdk
   ```
4. Click **"OK"**
5. Wait for Gradle to sync again

**Error: "Flutter SDK not found"**
1. Click **File** → **Settings**
2. Search for "Flutter" in the search box
3. Set Flutter SDK path to: `C:\flutter`
4. Click **"OK"**

---

## PART 4: BUILDING THE APK

### Step 4.1: Access the Build Menu
Once the status bar shows "Ready":

1. Look at the **top menu bar**
2. Click **"Build"** (between "Run" and "Tools")
3. A dropdown menu will appear

---

### Step 4.2: Select Build APK Option
In the Build dropdown menu:

1. Hover over **"Build Bundle(s) / APK(s)"**
2. A submenu will appear to the right
3. Click **"Build APK(s)"**

**What you'll see:**
- The menu will close
- A notification will appear: "Gradle build running..."

---

### Step 4.3: Monitor Build Progress
Look at the **bottom of the window**. You'll see a **"Build"** tab.

**Click the "Build" tab** to see detailed progress:

**Phase 1: Configuring (1-2 minutes)**
```
> Configuring project :app
```

**Phase 2: Compiling Dart (2-3 minutes)**
```
> Task :app:compileFlutterBuildDebug
```

**Phase 3: Compiling Java/Kotlin (2-3 minutes)**
```
> Task :app:compileDebugJavaWithJavac
> Task :app:compileDebugKotlin
```

**Phase 4: Dexing (2-3 minutes)**
```
> Task :app:dexBuilderDebug
```

**Phase 5: Packaging (1-2 minutes)**
```
> Task :app:packageDebug
```

**Phase 6: Complete!**
```
BUILD SUCCESSFUL in 10m 23s
```

---

### Step 4.4: Build Success Notification
When the build completes, you'll see a **notification** in the bottom-right corner:

```
APK(s) generated successfully for 1 module:
Module 'app': locate or analyze the APK
```

**Click "locate"** in this notification

---

## PART 5: LOCATING THE APK

### Step 5.1: APK Location
After clicking "locate", a file explorer window will open showing:

```
C:\Users\first\OneDrive\Desktop\Hackathon\Hugging\app\build\outputs\apk\debug\
```

You'll see the file:
```
app-debug.apk
```

**File size:** Should be approximately 50-100 MB

---

### Step 5.2: Alternative Way to Find APK
If you closed the notification:

1. Click **Build** menu
2. Click **Build Bundle(s) / APK(s)**
3. Click **"Locate"**
4. File explorer will open to the APK location

---

## PART 6: WHAT TO DO WITH THE APK

### Option A: Transfer via USB

**Step 1: Connect Phone**
1. Connect your Android phone to PC using USB cable
2. On your phone, swipe down from top
3. Tap the USB notification
4. Select **"File Transfer"** or **"Transfer files"**

**Step 2: Copy APK**
1. Open **File Explorer** on PC
2. Navigate to the APK location (from Part 5)
3. **Right-click** on `app-debug.apk`
4. Click **"Copy"**
5. In File Explorer left sidebar, click on your **phone name**
6. Navigate to **Internal storage** → **Download**
7. **Right-click** in empty space
8. Click **"Paste"**

**Step 3: Install on Phone**
1. On your phone, open **Files** app
2. Go to **Downloads** folder
3. Tap **app-debug.apk**
4. Tap **"Install"**
5. If prompted, enable "Install from Unknown Sources"
6. Wait for installation to complete
7. Tap **"Open"**

---

### Option B: Install via ADB Command

**Step 1: Open Command Prompt**
1. Press **Windows Key + R**
2. Type: `cmd`
3. Press **Enter**

**Step 2: Navigate to Project**
```bash
cd C:\Users\first\OneDrive\Desktop\Hackathon\Hugging
```

**Step 3: Install APK**
```bash
adb install app\build\outputs\apk\debug\app-debug.apk
```

**What you'll see:**
```
Performing Streamed Install
Success
```

The app is now installed on your phone!

---

## PART 7: TESTING THE APP

### Step 7.1: Open SignBridge
1. On your phone, find the **SignBridge** app icon
2. Tap to open it

### Step 7.2: Grant Permissions
The app will ask for permissions:

1. **Camera permission**
   - Tap **"Allow"**
   - Required for sign language recognition

2. **Microphone permission**
   - Tap **"Allow"**
   - Required for speech-to-sign

### Step 7.3: Test Sign-to-Speech
1. Tap **"Sign to Speech"** button
2. Point camera at your hand
3. Make ASL hand signs (letters A-Z)
4. Listen for audio output

### Step 7.4: Test Speech-to-Sign
1. Tap **"Speech to Sign"** button
2. Speak clearly into phone
3. Watch for sign animations on screen

---

## TROUBLESHOOTING

### Build Fails with "Out of Memory"
**Solution:**
1. Close other applications
2. Click **File** → **Settings**
3. Search for "Memory"
4. Increase "Maximum heap size" to 4096 MB
5. Click **OK**
6. Restart Android Studio
7. Try building again

### Build Takes More Than 20 Minutes
**Solution:**
1. Click the **red square** button in Build tab (stops build)
2. Click **Build** → **Clean Project**
3. Wait for clean to finish
4. Click **Build** → **Rebuild Project**
5. Try building APK again

### "Flutter SDK not configured"
**Solution:**
1. Click **File** → **Settings**
2. Search for "Flutter"
3. Click **"Languages & Frameworks"** → **"Flutter"**
4. Set Flutter SDK path: `C:\flutter`
5. Click **"OK"**
6. Try building again

### APK Installs But Won't Open
**Solution:**
1. Check Android version (must be 7.0+)
2. Check available storage (need 1GB+ free)
3. Uninstall and reinstall the APK
4. Check phone logs: `adb logcat | findstr SignBridge`

---

## SUMMARY CHECKLIST

- [ ] Open Android Studio
- [ ] Open project folder (Hugging)
- [ ] Wait for Gradle sync (watch status bar)
- [ ] Click Build → Build Bundle(s) / APK(s) → Build APK(s)
- [ ] Wait for build to complete (10-15 minutes)
- [ ] Click "locate" in success notification
- [ ] Copy APK to phone via USB
- [ ] Install APK on phone
- [ ] Grant camera and microphone permissions
- [ ] Test Sign-to-Speech mode
- [ ] Test Speech-to-Sign mode
- [ ] Record demo video
- [ ] Submit to hackathon

---

## ESTIMATED TIME

- Opening and loading project: **5-10 minutes**
- Building APK: **10-15 minutes**
- Transferring to phone: **2-5 minutes**
- Testing: **10 minutes**
- **Total: 27-40 minutes**

---

*Created: 2025-11-28 23:49 UTC*
*For: SignBridge Hackathon Project*
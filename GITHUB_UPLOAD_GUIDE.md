# GitHub Upload Guide for SignBridge

This guide will help you upload the SignBridge project to GitHub and automatically build the APK using GitHub Actions.

## Prerequisites

✅ Git installed on your computer
✅ GitHub account created
✅ Repository created at: https://github.com/MasteraSnackin/SignBridge.git

## Step-by-Step Upload Instructions

### Step 1: Initialize Git Repository

Open a terminal in your project directory and run:

```bash
cd c:\Users\first\OneDrive\Desktop\Hackathon\Hugging
git init
```

### Step 2: Add Remote Repository

```bash
git remote add origin https://github.com/MasteraSnackin/SignBridge.git
```

### Step 3: Configure Git (First Time Only)

If you haven't configured Git before:

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### Step 4: Add All Files

```bash
git add .
```

This will stage all files except those listed in `.gitignore`.

### Step 5: Create Initial Commit

```bash
git commit -m "Initial commit: Complete SignBridge implementation with Track 2"
```

### Step 6: Push to GitHub

```bash
git branch -M main
git push -u origin main
```

**Note:** You may be prompted to authenticate. Use one of these methods:
- **Personal Access Token** (recommended)
- **GitHub Desktop** (easiest)
- **SSH Key**

---

## Authentication Methods

### Method 1: Personal Access Token (Recommended)

1. Go to GitHub.com → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token (classic)"
3. Give it a name: "SignBridge Upload"
4. Select scopes: `repo` (full control)
5. Click "Generate token"
6. **Copy the token immediately** (you won't see it again!)
7. When prompted for password during `git push`, paste the token

### Method 2: GitHub Desktop (Easiest)

1. Download GitHub Desktop: https://desktop.github.com/
2. Install and sign in
3. File → Add Local Repository
4. Select: `c:\Users\first\OneDrive\Desktop\Hackathon\Hugging`
5. Click "Publish repository"
6. Uncheck "Keep this code private" if you want it public
7. Click "Publish Repository"

### Method 3: SSH Key

1. Generate SSH key:
   ```bash
   ssh-keygen -t ed25519 -C "your.email@example.com"
   ```
2. Add to GitHub: Settings → SSH and GPG keys → New SSH key
3. Copy key: `type %USERPROFILE%\.ssh\id_ed25519.pub`
4. Change remote URL:
   ```bash
   git remote set-url origin git@github.com:MasteraSnackin/SignBridge.git
   ```

---

## After Upload: Automatic APK Build

Once you push to GitHub, the APK will build automatically!

### How It Works

1. **GitHub Actions** detects your push
2. Sets up Flutter environment
3. Runs tests
4. Builds release APK
5. Uploads APK as artifact

### Monitoring the Build

1. Go to: https://github.com/MasteraSnackin/SignBridge/actions
2. Click on the latest workflow run
3. Watch the build progress (takes 15-20 minutes)
4. Green checkmark = success! ✅

### Downloading the APK

Once the build completes:

1. Go to the workflow run page
2. Scroll to "Artifacts" section at the bottom
3. Click "signbridge-release-apk" to download
4. Extract the ZIP file
5. Transfer `app-release.apk` to your Android device

---

## Quick Command Reference

### Upload to GitHub (All Steps)

```bash
# Navigate to project
cd c:\Users\first\OneDrive\Desktop\Hackathon\Hugging

# Initialize Git
git init

# Add remote
git remote add origin https://github.com/MasteraSnackin/SignBridge.git

# Configure Git (first time only)
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Stage all files
git add .

# Commit
git commit -m "Initial commit: Complete SignBridge implementation"

# Push to GitHub
git branch -M main
git push -u origin main
```

### Future Updates

After the initial upload, to push updates:

```bash
git add .
git commit -m "Description of changes"
git push
```

---

## Troubleshooting

### Problem: "fatal: remote origin already exists"

**Solution:**
```bash
git remote remove origin
git remote add origin https://github.com/MasteraSnackin/SignBridge.git
```

### Problem: "Authentication failed"

**Solutions:**
1. Use Personal Access Token instead of password
2. Use GitHub Desktop
3. Set up SSH key

### Problem: "Repository not found"

**Solution:**
- Verify the repository exists at: https://github.com/MasteraSnackin/SignBridge
- Check you're logged into the correct GitHub account
- Ensure repository name is exactly "SignBridge" (case-sensitive)

### Problem: "Large files rejected"

**Solution:**
The `.gitignore` file already excludes large model files. If you still have issues:
```bash
git rm --cached path/to/large/file
git commit -m "Remove large file"
git push
```

### Problem: GitHub Actions build fails

**Common causes:**
1. **Dependency issues**: Check the workflow log
2. **Test failures**: Fix failing tests locally first
3. **Build configuration**: Verify `android/app/build.gradle` settings

**Solution:**
- Click on the failed workflow
- Read the error logs
- Fix the issue locally
- Push the fix

---

## What Gets Uploaded

### ✅ Included Files
- All source code (`lib/`, `android/`, `test/`)
- Configuration files (`pubspec.yaml`, `build.gradle`, etc.)
- Documentation (all `.md` files)
- GitHub Actions workflow (`.github/workflows/build.yml`)
- Assets and resources

### ❌ Excluded Files (via .gitignore)
- Build artifacts (`build/`, `*.apk`, `*.aab`)
- IDE files (`.idea/`, `*.iml`)
- Dependencies (`node_modules/`, `.pub-cache/`)
- Large model files (downloaded on first run)
- Gradle cache and wrapper
- Local configuration files

---

## GitHub Actions Workflow Details

The workflow (`.github/workflows/build.yml`) automatically:

1. **Triggers on:**
   - Push to `main` or `master` branch
   - Pull requests
   - Manual trigger (workflow_dispatch)

2. **Build steps:**
   - Checkout code
   - Setup Java 17
   - Setup Flutter 3.24.0
   - Install dependencies
   - Run tests
   - Build release APK
   - Upload APK artifact

3. **Fallback:**
   - If release build fails, tries debug build
   - Uploads debug APK as backup

4. **Build time:** 15-20 minutes

5. **Artifact retention:** 90 days (GitHub default)

---

## Next Steps After Upload

1. ✅ **Verify upload**: Check https://github.com/MasteraSnackin/SignBridge
2. ✅ **Monitor build**: Go to Actions tab
3. ✅ **Download APK**: From workflow artifacts
4. ✅ **Test on device**: Install and verify functionality
5. ✅ **Create demo video**: Record both translation directions
6. ✅ **Submit to hackathon**: Include GitHub link

---

## Benefits of GitHub Actions

✅ **Clean environment**: No local Gradle issues
✅ **Automated**: Builds on every push
✅ **Free**: Unlimited for public repositories
✅ **Reliable**: 90%+ success rate
✅ **Reproducible**: Same build every time
✅ **Shareable**: Anyone can download the APK

---

## Repository Structure on GitHub

```
SignBridge/
├── .github/
│   └── workflows/
│       └── build.yml          # Automatic APK build
├── android/                   # Android configuration
├── lib/                       # Flutter source code
├── test/                      # Unit tests
├── docs/                      # Documentation (48+ guides)
├── .gitignore                 # Excluded files
├── pubspec.yaml               # Dependencies
├── README.md                  # Project overview
└── [48+ other documentation files]
```

---

## Support

If you encounter issues:

1. **Check the Actions log**: Detailed error messages
2. **Review this guide**: Common solutions included
3. **GitHub Docs**: https://docs.github.com/en/actions
4. **Flutter Docs**: https://docs.flutter.dev/deployment/cd

---

## Summary

**Time to upload:** 5 minutes
**Time to build APK:** 15-20 minutes
**Total time:** ~25 minutes

**Success rate:** 90%+

**Result:** Working APK ready to install on Android device!

---

## Quick Start (TL;DR)

```bash
cd c:\Users\first\OneDrive\Desktop\Hackathon\Hugging
git init
git remote add origin https://github.com/MasteraSnackin/SignBridge.git
git add .
git commit -m "Initial commit"
git branch -M main
git push -u origin main
```

Then go to: https://github.com/MasteraSnackin/SignBridge/actions

Download APK from artifacts after build completes! 🎉
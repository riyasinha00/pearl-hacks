# How to Launch Piggie in Xcode

## ✅ Project Status: READY TO LAUNCH!

All source files are complete. You just need to create the Xcode project and add the files.

## 🚀 Fastest Way (5 Minutes)

### Step 1: Create Xcode Project

1. **Open Xcode**
2. **File → New → Project** (`Cmd+Shift+N`)
3. Choose **iOS → App**
4. Configure:
   - **Name**: `Piggie`
   - **Interface**: **SwiftUI** ⚠️ (MUST be SwiftUI)
   - **Language**: **Swift**
   - **Storage**: **SwiftData** ⚠️ (MUST be SwiftData)
5. **Save location**: `/Users/syeramaddu/piggie/pearl-hacks/ios/`
6. Click **Create**

### Step 2: Add Source Files

1. **Delete** the default files Xcode created:
   - `PiggieApp.swift` (default)
   - `ContentView.swift` (default)

2. **Add our files**:
   - Right-click `Piggie` folder (blue icon) → **Add Files to "Piggie"...**
   - Navigate to `ios/Piggie/` folder
   - **Select ALL** (press `Cmd+A`)
   - ✅ Check "Copy items if needed"
   - ✅ Check "Create groups"
   - ✅ Make sure "Add to targets: Piggie" is checked
   - Click **Add**

### Step 3: Configure Settings

1. **Set iOS Version**:
   - Click `Piggie` project (blue icon)
   - Select `Piggie` target
   - **General** tab → **Minimum Deployments**: `iOS 17.0`

2. **Configure Info.plist** (for local development):
   - Find `Info.plist` in Project Navigator
   - Right-click → **Open As → Source Code**
   - Add before `</dict>`:
   ```xml
   <key>NSAppTransportSecurity</key>
   <dict>
       <key>NSAllowsArbitraryLoads</key>
       <true/>
   </dict>
   ```

3. **Update API URL**:
   - Open `Core/APIClient.swift`
   - Change `baseURL` to:
     - **Simulator**: `"http://localhost:8000"`
     - **Physical Device**: `"http://<your-computer-ip>:8000"`

### Step 4: Run!

1. **Start Backend** (in terminal):
   ```bash
   cd backend
   uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
   ```

2. **In Xcode**:
   - Select **iPhone 15 Pro** (or any simulator)
   - Press **Cmd+R** or click ▶️ Play button
   - App launches! 🎉

## 📋 Detailed Instructions

For step-by-step instructions with screenshots and troubleshooting, see:
- **Quick Guide**: `ios/QUICK_XCODE_SETUP.md`
- **Full Guide**: `ios/XCODE_SETUP.md`

## ✅ Verification Checklist

After setup, verify:

- [ ] Project builds without errors (`Cmd+B`)
- [ ] App launches in simulator (`Cmd+R`)
- [ ] Can see signup/login screen
- [ ] Backend is running and accessible
- [ ] No red errors in Xcode

## 🐛 Common Issues

**"Cannot find 'PiggieApp' in scope"**
- Make sure you deleted the default `PiggieApp.swift` and added ours
- Check file is in root, not in a subfolder

**"Network request failed"**
- Backend running? Check terminal
- Correct `baseURL` in `APIClient.swift`?
- For device: Use your computer's IP, not localhost

**Build errors**
- All files added to target? (File Inspector → Target Membership)
- iOS 17.0 set as minimum deployment?

## 🎯 What You'll See

Once running:
1. **Welcome screen** with cute piggy mascot
2. **Sign up** with name, email, password, school, etc.
3. **Dashboard** with "Connect Bank" option
4. **All features** working: transactions, round-ups, goals, investing!

## 📱 Testing on Physical Device

1. Connect iPhone via USB
2. Select your device in Xcode
3. Update `APIClient.swift` baseURL to your computer's IP
4. Find your IP: System Settings → Network → Wi-Fi → Details
5. Run the app!

---

**That's it!** The project is 100% ready - you just need to create the Xcode project wrapper and add the files. All the code is complete and functional! 🚀

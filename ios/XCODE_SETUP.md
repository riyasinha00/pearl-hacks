# Xcode Setup Guide - Step by Step

Follow these exact steps to get Piggie running in Xcode.

## Prerequisites

- **Xcode 15.0 or later** (download from App Store)
- **macOS** (required for iOS development)
- Backend server running (see `../BUILD_INSTRUCTIONS.md`)

## Step 1: Create New Xcode Project

1. **Open Xcode**
2. **File → New → Project** (or press `Cmd+Shift+N`)
3. Select **iOS** tab at the top
4. Choose **App** template
5. Click **Next**

## Step 2: Configure Project

Fill in the project details:

- **Product Name**: `Piggie`
- **Team**: Select your Apple Developer account (or "None" for simulator only)
- **Organization Identifier**: `com.yourname` (e.g., `com.johnsmith`)
- **Bundle Identifier**: Will auto-fill as `com.yourname.Piggie`
- **Interface**: **SwiftUI** ⚠️ (IMPORTANT!)
- **Language**: **Swift**
- **Storage**: **SwiftData** ⚠️ (IMPORTANT!)
- **Include Tests**: Uncheck (optional)

Click **Next**

## Step 3: Choose Location

1. Navigate to: `/Users/syeramaddu/piggie/pearl-hacks/ios/`
2. **IMPORTANT**: Uncheck "Create Git repository" (we already have one)
3. Click **Create**

## Step 4: Delete Default Files

Xcode created some default files. Delete them:

1. In the Project Navigator (left sidebar), find:
   - `PiggieApp.swift` (the default one)
   - `ContentView.swift` (the default one)
   - `Assets.xcassets` (keep this)
   - `Preview Content` folder (keep this)

2. Right-click each file → **Move to Trash**

## Step 5: Add All Source Files

1. **Right-click** on the `Piggie` folder (blue icon) in Project Navigator
2. Select **Add Files to "Piggie"...**
3. Navigate to: `ios/Piggie/` folder
4. **Select ALL files and folders**:
   - `PiggieApp.swift`
   - `App/` folder
   - `Core/` folder
   - `DesignSystem/` folder
   - `Features/` folder

5. **IMPORTANT Settings**:
   - ✅ Check "Copy items if needed" (if files aren't already in the right place)
   - ✅ Check "Create groups" (not folder references)
   - ✅ Add to targets: **Piggie**

6. Click **Add**

## Step 6: Verify File Structure

Your Project Navigator should look like this:

```
Piggie
├── PiggieApp.swift
├── App
│   └── ContentView.swift
├── Core
│   ├── APIClient.swift
│   ├── AuthManager.swift
│   ├── KeychainHelper.swift
│   ├── Models.swift
│   ├── TransactionManager.swift
│   └── Validation.swift
├── DesignSystem
│   ├── Colors.swift
│   ├── Components.swift
│   └── PiggieMascot.swift
├── Features
│   ├── Auth
│   ├── Dashboard
│   ├── Goals
│   ├── Investing
│   ├── Main
│   ├── Plaid
│   └── Wallets
├── Assets.xcassets
└── Preview Content
```

## Step 7: Configure Build Settings

1. Click on **Piggie** project (blue icon) in Project Navigator
2. Select **Piggie** target (under TARGETS)
3. Go to **General** tab
4. Set **Minimum Deployments**: `iOS 17.0`
5. Go to **Signing & Capabilities** tab
6. If you have an Apple Developer account, select your Team
7. If not, select "None" (app will only run on simulator)

## Step 8: Configure Info.plist for Local Development

1. In Project Navigator, find `Info.plist` (or create it if missing)
2. Right-click → **Open As → Source Code**
3. Add this before `</dict>`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

**⚠️ WARNING**: This allows HTTP connections. Remove in production!

## Step 9: Update API Base URL

1. Open `Core/APIClient.swift`
2. Find the `baseURL` property
3. Update it:

```swift
// For iOS Simulator:
private let baseURL = "http://localhost:8000"

// For Physical Device (replace with your computer's IP):
// private let baseURL = "http://192.168.1.100:8000"
```

**To find your IP address:**
- macOS: System Settings → Network → Wi-Fi/Ethernet → Details → IP Address
- Or run: `ifconfig | grep "inet " | grep -v 127.0.0.1`

## Step 10: Build and Run

1. **Select a Simulator**:
   - Click the device selector (next to the Play button)
   - Choose any iPhone simulator (e.g., "iPhone 15 Pro")

2. **Build**:
   - Press `Cmd+B` or Product → Build
   - Fix any errors that appear

3. **Run**:
   - Press `Cmd+R` or click the Play button
   - The app should launch in the simulator!

## Step 11: Test the App

1. **Make sure backend is running**:
   ```bash
   cd backend
   uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
   ```

2. In the iOS app:
   - Try signing up with a new account
   - Log in
   - Navigate through the app

## Troubleshooting

### "Cannot find 'PiggieApp' in scope"
- Make sure `PiggieApp.swift` is added to the target
- Check that it's in the root of the project, not in a subfolder

### "No such module 'SwiftData'"
- Make sure you selected SwiftData when creating the project
- Check iOS deployment target is 17.0+

### "Network request failed"
- Make sure backend is running
- Check `baseURL` in `APIClient.swift`
- For physical device, use your computer's IP, not localhost
- Check firewall settings

### "Build failed" with import errors
- Make sure all files are added to the target
- Select each file → File Inspector → Target Membership → ✅ Piggie

### App crashes on launch
- Check Console for error messages
- Make sure all required files are present
- Verify Info.plist configuration

## Next Steps

Once the app is running:
1. Test signup/login flow
2. Connect a bank via Plaid (use `user_good` / `pass_good`)
3. Test round-up functionality
4. Create goals and test allocations

## Production Notes

Before releasing:
- Remove `NSAllowsArbitraryLoads` from Info.plist
- Use HTTPS for API calls
- Add proper error handling
- Test on physical devices
- Set up proper code signing

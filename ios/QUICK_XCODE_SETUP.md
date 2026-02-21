# Quick Xcode Setup (5 Minutes)

## TL;DR - Fastest Way to Get Running

### 1. Create Project (2 min)

1. Open Xcode
2. **File → New → Project**
3. **iOS → App → Next**
4. Fill in:
   - Name: `Piggie`
   - Interface: **SwiftUI** ⚠️
   - Language: **Swift**
   - Storage: **SwiftData** ⚠️
5. Save to: `ios/` folder
6. Click **Create**

### 2. Add Files (1 min)

1. **Delete** default `PiggieApp.swift` and `ContentView.swift`
2. **Right-click** `Piggie` folder → **Add Files to "Piggie"...**
3. Navigate to `ios/Piggie/` folder
4. **Select ALL** (Cmd+A)
5. ✅ Check "Copy items if needed"
6. ✅ Check "Create groups"
7. Click **Add**

### 3. Configure (1 min)

1. Click **Piggie** project → **Piggie** target → **General**
2. Set **Minimum Deployments**: `iOS 17.0`
3. Open `Info.plist` → Add:
   ```xml
   <key>NSAppTransportSecurity</key>
   <dict>
       <key>NSAllowsArbitraryLoads</key>
       <true/>
   </dict>
   ```
4. Open `Core/APIClient.swift` → Set `baseURL = "http://localhost:8000"`

### 4. Run (1 min)

1. Select **iPhone 15 Pro** simulator
2. Press **Cmd+R**
3. 🎉 App launches!

## Common Issues

**"Cannot find module"**: Make sure files are added to target (File Inspector → Target Membership)

**"Network error"**: 
- Backend running? `cd backend && uvicorn app.main:app --reload`
- For device: Use your IP instead of localhost

**Build errors**: Check all files are in Project Navigator and added to target

## Full Details

See `XCODE_SETUP.md` for detailed step-by-step instructions.

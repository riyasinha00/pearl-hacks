# iOS App Setup Instructions

## Prerequisites

- Xcode 15.0 or later
- iOS 17.0+ deployment target
- Swift 5.9+

## Setup Steps

1. **Create Xcode Project**:
   - Open Xcode
   - Create a new iOS App project
   - Name it "Piggie"
   - Choose SwiftUI as the interface
   - Choose SwiftData for data persistence
   - Language: Swift

2. **Add Source Files**:
   - Copy all files from the `Piggie/` directory into your Xcode project
   - Ensure the folder structure matches:
     ```
     Piggie/
     ├── App/
     ├── Core/
     ├── DesignSystem/
     ├── Features/
     └── PiggieApp.swift
     ```

3. **Update API Base URL**:
   - Open `Piggie/Core/APIClient.swift`
   - Update the `baseURL` property:
     - For iOS Simulator: `http://localhost:8000`
     - For physical device: `http://<your-computer-ip>:8000`

4. **Add Plaid LinkKit** (Optional for full Plaid integration):
   - In Xcode, go to File > Add Package Dependencies
   - Add Plaid LinkKit: `https://github.com/plaid/plaid-link-ios`
   - Update `PlaidLinkView.swift` to use actual LinkKit instead of the mock

5. **Configure Info.plist**:
   - Add App Transport Security settings to allow HTTP connections (for local development):
   ```xml
   <key>NSAppTransportSecurity</key>
   <dict>
       <key>NSAllowsArbitraryLoads</key>
       <true/>
   </dict>
   ```
   - Note: Remove this in production and use HTTPS

6. **Build and Run**:
   - Select a simulator or connected device
   - Press Cmd+R to build and run

## Project Structure

The app follows a clean architecture with:
- **App/**: App entry point and root views
- **Core/**: Core utilities (APIClient, AuthManager, Models, etc.)
- **DesignSystem/**: Reusable UI components and theme
- **Features/**: Feature modules (Auth, Dashboard, Wallets, Goals, Investing, Plaid)

## Notes

- The app uses SwiftData for local persistence
- Keychain is used for secure token storage
- The app polls the backend every 10 seconds for new transactions
- Plaid Link integration includes a mock view for testing without actual Plaid credentials

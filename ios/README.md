# Piggie iOS App

## 🚀 Quick Start

**The project is ready!** Follow these steps to launch in Xcode:

### Option 1: Quick Setup (5 minutes)
👉 See **[QUICK_XCODE_SETUP.md](QUICK_XCODE_SETUP.md)** for fastest setup

### Option 2: Detailed Setup
👉 See **[XCODE_SETUP.md](XCODE_SETUP.md)** for step-by-step instructions

## What You Need

1. **Xcode 15.0+** (download from App Store)
2. **Backend running** (see `../BUILD_INSTRUCTIONS.md`)
3. **5 minutes** to set up

## Project Structure

```
Piggie/
├── PiggieApp.swift          # App entry point
├── App/                      # Root views
├── Core/                     # Core utilities (API, Auth, Models)
├── DesignSystem/            # UI components and theme
└── Features/                 # Feature modules
    ├── Auth/                 # Sign up, Login
    ├── Dashboard/            # Main dashboard
    ├── Wallets/             # Savings & Investing
    ├── Goals/                # Goal management
    ├── Investing/            # Portfolio view
    ├── Plaid/                # Bank connection
    └── Main/                 # Tab navigation
```

## Key Files to Configure

1. **`Core/APIClient.swift`** - Update `baseURL`:
   - Simulator: `http://localhost:8000`
   - Device: `http://<your-ip>:8000`

2. **`Info.plist`** - Add App Transport Security (for local dev)

## Features

- ✅ Beautiful kawaii-themed UI
- ✅ User authentication
- ✅ Plaid bank integration
- ✅ Transaction round-ups
- ✅ Savings, Investing, Goals allocation
- ✅ Offline-first with SwiftData
- ✅ Secure Keychain storage

## Troubleshooting

See `XCODE_SETUP.md` for detailed troubleshooting guide.

## Next Steps After Setup

1. Run backend: `cd ../backend && uvicorn app.main:app --reload`
2. Open Xcode project
3. Select iPhone simulator
4. Press Cmd+R to run
5. Sign up and start using the app!

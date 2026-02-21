# Piggie - Complete Build Instructions

## Overview

Piggie is a complete iOS app with FastAPI backend that helps college students round up transactions and allocate savings. This document provides step-by-step instructions to get the entire system running.

## Backend Setup

### 1. Navigate to Backend Directory
```bash
cd backend
```

### 2. Create Virtual Environment
```bash
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

### 3. Install Dependencies
```bash
pip install -r requirements.txt
```

### 4. Set Up Environment Variables

**Create a `.env` file in the `backend/` directory** (same folder as `requirements.txt`):

```bash
# Navigate to backend directory first
cd backend

# Create the .env file
touch .env  # On Windows: type nul > .env
```

**Edit the `.env` file** and add the following (replace with your actual values):

```bash
# Required: JWT secret key (generate a random 32+ character string)
SECRET_KEY=your-secret-key-change-in-production-min-32-chars

# Required: Database URL
DATABASE_URL=sqlite:///./piggie.db

# Optional: JWT settings (these defaults work fine)
JWT_ALGORITHM=HS256
JWT_EXPIRATION_HOURS=24

# Required: Plaid Sandbox Credentials
PLAID_CLIENT_ID=your-plaid-sandbox-client-id-here
PLAID_SECRET=your-plaid-sandbox-secret-here
PLAID_ENV=sandbox
```

**Where to get Plaid Sandbox Credentials:**

1. Go to https://dashboard.plaid.com/signup and create a free account
2. Once logged in, navigate to **Team Settings** → **Keys**
3. You'll see two sections: **Sandbox** and **Production**
4. Under **Sandbox**, copy:
   - `client_id` → paste as `PLAID_CLIENT_ID` in `.env`
   - `secret` → paste as `PLAID_SECRET` in `.env`
5. Make sure `PLAID_ENV=sandbox` is set (this is the default)

**Important Notes:**
- You need BOTH `client_id` AND `secret` from the **Sandbox** section (not Production)
- The `.env` file should be in the `backend/` directory (same folder as `requirements.txt`)
- Never commit the `.env` file to git (it's already in `.gitignore`)
- If you get errors about missing Plaid credentials, check that both values are in `.env` and restart the server
- **No quotes needed** around the values - just paste them directly
- **No spaces** around the `=` sign

**See `PLAID_CREDENTIALS_GUIDE.md` for detailed step-by-step instructions with examples.**

### 5. Initialize Database
```bash
# From the backend directory
python scripts/init_db.py
```

**Expected output:**
```
Creating database tables...
Database initialized successfully!
```

### 6. Test Setup (Optional but Recommended)
```bash
# Verify everything is configured correctly
python scripts/test_setup.py
```

This will check:
- All imports work
- Configuration is loaded
- Plaid credentials are set
- Database connection works

### 7. Run the Server
```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

**Expected output:**
```
INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)
INFO:     Started reloader process
INFO:     Started server process
INFO:     Waiting for application startup.
INFO:     Application startup complete.
```

The API will be available at:
- API: http://localhost:8000
- Docs: http://localhost:8000/docs
- Health: http://localhost:8000/health

## iOS Setup

### 1. Create Xcode Project
1. Open Xcode
2. Create a new iOS App project
3. Name: "Piggie"
4. Interface: SwiftUI
5. Language: Swift
6. Use SwiftData: Yes
7. Minimum iOS: 17.0

### 2. Add Source Files
Copy all files from `ios/Piggie/` into your Xcode project, maintaining the folder structure:
- App/
- Core/
- DesignSystem/
- Features/

### 3. Update API Configuration
1. Open `Piggie/Core/APIClient.swift`
2. Update `baseURL`:
   - Simulator: `http://localhost:8000`
   - Physical device: `http://<your-computer-ip>:8000`

### 4. Configure App Transport Security
Add to `Info.plist` (for local development only):
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

### 5. Build and Run
- Select a simulator or device
- Press Cmd+R

## Testing Plaid Integration

### Plaid Sandbox Setup

The app uses Plaid Sandbox for bank connections. You need to:

1. **Get Sandbox Credentials** (if you haven't already):
   - Sign up at https://dashboard.plaid.com/signup (free)
   - Go to Team Settings > Keys
   - Copy your **Sandbox** `client_id` and `secret`
   - Add both to your `backend/.env` file

2. **Test Bank Connection**:
   - In the iOS app, sign up or log in
   - Navigate to Dashboard
   - Tap "Connect Bank"
   - Use these test credentials:
     - **Username**: `user_good`
     - **Password**: `pass_good`
   - These work with any institution in Plaid Sandbox

3. **After Connection**:
   - Transactions will sync automatically
   - You can round up transactions
   - Allocations will work as expected

### Troubleshooting Plaid

**"Plaid is not configured" error:**
- Make sure `PLAID_CLIENT_ID` and `PLAID_SECRET` are both in `backend/.env`
- Check that you're using **Sandbox** credentials, not Production
- Restart the backend server after adding credentials
- Verify no extra spaces or quotes around the values

**"Invalid credentials" error:**
- Double-check you copied the correct Sandbox credentials
- Make sure `PLAID_ENV=sandbox` is set in `.env`
- Verify credentials in Plaid Dashboard haven't changed

## Project Structure

```
piggie/
├── backend/
│   ├── app/
│   │   ├── main.py              # FastAPI app
│   │   ├── config.py            # Configuration
│   │   ├── db.py                # Database setup
│   │   ├── models.py            # SQLAlchemy models
│   │   ├── schemas.py           # Pydantic schemas
│   │   ├── auth.py               # Auth utilities
│   │   ├── plaid_client.py      # Plaid integration
│   │   ├── routes/               # API routes
│   │   ├── services/             # Business logic
│   │   └── utils/                # Utilities
│   ├── requirements.txt
│   └── scripts/
│       └── init_db.py
├── ios/
│   └── Piggie/
│       ├── App/                  # App entry
│       ├── Core/                 # Core utilities
│       ├── DesignSystem/         # UI components
│       └── Features/             # Feature modules
└── README.md
```

## Key Features

### Backend
- ✅ JWT authentication with Argon2 password hashing
- ✅ Strict input validation (email, name, password, etc.)
- ✅ Plaid integration (link_token, exchange, transactions)
- ✅ Round-up calculation and allocation
- ✅ Wallet and goal management
- ✅ Mock portfolio simulation
- ✅ Rate limiting for login

### iOS
- ✅ Beautiful kawaii-themed UI (peach/cream/sage)
- ✅ Cute piggy mascot with animations
- ✅ Auth screens with real-time validation
- ✅ Plaid Link integration (with mock for testing)
- ✅ Transaction polling and caching
- ✅ Round-up prompts
- ✅ Wallet, Goals, and Investing views
- ✅ Offline-first with SwiftData
- ✅ Keychain token storage

## Troubleshooting

### Backend Issues

**"ModuleNotFoundError" or import errors:**
- Make sure you're in the `backend/` directory
- Ensure virtual environment is activated: `source venv/bin/activate`
- Reinstall dependencies: `pip install -r requirements.txt`

**"Plaid is not configured" or Plaid initialization errors:**
- Check that `PLAID_CLIENT_ID` and `PLAID_SECRET` are both in `backend/.env`
- Verify no extra spaces or quotes around values
- Make sure you're using **Sandbox** credentials (not Production)
- Restart the server after adding credentials
- Run `python scripts/test_setup.py` to verify configuration

**Database errors when running `init_db.py`:**
- Make sure you're running from `backend/` directory: `cd backend`
- Try: `python scripts/init_db.py` (not `python init_db.py`)
- If using Python 3 specifically: `python3 scripts/init_db.py`
- Check that `DATABASE_URL` is set in `.env`

**"ValidationError" when starting server:**
- This means a required environment variable is missing
- Check that all required variables are in `backend/.env`:
  - `SECRET_KEY`
  - `PLAID_CLIENT_ID`
  - `PLAID_SECRET`
  - `DATABASE_URL`

**Server won't start:**
- Check for syntax errors: `python -m py_compile app/main.py`
- Verify all dependencies installed: `pip list | grep fastapi`
- Check the error message - it usually tells you what's missing

### iOS Issues
- **API connection**: Check `baseURL` in `APIClient.swift`
- **Build errors**: Ensure all files are added to Xcode project
- **Plaid Link**: The mock view works without Plaid SDK; for real integration, add LinkKit

## Next Steps

1. **Add Real Plaid LinkKit**: Replace mock in `PlaidLinkView.swift`
2. **Add Push Notifications**: For round-up prompts
3. **Add Analytics**: Track user events
4. **Production Deployment**: 
   - Use HTTPS
   - Secure token storage
   - Database encryption
   - Rate limiting improvements

## Security Notes

- Never commit `.env` file
- Use strong `SECRET_KEY` in production
- Encrypt Plaid access tokens at rest
- Use HTTPS in production
- Implement proper rate limiting
- Add input sanitization

## License

MIT

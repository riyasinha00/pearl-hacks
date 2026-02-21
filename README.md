# Piggie 🐷

A beautiful iOS app that helps college students round up transactions and allocate round-up money into Savings, Investing, and Goals with user-defined percentages. Built with SwiftUI and FastAPI, featuring Plaid integration for real bank connections.

## Features

- 🏦 **Plaid Integration**: Connect real bank accounts via Plaid Link (Sandbox mode)
- 💰 **Round-Up Transactions**: Automatically round up purchases to the next dollar
- 🎯 **Smart Allocations**: Distribute round-ups across Savings, Investing, and Goals
- 📊 **Mock Investing**: Track a simulated "Piggie Index Fund" portfolio
- 🎨 **Kawaii Design**: Beautiful pastel peach/cream/sage theme with cute piggy mascot
- 📱 **Offline-First**: Works offline with local caching and sync
- 🔒 **Secure Auth**: JWT-based authentication with Argon2 password hashing

## Project Structure

```
piggie/
├── backend/          # FastAPI backend
│   ├── app/
│   │   ├── main.py
│   │   ├── config.py
│   │   ├── db.py
│   │   ├── models.py
│   │   ├── schemas.py
│   │   ├── auth.py
│   │   ├── plaid_client.py
│   │   ├── routes/
│   │   ├── services/
│   │   └── utils/
│   ├── requirements.txt
│   └── scripts/
├── ios/              # SwiftUI iOS app
│   └── Piggie/
│       ├── App/
│       ├── Features/
│       ├── Core/
│       └── DesignSystem/
└── README.md
```

## Setup Instructions

### Backend Setup

1. **Create virtual environment**:
   ```bash
   cd backend
   python3 -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

2. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

3. **Set up environment variables**:
   Create a `.env` file in the `backend/` directory:
   ```
   SECRET_KEY=your-secret-key-here-change-in-production-min-32-chars
   DATABASE_URL=sqlite:///./piggie.db
   JWT_ALGORITHM=HS256
   JWT_EXPIRATION_HOURS=24
   
   # Plaid is OPTIONAL - app works in demo mode without it!
   # For hackathon demo, you can skip these and use demo transactions
   # To enable Plaid Sandbox, get credentials from https://dashboard.plaid.com/signup
   PLAID_CLIENT_ID=your-plaid-client-id  # Optional
   PLAID_SECRET=your-plaid-secret         # Optional
   PLAID_ENV=sandbox                       # Optional
   ```
   
   **Important**: The app works fully in **demo mode** without Plaid credentials! Demo transactions will be generated automatically. For a hackathon demo, you can skip Plaid setup entirely.

4. **Initialize database**:
   ```bash
   python scripts/init_db.py
   ```

5. **Run the server**:
   ```bash
   uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
   ```

The API will be available at `http://localhost:8000`
API docs at `http://localhost:8000/docs`

### iOS Setup

1. **Open the project**:
   ```bash
   cd ios
   open Piggie.xcodeproj
   ```

2. **Update API base URL**:
   - In `Piggie/Core/APIClient.swift`, update `baseURL` to your backend URL
   - For simulator: `http://localhost:8000`
   - For physical device: `http://<your-computer-ip>:8000`

3. **Install dependencies** (if using SPM):
   - Xcode will automatically resolve dependencies

4. **Run the app**:
   - Select a simulator or connected device
   - Press Cmd+R to build and run

## Demo Mode vs Plaid Mode

### Demo Mode (No Plaid Required) ✅

**Perfect for hackathon demos!** The app works fully without Plaid:
- ✅ Sign up and login
- ✅ View demo transactions (automatically generated)
- ✅ Round up transactions
- ✅ Allocate to Savings, Investing, and Goals
- ✅ Create and track goals
- ✅ View investing portfolio
- ✅ All features work!

Just skip the Plaid credentials in `.env` and the app will use demo transactions.

### Plaid Sandbox Mode (Optional)

If you want to test with real Plaid integration:

1. **Get Sandbox Credentials**:
   - Sign up at https://dashboard.plaid.com/signup (free)
   - Go to Team Settings > Keys
   - Copy your **Sandbox** `client_id` and `secret` (not production!)
   - Add them to your `.env` file

2. **Test Credentials** (when connecting a bank):
   - **Username**: `user_good`
   - **Password**: `pass_good`

3. **Testing Flow**:
   - Sign up with a new account
   - Navigate to Dashboard
   - Tap "Connect bank" card
   - Use Plaid Link with sandbox credentials
   - After successful connection, real transactions will appear

## Development

### Backend Tests

```bash
cd backend
pytest tests/
```

### Code Style

- Backend: Follow PEP 8, use Black formatter
- iOS: Follow Swift style guide, use SwiftFormat

## Security Notes

- Never commit `.env` file
- Use strong `SECRET_KEY` in production
- Store Plaid access tokens securely (encrypted at rest)
- JWT tokens expire after 24 hours
- Passwords are hashed with Argon2

## License

MIT

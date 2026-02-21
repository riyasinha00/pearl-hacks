# Quick Start Guide for Hackathon Demo 🚀

## TL;DR - Get Running in 5 Minutes

**You don't need Plaid!** The app works perfectly in demo mode.

### Backend (2 minutes)

```bash
cd backend
python3 -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt

# Create .env file with just this:
echo "SECRET_KEY=$(python -c 'import secrets; print(secrets.token_urlsafe(32))')" > .env
echo "DATABASE_URL=sqlite:///./piggie.db" >> .env

python scripts/init_db.py
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### iOS (3 minutes)

1. Open Xcode
2. Create new iOS App: "Piggie", SwiftUI, SwiftData
3. Copy all files from `ios/Piggie/` into project
4. Update `Piggie/Core/APIClient.swift`:
   - Simulator: `baseURL = "http://localhost:8000"`
   - Device: `baseURL = "http://<your-ip>:8000"`
5. Build & Run (Cmd+R)

## That's It! 🎉

The app will:
- ✅ Generate demo transactions automatically
- ✅ Show all features working
- ✅ Round-ups, allocations, goals all functional
- ✅ Beautiful UI with piggy mascot
- ✅ Perfect for hackathon demo!

## What Works Without Plaid

- User signup/login
- Demo transactions (auto-generated)
- Round-up prompts
- Savings/Investing/Goals allocation
- Goal creation and tracking
- Portfolio simulation
- All UI features

## If You Want Plaid Later

See `PLAID_SETUP.md` - but you don't need it for the demo!

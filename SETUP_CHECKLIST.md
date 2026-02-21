# Setup Checklist

Use this checklist to verify your setup is complete before running the app.

## Backend Setup

- [ ] Virtual environment created and activated
- [ ] Dependencies installed (`pip install -r requirements.txt`)
- [ ] `.env` file created in `backend/` directory
- [ ] `SECRET_KEY` added to `.env` (32+ characters)
- [ ] `PLAID_CLIENT_ID` added to `.env` (from Plaid Dashboard → Sandbox)
- [ ] `PLAID_SECRET` added to `.env` (from Plaid Dashboard → Sandbox)
- [ ] `PLAID_ENV=sandbox` in `.env`
- [ ] `DATABASE_URL=sqlite:///./piggie.db` in `.env`
- [ ] Database initialized: `python scripts/init_db.py` (from backend directory)
- [ ] Setup test passed: `python scripts/test_setup.py`
- [ ] Server starts: `uvicorn app.main:app --reload --host 0.0.0.0 --port 8000`

## iOS Setup

- [ ] Xcode project created
- [ ] All source files copied from `ios/Piggie/` to Xcode project
- [ ] `APIClient.swift` baseURL updated (localhost for simulator, IP for device)
- [ ] Info.plist configured for local development (NSAllowsArbitraryLoads)
- [ ] App builds without errors
- [ ] App runs on simulator/device

## Testing

- [ ] Backend API accessible at http://localhost:8000
- [ ] API docs accessible at http://localhost:8000/docs
- [ ] Can sign up new user in iOS app
- [ ] Can log in with created user
- [ ] Dashboard shows "Connect Bank" option
- [ ] Can connect bank via Plaid (use `user_good` / `pass_good`)
- [ ] Transactions appear after connection
- [ ] Can round up transactions
- [ ] Wallets show balances
- [ ] Can create goals
- [ ] Investing view shows portfolio

## Common Issues

**Backend won't start:**
- Check `.env` file exists in `backend/` directory
- Verify all required variables are set
- Run `python scripts/test_setup.py` to diagnose

**"Plaid is not configured":**
- Check `PLAID_CLIENT_ID` and `PLAID_SECRET` in `.env`
- Make sure no quotes around values
- Restart server after adding credentials

**Database errors:**
- Run `python scripts/init_db.py` from `backend/` directory
- Check `DATABASE_URL` is set in `.env`

**iOS can't connect to backend:**
- Check backend is running
- Verify `baseURL` in `APIClient.swift` matches your setup
- For physical device, use your computer's IP address
- Check firewall settings

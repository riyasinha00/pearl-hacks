# Plaid Setup Guide (Optional)

## Quick Answer

**For hackathon demo: You don't need Plaid!** The app works fully in demo mode with automatically generated transactions. Just skip Plaid setup entirely.

## If You Want Plaid Integration

### Step 1: Get Sandbox Credentials

1. Go to https://dashboard.plaid.com/signup
2. Sign up for a free account
3. Once logged in, go to **Team Settings** → **Keys**
4. You'll see two environments:
   - **Sandbox** (for testing - use this!)
   - **Production** (requires approval - ignore for now)

5. Copy your **Sandbox** credentials:
   - `client_id` (looks like: `5f8a...`)
   - `secret` (looks like: `abc123...`)

**Important**: You need BOTH `client_id` AND `secret` for sandbox. They're different from production credentials.

### Step 2: Add to .env

Add to your `backend/.env` file:
```bash
PLAID_CLIENT_ID=your-sandbox-client-id-here
PLAID_SECRET=your-sandbox-secret-here
PLAID_ENV=sandbox
```

### Step 3: Restart Backend

Restart your FastAPI server for changes to take effect.

### Step 4: Test Connection

1. Run the iOS app
2. Sign up or log in
3. Go to Dashboard
4. Tap "Connect Bank"
5. Use these test credentials:
   - **Username**: `user_good`
   - **Password**: `pass_good`

### Common Issues

**"Plaid is not configured" error:**
- Make sure both `PLAID_CLIENT_ID` and `PLAID_SECRET` are in `.env`
- Restart the backend server
- Check that values don't have extra spaces

**"Invalid credentials" error:**
- Make sure you're using **Sandbox** credentials, not Production
- Verify credentials in Plaid Dashboard
- Check that `PLAID_ENV=sandbox` is set

**Can't find credentials:**
- Make sure you're logged into Plaid Dashboard
- Check Team Settings > Keys (not API keys)
- Sandbox credentials are separate from Production

## For Hackathon Demo

**Just skip Plaid entirely!** The app will:
- Generate demo transactions automatically
- Show "Connect Bank" button (will show helpful message if clicked)
- All round-up, allocation, and goal features work perfectly
- No setup needed - perfect for quick demos

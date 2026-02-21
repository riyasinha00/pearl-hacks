# How to Add Plaid Sandbox Secret to .env File

## Step-by-Step Guide

### 1. Locate Your .env File

The `.env` file should be in the `backend/` directory:
```
piggie/
└── backend/
    ├── .env          ← This file (create it if it doesn't exist)
    ├── app/
    ├── requirements.txt
    └── ...
```

### 2. Create or Edit .env File

**If the file doesn't exist:**
```bash
cd backend
touch .env  # On Windows: type nul > .env
```

**Open the file in any text editor** (VS Code, nano, vim, Notepad, etc.)

### 3. Add Your Credentials

Your `.env` file should look exactly like this (replace with your actual values):

```bash
SECRET_KEY=your-secret-key-here-min-32-characters
DATABASE_URL=sqlite:///./piggie.db
JWT_ALGORITHM=HS256
JWT_EXPIRATION_HOURS=24

# Plaid Sandbox Credentials
PLAID_CLIENT_ID=5f8a1b2c3d4e5f6a7b8c9d0e  # Your client_id here
PLAID_SECRET=abc123def456ghi789jkl012mno345  # Your secret here
PLAID_ENV=sandbox
```

### 4. Where to Get the Secret

1. Go to https://dashboard.plaid.com
2. Log in to your account
3. Click **Team Settings** (in the left sidebar)
4. Click **Keys** (under Team Settings)
5. Find the **Sandbox** section (not Production!)
6. You'll see:
   - **Client ID**: Copy this → goes in `PLAID_CLIENT_ID=`
   - **Secret**: Copy this → goes in `PLAID_SECRET=`

### 5. Important Notes

- ✅ **No quotes needed** - just paste the value directly
- ✅ **No spaces** around the `=` sign
- ✅ Use **Sandbox** credentials, not Production
- ✅ You need **BOTH** `client_id` AND `secret`
- ✅ The `.env` file must be in the `backend/` folder

### 6. Example .env File

Here's a complete example (with fake values):

```bash
SECRET_KEY=my-super-secret-key-for-jwt-tokens-min-32-chars-long
DATABASE_URL=sqlite:///./piggie.db
JWT_ALGORITHM=HS256
JWT_EXPIRATION_HOURS=24

PLAID_CLIENT_ID=5f8a1b2c3d4e5f6a7b8c9d0e1f2a3b4c
PLAID_SECRET=abc123def456ghi789jkl012mno345pqr678stu901vwx234
PLAID_ENV=sandbox
```

### 7. Verify It Works

After saving the `.env` file:

1. **Restart your backend server** (stop it with Ctrl+C, then start again)
2. The server should start without errors
3. If you see "Plaid is not configured" errors, double-check:
   - Both `PLAID_CLIENT_ID` and `PLAID_SECRET` are present
   - No extra spaces or quotes
   - Values are from the Sandbox section (not Production)
   - File is saved in `backend/.env`

### Troubleshooting

**"Plaid is not configured" error:**
- Check that `PLAID_SECRET=` line exists in `.env`
- Make sure there's a value after the `=` sign
- Restart the server after making changes

**"Invalid credentials" error:**
- Verify you're using Sandbox credentials (not Production)
- Check that `PLAID_ENV=sandbox` is set
- Make sure you copied the entire secret (they're long strings)

**Can't find .env file:**
- Make sure you're in the `backend/` directory
- The file might be hidden (starts with `.`)
- Create it if it doesn't exist: `touch .env` or `type nul > .env`

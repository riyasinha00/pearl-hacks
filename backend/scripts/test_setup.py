"""Test script to verify backend setup is correct."""
import sys
import os

# Add parent directory to path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

def test_imports():
    """Test that all imports work."""
    print("Testing imports...")
    try:
        from app.config import settings
        print("✓ Config imported")
        
        from app.db import Base, engine
        print("✓ Database imported")
        
        from app.models import User, PlaidItem, Transaction
        print("✓ Models imported")
        
        from app.plaid_client import PlaidClient
        print("✓ Plaid client imported")
        
        return True
    except Exception as e:
        print(f"✗ Import error: {e}")
        return False

def test_config():
    """Test that configuration is loaded."""
    print("\nTesting configuration...")
    try:
        from app.config import settings
        
        if not settings.secret_key:
            print("✗ SECRET_KEY is not set")
            return False
        print("✓ SECRET_KEY is set")
        
        if not settings.plaid_client_id:
            print("✗ PLAID_CLIENT_ID is not set")
            return False
        print("✓ PLAID_CLIENT_ID is set")
        
        if not settings.plaid_secret:
            print("✗ PLAID_SECRET is not set")
            return False
        print("✓ PLAID_SECRET is set")
        
        print(f"✓ Plaid environment: {settings.plaid_env}")
        return True
    except Exception as e:
        print(f"✗ Config error: {e}")
        return False

def test_plaid_client():
    """Test that Plaid client can be initialized."""
    print("\nTesting Plaid client initialization...")
    try:
        from app.plaid_client import PlaidClient
        client = PlaidClient()
        print("✓ Plaid client initialized successfully")
        return True
    except Exception as e:
        print(f"✗ Plaid client error: {e}")
        print("  Make sure PLAID_CLIENT_ID and PLAID_SECRET are correct in .env")
        return False

def test_database():
    """Test database connection."""
    print("\nTesting database connection...")
    try:
        from app.db import engine
        with engine.connect() as conn:
            print("✓ Database connection successful")
        return True
    except Exception as e:
        print(f"✗ Database error: {e}")
        return False

if __name__ == "__main__":
    print("=" * 50)
    print("Piggie Backend Setup Test")
    print("=" * 50)
    
    all_passed = True
    all_passed &= test_imports()
    all_passed &= test_config()
    all_passed &= test_plaid_client()
    all_passed &= test_database()
    
    print("\n" + "=" * 50)
    if all_passed:
        print("✓ All tests passed! Backend is ready to run.")
        sys.exit(0)
    else:
        print("✗ Some tests failed. Please fix the errors above.")
        sys.exit(1)

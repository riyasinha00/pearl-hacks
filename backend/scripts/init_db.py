"""Initialize the database with tables."""
import sys
import os

# Add parent directory to path so we can import app modules
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from app.db import Base, engine
# Import all models so they're registered with Base
from app.models import User, PlaidItem, Transaction, Wallet, Goal, Allocation, MerchantRule, Roundup, Event

if __name__ == "__main__":
    print("Creating database tables...")
    try:
        Base.metadata.create_all(bind=engine)
        print("Database initialized successfully!")
    except Exception as e:
        print(f"Error initializing database: {e}")
        sys.exit(1)

from sqlalchemy.orm import Session
from app.models import Transaction, User
from datetime import datetime, timedelta
from typing import List, Dict, Any
import random


def generate_demo_transactions(user_public_id: str, count: int = 10) -> List[Dict[str, Any]]:
    """Generate demo transactions for offline/local use."""
    merchants = [
        "Starbucks", "Target", "Amazon", "Chipotle", "Uber Eats",
        "Spotify", "Netflix", "Apple Store", "CVS", "Whole Foods",
        "McDonald's", "Subway", "Pizza Hut", "Best Buy", "Trader Joe's"
    ]
    
    categories = [
        "Food and Drink", "Shopping", "Entertainment", "Transportation",
        "Groceries", "Restaurants", "General Merchandise"
    ]
    
    transactions = []
    base_time = datetime.now()
    
    for i in range(count):
        days_ago = random.randint(0, 30)
        timestamp = base_time - timedelta(days=days_ago, hours=random.randint(0, 23))
        
        # Random amount between $1 and $50
        amount = random.uniform(1.0, 50.0)
        amount_cents = int(amount * 100)
        
        merchant = random.choice(merchants)
        category = random.choice(categories)
        
        transactions.append({
            "transaction_id": f"demo_{user_public_id}_{i}_{int(timestamp.timestamp())}",
            "amount_cents": amount_cents,
            "merchant": merchant,
            "category": category,
            "timestamp": timestamp,
            "source": "local",
            "pending": False
        })
    
    return transactions


def sync_plaid_transactions(
    db: Session,
    user: User,
    access_token: str,
    plaid_client
) -> List[Transaction]:
    """Sync transactions from Plaid and store in DB."""
    # Get transactions from last 30 days
    end_date = datetime.now().date()
    start_date = (end_date - timedelta(days=30)).isoformat()
    end_date_str = end_date.isoformat()
    
    try:
        plaid_transactions = plaid_client.get_transactions(
            access_token,
            start_date,
            end_date_str
        )
        
        new_transactions = []
        for txn_data in plaid_transactions:
            # Check if transaction already exists
            existing = db.query(Transaction).filter(
                Transaction.transaction_id == txn_data["transaction_id"]
            ).first()
            
            if not existing:
                transaction = Transaction(
                    user_public_id=user.public_id,
                    transaction_id=txn_data["transaction_id"],
                    amount_cents=txn_data["amount_cents"],
                    merchant=txn_data["merchant"],
                    category=txn_data.get("category"),
                    timestamp=txn_data["timestamp"],
                    source="plaid",
                    pending=txn_data.get("pending", False)
                )
                db.add(transaction)
                new_transactions.append(transaction)
        
        db.commit()
        return new_transactions
    
    except Exception as e:
        db.rollback()
        raise e

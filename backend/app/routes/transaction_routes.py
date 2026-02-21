from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
from typing import List
from app.db import get_db
from app.models import Transaction, PlaidItem, User
from app.auth import get_current_user
from app.schemas import TransactionResponse
from app.services.transaction_service import generate_demo_transactions, sync_plaid_transactions
from app.plaid_client import PlaidClient

router = APIRouter(prefix="/transactions", tags=["transactions"])

plaid_client = PlaidClient()


@router.get("", response_model=List[TransactionResponse])
def get_transactions(
    since: str = Query(None, description="ISO8601 timestamp to fetch transactions since"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get user's transactions. Returns Plaid transactions if linked, otherwise demo transactions."""
    # Check if user has Plaid linked
    plaid_item = db.query(PlaidItem).filter(
        PlaidItem.user_public_id == current_user.public_id
    ).first()
    
    if plaid_item:
        # Try to sync latest transactions
        try:
            sync_plaid_transactions(db, current_user, plaid_item.access_token, plaid_client)
            plaid_item.last_sync = datetime.utcnow()
            db.commit()
        except Exception:
            db.rollback()
            # Continue with cached transactions
        
        # Query transactions from DB
        query = db.query(Transaction).filter(
            Transaction.user_public_id == current_user.public_id
        )
        
        if since:
            try:
                since_dt = datetime.fromisoformat(since.replace('Z', '+00:00'))
                query = query.filter(Transaction.timestamp >= since_dt)
            except ValueError:
                pass  # Invalid date format, ignore
        
        transactions = query.order_by(Transaction.timestamp.desc()).limit(100).all()
        
        if transactions:
            return [TransactionResponse.model_validate(t) for t in transactions]
    
    # Fallback to demo transactions if no Plaid or no transactions
    demo_txns = generate_demo_transactions(current_user.public_id, count=20)
    
    # Convert to TransactionResponse format
    return [
        TransactionResponse(
            id=i,
            transaction_id=t["transaction_id"],
            amount_cents=t["amount_cents"],
            merchant=t["merchant"],
            category=t["category"],
            timestamp=t["timestamp"],
            source=t["source"],
            pending=t["pending"]
        )
        for i, t in enumerate(demo_txns)
    ]

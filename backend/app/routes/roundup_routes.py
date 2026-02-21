from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.db import get_db
from app.models import Transaction, User
from app.auth import get_current_user
from app.schemas import RoundupRequest, RoundupResponse
from app.services.allocation_service import calculate_roundup, apply_roundup

router = APIRouter(prefix="/roundup", tags=["roundup"])


@router.post("/calculate")
def calculate_roundup_amount(
    transaction_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Calculate round-up amount for a transaction."""
    # Find transaction
    transaction = db.query(Transaction).filter(
        Transaction.transaction_id == transaction_id,
        Transaction.user_public_id == current_user.public_id
    ).first()
    
    if not transaction:
        # For demo transactions, we might not have it in DB
        # Return a mock calculation
        return {
            "roundup_cents": 50,  # Example
            "transaction_amount_cents": 1234
        }
    
    roundup_cents = calculate_roundup(transaction.amount_cents)
    
    return {
        "roundup_cents": roundup_cents,
        "transaction_amount_cents": transaction.amount_cents
    }


@router.post("", response_model=RoundupResponse)
def apply_roundup_to_transaction(
    request: RoundupRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Apply round-up to a transaction and allocate funds."""
    # Find transaction
    transaction = db.query(Transaction).filter(
        Transaction.transaction_id == request.transaction_id,
        Transaction.user_public_id == current_user.public_id
    ).first()
    
    if not transaction:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Transaction not found"
        )
    
    # Calculate round-up
    roundup_cents = calculate_roundup(transaction.amount_cents)
    
    if roundup_cents <= 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No round-up available for this transaction"
        )
    
    # Apply round-up
    roundup = apply_roundup(
        db,
        current_user,
        request.transaction_id,
        roundup_cents,
        request.goal_id
    )
    
    return RoundupResponse(
        roundup_cents=roundup.roundup_cents,
        savings_cents=roundup.savings_cents,
        investing_cents=roundup.investing_cents,
        goals_cents=roundup.goals_cents,
        goal_id=roundup.goal_id
    )

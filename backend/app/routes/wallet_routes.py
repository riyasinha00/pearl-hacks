from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.db import get_db
from app.models import Wallet, User
from app.auth import get_current_user
from app.schemas import WalletResponse
from app.services.portfolio_simulator import get_portfolio_summary

router = APIRouter(prefix="/wallet", tags=["wallet"])


@router.get("", response_model=WalletResponse)
def get_wallet(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get user's wallet balances."""
    wallet = db.query(Wallet).filter(
        Wallet.user_public_id == current_user.public_id
    ).first()
    
    if not wallet:
        # Create default wallet
        wallet = Wallet(user_public_id=current_user.public_id)
        db.add(wallet)
        db.commit()
        db.refresh(wallet)
    
    return WalletResponse(
        savings_cents=wallet.savings_cents,
        investing_cents=wallet.investing_cents
    )


@router.get("/portfolio")
def get_portfolio(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get portfolio summary with returns."""
    wallet = db.query(Wallet).filter(
        Wallet.user_public_id == current_user.public_id
    ).first()
    
    if not wallet:
        wallet = Wallet(user_public_id=current_user.public_id)
        db.add(wallet)
        db.commit()
        db.refresh(wallet)
    
    # Calculate initial investment (sum of all investing contributions)
    # For simplicity, use current value as baseline
    initial_investment = max(wallet.investing_cents, 1000)  # Min $10
    
    summary = get_portfolio_summary(
        current_user.public_id,
        initial_investment,
        wallet.investing_cents
    )
    
    return summary

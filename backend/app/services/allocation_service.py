from sqlalchemy.orm import Session
from app.models import Allocation, Wallet, Goal, Roundup, User
from typing import Optional


def calculate_roundup(amount_cents: int) -> int:
    """Calculate round-up amount. Always rounds to next dollar."""
    # If exactly on dollar, round up by $1.00
    if amount_cents % 100 == 0:
        return 100
    
    # Otherwise, round up to next dollar
    return 100 - (amount_cents % 100)


def apply_roundup(
    db: Session,
    user: User,
    transaction_id: str,
    roundup_cents: int,
    goal_id: Optional[int] = None
) -> Roundup:
    """Apply a round-up and allocate funds according to user's allocation settings."""
    # Get user's allocation
    allocation = db.query(Allocation).filter(
        Allocation.user_public_id == user.public_id
    ).first()
    
    if not allocation:
        # Default allocation: 40% savings, 30% investing, 30% goals
        allocation = Allocation(
            user_public_id=user.public_id,
            savings_percent=40.0,
            investing_percent=30.0,
            goals_percent=30.0
        )
        db.add(allocation)
        db.flush()
    
    # Calculate allocations
    savings_cents = int(roundup_cents * allocation.savings_percent / 100)
    investing_cents = int(roundup_cents * allocation.investing_percent / 100)
    goals_cents = roundup_cents - savings_cents - investing_cents  # Remainder to goals
    
    # Get or create wallet
    wallet = db.query(Wallet).filter(
        Wallet.user_public_id == user.public_id
    ).first()
    
    if not wallet:
        wallet = Wallet(user_public_id=user.public_id)
        db.add(wallet)
    
    # Update wallet balances
    wallet.savings_cents += savings_cents
    wallet.investing_cents += investing_cents
    
    # Apply goals allocation
    if goals_cents > 0:
        if goal_id:
            goal = db.query(Goal).filter(
                Goal.id == goal_id,
                Goal.user_public_id == user.public_id
            ).first()
        else:
            # Use default goal if exists
            goal = db.query(Goal).filter(
                Goal.user_public_id == user.public_id,
                Goal.is_default == True
            ).first()
        
        if goal:
            goal.current_cents += goals_cents
        else:
            # If no goal, add to savings instead
            wallet.savings_cents += goals_cents
            goals_cents = 0
    
    # Create roundup record
    roundup = Roundup(
        user_public_id=user.public_id,
        transaction_id=transaction_id,
        roundup_cents=roundup_cents,
        savings_cents=savings_cents,
        investing_cents=investing_cents,
        goals_cents=goals_cents,
        goal_id=goal_id if goals_cents > 0 else None
    )
    db.add(roundup)
    db.commit()
    
    return roundup

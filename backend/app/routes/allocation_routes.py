from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.db import get_db
from app.models import Allocation, User
from app.auth import get_current_user
from app.schemas import AllocationUpdate, AllocationResponse

router = APIRouter(prefix="/allocation", tags=["allocation"])


@router.get("", response_model=AllocationResponse)
def get_allocation(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get user's allocation percentages."""
    allocation = db.query(Allocation).filter(
        Allocation.user_public_id == current_user.public_id
    ).first()
    
    if not allocation:
        # Create default allocation
        allocation = Allocation(
            user_public_id=current_user.public_id,
            savings_percent=40.0,
            investing_percent=30.0,
            goals_percent=30.0
        )
        db.add(allocation)
        db.commit()
        db.refresh(allocation)
    
    return AllocationResponse(
        savings_percent=allocation.savings_percent,
        investing_percent=allocation.investing_percent,
        goals_percent=allocation.goals_percent
    )


@router.put("", response_model=AllocationResponse)
def update_allocation(
    allocation_data: AllocationUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Update user's allocation percentages."""
    allocation = db.query(Allocation).filter(
        Allocation.user_public_id == current_user.public_id
    ).first()
    
    if not allocation:
        allocation = Allocation(user_public_id=current_user.public_id)
        db.add(allocation)
    
    allocation.savings_percent = allocation_data.savings_percent
    allocation.investing_percent = allocation_data.investing_percent
    allocation.goals_percent = allocation_data.goals_percent
    
    db.commit()
    db.refresh(allocation)
    
    return AllocationResponse(
        savings_percent=allocation.savings_percent,
        investing_percent=allocation.investing_percent,
        goals_percent=allocation.goals_percent
    )

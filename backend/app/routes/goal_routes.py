from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from app.db import get_db
from app.models import Goal, User
from app.auth import get_current_user
from app.schemas import GoalCreate, GoalResponse

router = APIRouter(prefix="/goals", tags=["goals"])


@router.post("", response_model=GoalResponse)
def create_goal(
    goal_data: GoalCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Create a new goal."""
    # If this is set as default, unset other defaults
    if goal_data.is_default:
        db.query(Goal).filter(
            Goal.user_public_id == current_user.public_id,
            Goal.is_default == True
        ).update({"is_default": False})
    
    goal = Goal(
        user_public_id=current_user.public_id,
        name=goal_data.name,
        target_cents=goal_data.target_cents,
        icon=goal_data.icon,
        is_default=goal_data.is_default
    )
    db.add(goal)
    db.commit()
    db.refresh(goal)
    
    return GoalResponse.model_validate(goal)


@router.get("", response_model=List[GoalResponse])
def get_goals(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get all user's goals."""
    goals = db.query(Goal).filter(
        Goal.user_public_id == current_user.public_id
    ).order_by(Goal.created_at.desc()).all()
    
    return [GoalResponse.model_validate(g) for g in goals]


@router.get("/{goal_id}", response_model=GoalResponse)
def get_goal(
    goal_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get a specific goal."""
    goal = db.query(Goal).filter(
        Goal.id == goal_id,
        Goal.user_public_id == current_user.public_id
    ).first()
    
    if not goal:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Goal not found"
        )
    
    return GoalResponse.model_validate(goal)


@router.put("/{goal_id}", response_model=GoalResponse)
def update_goal(
    goal_id: int,
    goal_data: GoalCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Update a goal."""
    goal = db.query(Goal).filter(
        Goal.id == goal_id,
        Goal.user_public_id == current_user.public_id
    ).first()
    
    if not goal:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Goal not found"
        )
    
    # If setting as default, unset others
    if goal_data.is_default:
        db.query(Goal).filter(
            Goal.user_public_id == current_user.public_id,
            Goal.is_default == True,
            Goal.id != goal_id
        ).update({"is_default": False})
    
    goal.name = goal_data.name
    goal.target_cents = goal_data.target_cents
    goal.icon = goal_data.icon
    goal.is_default = goal_data.is_default
    
    db.commit()
    db.refresh(goal)
    
    return GoalResponse.model_validate(goal)


@router.delete("/{goal_id}")
def delete_goal(
    goal_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Delete a goal."""
    goal = db.query(Goal).filter(
        Goal.id == goal_id,
        Goal.user_public_id == current_user.public_id
    ).first()
    
    if not goal:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Goal not found"
        )
    
    db.delete(goal)
    db.commit()
    
    return {"status": "success"}


@router.post("/{goal_id}/set-default")
def set_default_goal(
    goal_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Set a goal as the default goal."""
    goal = db.query(Goal).filter(
        Goal.id == goal_id,
        Goal.user_public_id == current_user.public_id
    ).first()
    
    if not goal:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Goal not found"
        )
    
    # Unset other defaults
    db.query(Goal).filter(
        Goal.user_public_id == current_user.public_id,
        Goal.is_default == True
    ).update({"is_default": False})
    
    goal.is_default = True
    db.commit()
    
    return {"status": "success"}

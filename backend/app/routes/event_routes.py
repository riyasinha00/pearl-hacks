from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.db import get_db
from app.models import Event, User
from app.auth import get_current_user
from app.schemas import EventCreate

router = APIRouter(prefix="/events", tags=["events"])


@router.post("")
def create_event(
    event_data: EventCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Log an analytics event."""
    event = Event(
        user_public_id=current_user.public_id,
        event_type=event_data.event_type,
        metadata=event_data.metadata
    )
    db.add(event)
    db.commit()
    
    return {"status": "success"}

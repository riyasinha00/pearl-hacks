from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from datetime import datetime
from app.db import get_db
from app.models import PlaidItem, User
from app.auth import get_current_user
from app.plaid_client import PlaidClient
from app.schemas import PlaidLinkTokenResponse, PlaidExchangeRequest, PlaidItemResponse
from app.services.transaction_service import sync_plaid_transactions

router = APIRouter(prefix="/plaid", tags=["plaid"])

plaid_client = PlaidClient()


@router.post("/link_token", response_model=PlaidLinkTokenResponse)
def create_link_token(current_user: User = Depends(get_current_user)):
    """Create a Plaid Link token for the current user."""
    try:
        link_token = plaid_client.create_link_token(current_user.public_id)
        return PlaidLinkTokenResponse(link_token=link_token)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to create link token: {str(e)}"
        )


@router.post("/exchange_public_token")
def exchange_public_token(
    request: PlaidExchangeRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Exchange Plaid public token for access token and store item."""
    try:
        # Exchange token
        result = plaid_client.exchange_public_token(request.public_token)
        access_token = result["access_token"]
        item_id = result["item_id"]
        
        # Get institution info (optional)
        institution_id = None
        institution_name = None
        # Note: In sandbox, we might not have institution_id immediately
        # This would typically come from the Link success callback
        
        # Check if item already exists
        existing_item = db.query(PlaidItem).filter(
            PlaidItem.item_id == item_id
        ).first()
        
        if existing_item:
            # Update existing item
            existing_item.access_token = access_token
            existing_item.last_sync = datetime.utcnow()
            if institution_id:
                existing_item.institution_id = institution_id
            if institution_name:
                existing_item.institution_name = institution_name
        else:
            # Create new item
            plaid_item = PlaidItem(
                user_public_id=current_user.public_id,
                item_id=item_id,
                access_token=access_token,
                institution_id=institution_id,
                institution_name=institution_name,
                last_sync=datetime.utcnow()
            )
            db.add(plaid_item)
        
        db.commit()
        
        # Sync transactions
        try:
            sync_plaid_transactions(db, current_user, access_token, plaid_client)
        except Exception as e:
            # Log but don't fail the exchange
            print(f"Failed to sync transactions: {e}")
        
        return {"status": "success", "item_id": item_id}
    
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to exchange token: {str(e)}"
        )


@router.get("/item", response_model=PlaidItemResponse)
def get_plaid_item(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get the user's Plaid item information."""
    item = db.query(PlaidItem).filter(
        PlaidItem.user_public_id == current_user.public_id
    ).first()
    
    if not item:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No Plaid item connected"
        )
    
    return PlaidItemResponse(
        item_id=item.item_id,
        institution_name=item.institution_name,
        last_sync=item.last_sync
    )


@router.post("/sync")
def sync_transactions(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Manually sync transactions from Plaid."""
    item = db.query(PlaidItem).filter(
        PlaidItem.user_public_id == current_user.public_id
    ).first()
    
    if not item:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No Plaid item connected"
        )
    
    try:
        sync_plaid_transactions(db, current_user, item.access_token, plaid_client)
        item.last_sync = datetime.utcnow()
        db.commit()
        return {"status": "success", "message": "Transactions synced"}
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to sync: {str(e)}"
        )

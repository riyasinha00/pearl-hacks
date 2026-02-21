from fastapi import APIRouter, Depends, HTTPException, status
from fastapi import Request
from sqlalchemy.orm import Session
from collections import defaultdict
from datetime import datetime, timedelta
from app.db import get_db
from app.models import User, Wallet, Allocation
from app.schemas import UserSignup, UserLogin, Token, UserResponse
from app.utils.security import hash_password, verify_password, create_access_token
from app.utils.ids import generate_public_id
from app.auth import get_current_user

router = APIRouter(prefix="/auth", tags=["auth"])

# Simple in-memory rate limiting (sliding window per IP)
login_attempts = defaultdict(list)
MAX_ATTEMPTS = 5
WINDOW_MINUTES = 15


def check_rate_limit(ip: str) -> bool:
    """Check if IP is rate limited."""
    now = datetime.utcnow()
    cutoff = now - timedelta(minutes=WINDOW_MINUTES)
    
    # Clean old attempts
    login_attempts[ip] = [t for t in login_attempts[ip] if t > cutoff]
    
    # Check limit
    if len(login_attempts[ip]) >= MAX_ATTEMPTS:
        return False
    
    login_attempts[ip].append(now)
    return True


@router.post("/signup", response_model=Token)
def signup(user_data: UserSignup, db: Session = Depends(get_db)):
    """Create a new user account."""
    # Check if email already exists
    existing_user = db.query(User).filter(User.email == user_data.email).first()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )
    
    # Create user
    public_id = generate_public_id()
    # Ensure uniqueness
    while db.query(User).filter(User.public_id == public_id).first():
        public_id = generate_public_id()
    
    hashed_pw = hash_password(user_data.password)
    monthly_goal_cents = int(user_data.monthly_goal * 100)
    
    user = User(
        public_id=public_id,
        email=user_data.email,
        hashed_password=hashed_pw,
        name=user_data.name,
        school=user_data.school,
        grad_year=user_data.grad_year,
        monthly_goal_cents=monthly_goal_cents
    )
    db.add(user)
    
    # Create default wallet
    wallet = Wallet(user_public_id=public_id)
    db.add(wallet)
    
    # Create default allocation (40/30/30)
    allocation = Allocation(
        user_public_id=public_id,
        savings_percent=40.0,
        investing_percent=30.0,
        goals_percent=30.0
    )
    db.add(allocation)
    
    db.commit()
    db.refresh(user)
    
    # Create JWT token
    access_token = create_access_token(data={"sub": user.public_id})
    
    return Token(access_token=access_token)


@router.post("/login", response_model=Token)
def login(credentials: UserLogin, db: Session = Depends(get_db), request: Request = None):
    """Authenticate user and return JWT token."""
    # Rate limiting check (basic)
    client_ip = request.client.host if request and request.client else "unknown"
    if not check_rate_limit(client_ip):
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail="Too many login attempts. Please try again later."
        )
    
    # Find user
    user = db.query(User).filter(User.email == credentials.email).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password"
        )
    
    # Verify password
    if not verify_password(credentials.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password"
        )
    
    # Create JWT token
    access_token = create_access_token(data={"sub": user.public_id})
    
    return Token(access_token=access_token)


@router.get("/me", response_model=UserResponse)
def get_current_user_info(current_user: User = Depends(get_current_user)):
    """Get current user information."""
    return UserResponse(
        public_id=current_user.public_id,
        email=current_user.email,
        name=current_user.name,
        school=current_user.school,
        grad_year=current_user.grad_year,
        monthly_goal_cents=current_user.monthly_goal_cents
    )

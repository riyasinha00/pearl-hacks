from pydantic import BaseModel, EmailStr, field_validator, model_validator
from typing import Optional
from datetime import datetime
from app.utils.validation import (
    validate_email, validate_name, validate_school, validate_grad_year,
    validate_monthly_goal, validate_password
)


class UserSignup(BaseModel):
    name: str
    email: str
    password: str
    school: str
    grad_year: int
    monthly_goal: float
    
    @field_validator('email')
    @classmethod
    def validate_email_field(cls, v):
        is_valid, error = validate_email(v)
        if not is_valid:
            raise ValueError(error)
        return v.strip().lower()
    
    @field_validator('name')
    @classmethod
    def validate_name_field(cls, v):
        is_valid, error = validate_name(v)
        if not is_valid:
            raise ValueError(error)
        return v.strip()
    
    @field_validator('school')
    @classmethod
    def validate_school_field(cls, v):
        is_valid, error = validate_school(v)
        if not is_valid:
            raise ValueError(error)
        return v.strip()
    
    @field_validator('grad_year')
    @classmethod
    def validate_grad_year_field(cls, v):
        is_valid, error = validate_grad_year(v)
        if not is_valid:
            raise ValueError(error)
        return v
    
    @field_validator('monthly_goal')
    @classmethod
    def validate_monthly_goal_field(cls, v):
        is_valid, error = validate_monthly_goal(v)
        if not is_valid:
            raise ValueError(error)
        return v
    
    @field_validator('password')
    @classmethod
    def validate_password_field(cls, v):
        is_valid, error = validate_password(v)
        if not is_valid:
            raise ValueError(error)
        return v


class UserLogin(BaseModel):
    email: str
    password: str
    
    @field_validator('email')
    @classmethod
    def validate_email_field(cls, v):
        is_valid, error = validate_email(v)
        if not is_valid:
            raise ValueError(error)
        return v.strip().lower()


class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"


class UserResponse(BaseModel):
    public_id: str
    email: str
    name: str
    school: str
    grad_year: int
    monthly_goal_cents: int
    
    model_config = {"from_attributes": True}


class PlaidLinkTokenResponse(BaseModel):
    link_token: str


class PlaidExchangeRequest(BaseModel):
    public_token: str


class PlaidItemResponse(BaseModel):
    item_id: str
    institution_name: Optional[str] = None
    last_sync: Optional[datetime] = None
    
    model_config = {"from_attributes": True}


class TransactionResponse(BaseModel):
    id: int
    transaction_id: str
    amount_cents: int
    merchant: str
    category: Optional[str] = None
    timestamp: datetime
    source: str
    pending: bool
    
    model_config = {"from_attributes": True}


class WalletResponse(BaseModel):
    savings_cents: int
    investing_cents: int
    
    model_config = {"from_attributes": True}


class GoalCreate(BaseModel):
    name: str
    target_cents: int
    icon: str = "🎯"
    is_default: bool = False


class GoalResponse(BaseModel):
    id: int
    name: str
    target_cents: int
    current_cents: int
    icon: str
    is_default: bool
    created_at: datetime
    
    model_config = {"from_attributes": True}


class AllocationUpdate(BaseModel):
    savings_percent: float
    investing_percent: float
    goals_percent: float
    
    @model_validator(mode='after')
    def check_percentages_sum(self):
        total = self.savings_percent + self.investing_percent + self.goals_percent
        if abs(total - 100.0) > 0.01:
            raise ValueError("Percentages must sum to 100")
        return self


class AllocationResponse(BaseModel):
    savings_percent: float
    investing_percent: float
    goals_percent: float
    
    model_config = {"from_attributes": True}


class RoundupRequest(BaseModel):
    transaction_id: str
    goal_id: Optional[int] = None


class RoundupResponse(BaseModel):
    roundup_cents: int
    savings_cents: int
    investing_cents: int
    goals_cents: int
    goal_id: Optional[int] = None


class EventCreate(BaseModel):
    event_type: str
    metadata: Optional[str] = None

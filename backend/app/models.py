from sqlalchemy import Column, Integer, String, Float, Boolean, DateTime, ForeignKey, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.db import Base


class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    public_id = Column(String, unique=True, index=True, nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    name = Column(String, nullable=False)
    school = Column(String, nullable=False)
    grad_year = Column(Integer, nullable=False)
    monthly_goal_cents = Column(Integer, nullable=False, default=0)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Relationships
    plaid_items = relationship("PlaidItem", back_populates="user")
    transactions = relationship("Transaction", back_populates="user")
    wallets = relationship("Wallet", back_populates="user")
    goals = relationship("Goal", back_populates="user")
    allocations = relationship("Allocation", back_populates="user")
    merchant_rules = relationship("MerchantRule", back_populates="user")
    roundups = relationship("Roundup", back_populates="user")


class PlaidItem(Base):
    __tablename__ = "plaid_items"
    
    id = Column(Integer, primary_key=True, index=True)
    user_public_id = Column(String, ForeignKey("users.public_id"), nullable=False)
    item_id = Column(String, unique=True, nullable=False)
    access_token = Column(String, nullable=False)  # Should be encrypted in production
    institution_id = Column(String)
    institution_name = Column(String)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    last_sync = Column(DateTime(timezone=True))
    
    user = relationship("User", back_populates="plaid_items")


class Transaction(Base):
    __tablename__ = "transactions"
    
    id = Column(Integer, primary_key=True, index=True)
    user_public_id = Column(String, ForeignKey("users.public_id"), nullable=False)
    transaction_id = Column(String, unique=True, nullable=False)
    amount_cents = Column(Integer, nullable=False)
    merchant = Column(String, nullable=False)
    category = Column(String)
    timestamp = Column(DateTime(timezone=True), nullable=False)
    source = Column(String, nullable=False)  # "plaid" or "local"
    pending = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    user = relationship("User", back_populates="transactions")


class Wallet(Base):
    __tablename__ = "wallets"
    
    id = Column(Integer, primary_key=True, index=True)
    user_public_id = Column(String, ForeignKey("users.public_id"), unique=True, nullable=False)
    savings_cents = Column(Integer, default=0)
    investing_cents = Column(Integer, default=0)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    user = relationship("User", back_populates="wallets")


class Goal(Base):
    __tablename__ = "goals"
    
    id = Column(Integer, primary_key=True, index=True)
    user_public_id = Column(String, ForeignKey("users.public_id"), nullable=False)
    name = Column(String, nullable=False)
    target_cents = Column(Integer, nullable=False)
    current_cents = Column(Integer, default=0)
    icon = Column(String, default="🎯")
    is_default = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    user = relationship("User", back_populates="goals")


class Allocation(Base):
    __tablename__ = "allocations"
    
    id = Column(Integer, primary_key=True, index=True)
    user_public_id = Column(String, ForeignKey("users.public_id"), unique=True, nullable=False)
    savings_percent = Column(Float, nullable=False, default=0.0)
    investing_percent = Column(Float, nullable=False, default=0.0)
    goals_percent = Column(Float, nullable=False, default=0.0)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    user = relationship("User", back_populates="allocations")


class MerchantRule(Base):
    __tablename__ = "merchant_rules"
    
    id = Column(Integer, primary_key=True, index=True)
    user_public_id = Column(String, ForeignKey("users.public_id"), nullable=False)
    merchant = Column(String, nullable=False)
    auto_roundup = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    user = relationship("User", back_populates="merchant_rules")


class Roundup(Base):
    __tablename__ = "roundups"
    
    id = Column(Integer, primary_key=True, index=True)
    user_public_id = Column(String, ForeignKey("users.public_id"), nullable=False)
    transaction_id = Column(String, nullable=False)
    roundup_cents = Column(Integer, nullable=False)
    savings_cents = Column(Integer, default=0)
    investing_cents = Column(Integer, default=0)
    goals_cents = Column(Integer, default=0)
    goal_id = Column(Integer, ForeignKey("goals.id"), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    user = relationship("User", back_populates="roundups")


class Event(Base):
    __tablename__ = "events"
    
    id = Column(Integer, primary_key=True, index=True)
    user_public_id = Column(String, nullable=False)
    event_type = Column(String, nullable=False)  # prompt_shown, prompt_accepted, etc.
    event_metadata = Column(Text)  # JSON string
    created_at = Column(DateTime(timezone=True), server_default=func.now())

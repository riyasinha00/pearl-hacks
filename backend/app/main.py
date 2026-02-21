from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.db import Base, engine
# Import all models so they're registered with Base
from app.models import User, PlaidItem, Transaction, Wallet, Goal, Allocation, MerchantRule, Roundup, Event
from app.routes import auth_routes, plaid_routes, transaction_routes, wallet_routes, goal_routes, event_routes

# Create database tables
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Piggie API",
    description="Backend API for Piggie - Round-up savings app",
    version="1.0.0"
)

# CORS middleware for iOS app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, restrict to specific origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth_routes.router)
app.include_router(plaid_routes.router)
app.include_router(transaction_routes.router)
app.include_router(wallet_routes.router)
app.include_router(goal_routes.router)
app.include_router(event_routes.router)

# Round-up route (needs to be added)
from app.routes.roundup_routes import router as roundup_router
app.include_router(roundup_router)

# Allocation route (needs to be added)
from app.routes.allocation_routes import router as allocation_router
app.include_router(allocation_router)


@app.get("/")
def root():
    return {"message": "Piggie API", "version": "1.0.0"}


@app.get("/health")
def health():
    return {"status": "healthy"}

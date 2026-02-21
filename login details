from fastapi import FastAPI, Depends
from sqlalchemy.orm import Session
from db import get_db
from services import register_user, login_user, get_current_user, create_plaid_link_token, exchange_public_token, get_loan_preapproval

app = FastAPI()

# Register User
@app.post("/register")
def register(username: str, password: str, db: Session = Depends(get_db)):
    return register_user(db, username, password)

# Login User
@app.post("/token")
def login(username: str, password: str, db: Session = Depends(get_db)):
    return login_user(db, username, password)

# Create Plaid Link Token
@app.post("/create_link_token")
def create_link_token(token: str, db: Session = Depends(get_db)):
    username = get_current_user(token)
    return create_plaid_link_token(db, username)

@app.post("/exchange_public_token")
def api_exchange_public_token(public_token: str, username: str, db: Session = Depends(get_db)):
    return exchange_public_token(db, public_token, username)

# Loan Pre-Approval
@app.get("/loan_preapproval")
def loan_preapproval(token: str, db: Session = Depends(get_db)):
    username = get_current_user(token)
    return get_loan_preapproval(db, username)

import hashlib
import random
from datetime import datetime, timedelta
from typing import List, Tuple


def generate_portfolio_returns(
    user_public_id: str,
    initial_investment_cents: int,
    days: int = 365
) -> List[Tuple[datetime, int]]:
    """
    Generate deterministic portfolio returns based on user public_id.
    Uses a seeded random walk to simulate daily returns.
    """
    # Seed random with user public_id hash for determinism
    seed = int(hashlib.md5(user_public_id.encode()).hexdigest(), 16) % (2**32)
    random.seed(seed)
    
    # Daily return parameters (mean ~0.03%, std ~1.5%)
    mean_daily_return = 0.0003
    std_daily_return = 0.015
    
    returns = []
    current_value_cents = initial_investment_cents
    base_date = datetime.now() - timedelta(days=days)
    
    for day in range(days):
        # Generate daily return
        daily_return = random.gauss(mean_daily_return, std_daily_return)
        current_value_cents = int(current_value_cents * (1 + daily_return))
        
        date = base_date + timedelta(days=day)
        returns.append((date, current_value_cents))
    
    return returns


def get_portfolio_summary(
    user_public_id: str,
    initial_investment_cents: int,
    current_investment_cents: int
) -> dict:
    """Get portfolio summary with today and all-time returns."""
    # Calculate all-time return
    total_return_cents = current_investment_cents - initial_investment_cents
    total_return_percent = (total_return_cents / initial_investment_cents * 100) if initial_investment_cents > 0 else 0
    
    # Get today's return (simulate)
    seed = int(hashlib.md5((user_public_id + str(datetime.now().date())).encode()).hexdigest(), 16) % (2**32)
    random.seed(seed)
    today_return = random.gauss(0.0003, 0.015)
    today_return_cents = int(current_investment_cents * today_return)
    today_return_percent = today_return * 100
    
    return {
        "current_value_cents": current_investment_cents,
        "total_return_cents": total_return_cents,
        "total_return_percent": total_return_percent,
        "today_return_cents": today_return_cents,
        "today_return_percent": today_return_percent
    }

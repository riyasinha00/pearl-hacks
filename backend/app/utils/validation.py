import re
from typing import Optional
from datetime import datetime

# Common password denylist
COMMON_PASSWORDS = {
    "password", "1234567890", "qwerty", "qwerty123", "password123",
    "12345678", "123456789", "abc123", "password1", "welcome123"
}


def validate_email(email: str) -> tuple[bool, Optional[str]]:
    """Validate email format. Returns (is_valid, error_message)."""
    if not email:
        return False, "Email is required"
    
    email = email.strip().lower()
    
    # Basic email regex
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    if not re.match(pattern, email):
        return False, "Please enter a valid email address"
    
    if len(email) > 254:  # RFC 5321 limit
        return False, "Email address is too long"
    
    return True, None


def validate_name(name: str) -> tuple[bool, Optional[str]]:
    """Validate name. Returns (is_valid, error_message)."""
    if not name:
        return False, "Name is required"
    
    name = name.strip()
    
    if len(name) < 2:
        return False, "Name must be at least 2 characters"
    
    if len(name) > 40:
        return False, "Name must be no more than 40 characters"
    
    # Allow letters, spaces, hyphens, apostrophes
    pattern = r'^[a-zA-Z\s\-\']+$'
    if not re.match(pattern, name):
        return False, "Name can only contain letters, spaces, hyphens, and apostrophes"
    
    if name != name.strip():
        return False, "Name cannot have leading or trailing spaces"
    
    return True, None


def validate_school(school: str) -> tuple[bool, Optional[str]]:
    """Validate school name. Returns (is_valid, error_message)."""
    if not school:
        return False, "School is required"
    
    school = school.strip()
    
    if len(school) < 2:
        return False, "School name must be at least 2 characters"
    
    if len(school) > 60:
        return False, "School name must be no more than 60 characters"
    
    # Safe characters: letters, numbers, spaces, dots, hyphens, apostrophes
    pattern = r'^[a-zA-Z0-9\s\.\-\']+$'
    if not re.match(pattern, school):
        return False, "School name contains invalid characters"
    
    return True, None


def validate_grad_year(grad_year: int) -> tuple[bool, Optional[str]]:
    """Validate graduation year. Returns (is_valid, error_message)."""
    current_year = datetime.now().year
    min_year = current_year - 10
    max_year = current_year + 10
    
    if grad_year < min_year or grad_year > max_year:
        return False, f"Graduation year must be between {min_year} and {max_year}"
    
    return True, None


def validate_monthly_goal(amount: float) -> tuple[bool, Optional[str]]:
    """Validate monthly goal amount. Returns (is_valid, error_message)."""
    if amount < 0:
        return False, "Monthly goal must be positive"
    
    if amount > 5000:
        return False, "Monthly goal cannot exceed $5,000"
    
    return True, None


def validate_password(password: str) -> tuple[bool, Optional[str]]:
    """Validate password strength. Returns (is_valid, error_message)."""
    if not password:
        return False, "Password is required"
    
    if len(password) < 10:
        return False, "Password must be at least 10 characters"
    
    if len(password) > 72:
        return False, "Password must be no more than 72 characters"
    
    # Check for uppercase
    if not re.search(r'[A-Z]', password):
        return False, "Password must include at least one uppercase letter"
    
    # Check for lowercase
    if not re.search(r'[a-z]', password):
        return False, "Password must include at least one lowercase letter"
    
    # Check for digit
    if not re.search(r'\d', password):
        return False, "Password must include at least one number"
    
    # Check for symbol
    if not re.search(r'[!@#$%^&*()_+\-=\[\]{};\':"\\|,.<>/?]', password):
        return False, "Password must include at least one symbol"
    
    # Check against common passwords
    if password.lower() in COMMON_PASSWORDS:
        return False, "This password is too common. Please choose a stronger password"
    
    return True, None

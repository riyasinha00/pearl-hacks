"""Tests for authentication and validation."""
import pytest
from app.utils.validation import (
    validate_email, validate_name, validate_school,
    validate_grad_year, validate_monthly_goal, validate_password
)


def test_validate_email():
    # Valid emails
    assert validate_email("test@example.com")[0] == True
    assert validate_email("user.name@domain.co.uk")[0] == True
    
    # Invalid emails
    assert validate_email("")[0] == False
    assert validate_email("invalid")[0] == False
    assert validate_email("@example.com")[0] == False


def test_validate_name():
    # Valid names
    assert validate_name("John Doe")[0] == True
    assert validate_name("Mary-Jane O'Connor")[0] == True
    
    # Invalid names
    assert validate_name("")[0] == False
    assert validate_name("A")[0] == False  # Too short
    assert validate_name("A" * 41)[0] == False  # Too long
    assert validate_name("John123")[0] == False  # Contains numbers


def test_validate_password():
    # Valid password
    assert validate_password("StrongPass123!")[0] == True
    
    # Invalid passwords
    assert validate_password("")[0] == False
    assert validate_password("short")[0] == False  # Too short
    assert validate_password("nouppercase123!")[0] == False  # No uppercase
    assert validate_password("NOLOWERCASE123!")[0] == False  # No lowercase
    assert validate_password("NoNumbers!")[0] == False  # No numbers
    assert validate_password("NoSymbols123")[0] == False  # No symbols
    assert validate_password("password123!")[0] == False  # Common password

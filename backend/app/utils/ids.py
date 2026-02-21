import random
import string


def generate_public_id() -> str:
    """Generate a random 10-character alphanumeric public ID."""
    return ''.join(random.choices(string.ascii_letters + string.digits, k=10))

from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    secret_key: str
    # Plaid Sandbox credentials (required)
    plaid_client_id: str
    plaid_secret: str
    plaid_env: str = "sandbox"
    database_url: str = "sqlite:///./piggie.db"
    jwt_algorithm: str = "HS256"
    jwt_expiration_hours: int = 24
    
    class Config:
        env_file = ".env"
        case_sensitive = False


settings = Settings()

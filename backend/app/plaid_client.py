from plaid.api import plaid_api
from plaid.configuration import Configuration
from plaid.api_client import ApiClient
from app.config import settings
from typing import Optional, Dict, Any
import os

# Map environment to Plaid host
PLAID_HOSTS = {
    "sandbox": "https://sandbox.plaid.com",
    "development": "https://development.plaid.com",
    "production": "https://production.plaid.com"
}


class PlaidClient:
    def __init__(self):
        try:
            configuration = Configuration(
                host=PLAID_HOSTS.get(settings.plaid_env, PLAID_HOSTS["sandbox"]),
                api_key={
                    "clientId": settings.plaid_client_id,
                    "secret": settings.plaid_secret
                }
            )
            api_client = ApiClient(configuration)
            self.client = plaid_api.PlaidApi(api_client)
        except Exception as e:
            raise ValueError(
                f"Failed to initialize Plaid client. Make sure PLAID_CLIENT_ID and PLAID_SECRET are set in .env file. Error: {str(e)}"
            )
    
    def create_link_token(self, user_id: str) -> str:
        """Create a Plaid Link token for the user."""
        from plaid.model.link_token_create_request import LinkTokenCreateRequest
        from plaid.model.link_token_create_request_user import LinkTokenCreateRequestUser
        from plaid.model.country_code import CountryCode
        from plaid.model.products import Products
        
        request = LinkTokenCreateRequest(
            products=[Products('transactions')],
            client_name="Piggie",
            country_codes=[CountryCode('US')],
            language='en',
            user=LinkTokenCreateRequestUser(client_user_id=user_id),
            webhook='https://example.com/webhook'  # Not used in sandbox
        )
        
        response = self.client.link_token_create(request)
        return response['link_token']
    
    def exchange_public_token(self, public_token: str) -> Dict[str, Any]:
        """Exchange public token for access token."""
        from plaid.model.item_public_token_exchange_request import ItemPublicTokenExchangeRequest
        
        request = ItemPublicTokenExchangeRequest(public_token=public_token)
        response = self.client.item_public_token_exchange(request)
        
        return {
            "access_token": response['access_token'],
            "item_id": response['item_id']
        }
    
    def get_institution(self, institution_id: str) -> Optional[Dict[str, Any]]:
        """Get institution information."""
        from plaid.model.institutions_get_by_id_request import InstitutionsGetByIdRequest
        from plaid.model.country_code import CountryCode
        
        try:
            request = InstitutionsGetByIdRequest(
                institution_id=institution_id,
                country_codes=[CountryCode('US')]
            )
            response = self.client.institutions_get_by_id(request)
            institution = response['institution']
            return {
                "institution_id": institution['institution_id'],
                "name": institution['name']
            }
        except Exception:
            return None
    
    def get_transactions(
        self,
        access_token: str,
        start_date: str,
        end_date: str
    ) -> list[Dict[str, Any]]:
        """Fetch transactions from Plaid."""
        from plaid.model.transactions_get_request import TransactionsGetRequest
        from datetime import datetime
        
        request = TransactionsGetRequest(
            access_token=access_token,
            start_date=datetime.strptime(start_date, "%Y-%m-%d").date(),
            end_date=datetime.strptime(end_date, "%Y-%m-%d").date()
        )
        
        response = self.client.transactions_get(request)
        transactions = response['transactions']
        
        # Normalize to our format
        normalized = []
        for txn in transactions:
            # Convert date string to datetime
            date_str = txn['date']
            if isinstance(date_str, str):
                txn_date = datetime.strptime(date_str, "%Y-%m-%d")
            else:
                txn_date = date_str
            
            normalized.append({
                "transaction_id": txn['transaction_id'],
                "amount_cents": int(abs(txn['amount']) * 100),  # Plaid uses negative for debits
                "merchant": txn.get('merchant_name') or txn.get('name', 'Unknown'),
                "category": ', '.join(txn.get('category', [])) if txn.get('category') else None,
                "timestamp": txn_date,
                "pending": txn.get('pending', False)
            })
        
        return normalized

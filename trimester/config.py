import os
from dotenv import load_dotenv

load_dotenv()

class Settings:
    # OpenAPI Configuration
    OPENAPI_BASE_URL: str = os.getenv("OPENAPI_BASE_URL", "https://api.pregnancy.com/v1")
    OPENAPI_API_KEY: str = os.getenv("OPENAPI_API_KEY", "")
    OPENAPI_TIMEOUT: int = int(os.getenv("OPENAPI_TIMEOUT", "30"))
    
    # OpenAI Configuration
    OPENAI_API_KEY: str = os.getenv("OPENAI_API_KEY", "")
    OPENAI_MODEL: str = os.getenv("OPENAI_MODEL", "gpt-3.5-turbo")
    OPENAI_MAX_TOKENS: int = int(os.getenv("OPENAI_MAX_TOKENS", "500"))
    
    # FastAPI Configuration
    HOST: str = os.getenv("HOST", "0.0.0.0")
    PORT: int = int(os.getenv("PORT", "8000"))
    DEBUG: bool = os.getenv("DEBUG", "True").lower() == "true"

settings = Settings()

from pydantic_settings import BaseSettings
from typing import List
import os

class Settings(BaseSettings):
    # Database
    DATABASE_URL: str = "sqlite:///./vital_hydration.db"
    
    # MongoDB Configuration
    MONGO_URI: str = "mongodb://localhost:27017"
    DB_NAME: str = "vital_hydration"
    COLLECTION_NAME: str = "patient_v2"
    
    # API Configuration
    API_HOST: str = "0.0.0.0"
    API_PORT: str = "8000"
    DEBUG: str = "True"
    RELOAD: str = "True"
    
    # Security
    SECRET_KEY: str = "your-secret-key-here"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    
    # CORS
    ALLOWED_ORIGINS: List[str] = ["*"]
    
    # Weather API
    OPENWEATHER_API_KEY: str = "your-openweather-api-key"
    
    # Twilio SMS
    TWILIO_ACCOUNT_SID: str = "your-twilio-sid"
    TWILIO_AUTH_TOKEN: str = "your-twilio-token"
    TWILIO_PHONE_NUMBER: str = "+1234567890"
    
    # Firebase (Push Notifications)
    FIREBASE_CREDENTIALS_PATH: str = "firebase-credentials.json"
    
    # Redis (for Celery)
    REDIS_URL: str = "redis://localhost:6379"
    
    # Hydration Settings
    DEFAULT_HYDRATION_GOAL: int = 2500  # ml per day
    PREGNANCY_HYDRATION_BOOST: float = 1.2  # 20% increase during pregnancy
    WEATHER_HYDRATION_FACTOR: float = 0.1  # 10% increase per 5°C above 25°C
    
    class Config:
        env_file = ".env"
        extra = "allow"  # Allow extra fields from environment

settings = Settings()

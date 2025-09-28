from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBearer
from contextlib import asynccontextmanager
import uvicorn
import os

# Set environment variables for development
os.environ.setdefault("DATABASE_URL", "sqlite:///./vital_hydration.db")
os.environ.setdefault("SECRET_KEY", "dev-secret-key-change-in-production")
os.environ.setdefault("OPENWEATHER_API_KEY", "demo-key")

from app.database import engine, Base
from app.routers import auth, hydration, weather, alerts, reports, content, patients
from app.core.config import settings
# Create database tables
@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    Base.metadata.create_all(bind=engine)
    yield
    # Shutdown
    pass

app = FastAPI(
    title="Vital Hydration API",
    description="Real-time hydration monitoring and alerts for pregnant users",
    version="1.0.0",
    lifespan=lifespan
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth.router, prefix="/api/v1/auth", tags=["Authentication"])
app.include_router(hydration.router, prefix="/api/v1/hydration", tags=["Hydration"])
app.include_router(weather.router, prefix="/api/v1/weather", tags=["Weather"])
app.include_router(alerts.router, prefix="/api/v1/alerts", tags=["Alerts"])
app.include_router(reports.router, prefix="/api/v1/reports", tags=["Reports"])
app.include_router(content.router, prefix="/api/v1/content", tags=["Content"])
app.include_router(patients.router, prefix="/api/v1/patients", tags=["Patients"])

@app.get("/")
async def root():
    return {"message": "Vital Hydration API - Real-time wellness monitoring"}

@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "vital-hydration-api"}

if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True
    )

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from app.database import get_db
from app.models import User, WeatherData
from app.schemas import WeatherData as WeatherDataSchema
from app.core.security import get_current_active_user
from app.services.weather_service import weather_service

router = APIRouter()

@router.get("/current")
async def get_current_weather(
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Get current weather data for user's location"""
    if not current_user.location_lat or not current_user.location_lon:
        raise HTTPException(
            status_code=400,
            detail="User location not set. Please update your location in profile."
        )
    
    # Get current weather
    weather_data = await weather_service.get_current_weather(
        current_user.location_lat, 
        current_user.location_lon
    )
    
    if not weather_data:
        raise HTTPException(
            status_code=503,
            detail="Weather service temporarily unavailable"
        )
    
    # Save weather data to database
    db_weather = WeatherData(
        user_id=current_user.id,
        temperature=weather_data["temperature"],
        humidity=weather_data["humidity"],
        location_lat=weather_data["location_lat"],
        location_lon=weather_data["location_lon"],
        weather_condition=weather_data["weather_condition"]
    )
    
    db.add(db_weather)
    db.commit()
    
    return {
        "current_weather": weather_data,
        "hydration_adjustment": weather_service.calculate_hydration_adjustment(
            weather_data["temperature"], 
            weather_data["humidity"]
        )
    }

@router.get("/forecast")
async def get_weather_forecast(
    days: int = 5,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Get weather forecast for user's location"""
    if not current_user.location_lat or not current_user.location_lon:
        raise HTTPException(
            status_code=400,
            detail="User location not set. Please update your location in profile."
        )
    
    forecast_data = await weather_service.get_weather_forecast(
        current_user.location_lat, 
        current_user.location_lon, 
        days
    )
    
    if not forecast_data:
        raise HTTPException(
            status_code=503,
            detail="Weather forecast service temporarily unavailable"
        )
    
    return forecast_data

@router.get("/history", response_model=List[WeatherDataSchema])
async def get_weather_history(
    days: int = 7,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Get historical weather data"""
    from datetime import datetime, timedelta
    
    cutoff_time = datetime.utcnow() - timedelta(days=days)
    
    weather_history = db.query(WeatherData).filter(
        WeatherData.user_id == current_user.id,
        WeatherData.timestamp >= cutoff_time
    ).order_by(WeatherData.timestamp.desc()).all()
    
    return weather_history

@router.post("/update-location")
async def update_user_location(
    lat: float,
    lon: float,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Update user's location and get current weather"""
    # Update user location
    current_user.location_lat = lat
    current_user.location_lon = lon
    db.commit()
    
    # Get current weather for new location
    weather_data = await weather_service.get_current_weather(lat, lon)
    
    if weather_data:
        # Save weather data
        db_weather = WeatherData(
            user_id=current_user.id,
            temperature=weather_data["temperature"],
            humidity=weather_data["humidity"],
            location_lat=lat,
            location_lon=lon,
            weather_condition=weather_data["weather_condition"]
        )
        
        db.add(db_weather)
        db.commit()
        
        return {
            "message": "Location updated successfully",
            "weather": weather_data,
            "hydration_adjustment": weather_service.calculate_hydration_adjustment(
                weather_data["temperature"], 
                weather_data["humidity"]
            )
        }
    
    return {"message": "Location updated successfully"}


import httpx
from typing import Dict, Optional
from app.core.config import settings
import logging

logger = logging.getLogger(__name__)

class WeatherService:
    def __init__(self):
        self.api_key = settings.OPENWEATHER_API_KEY
        self.base_url = "http://api.openweathermap.org/data/2.5"
    
    async def get_current_weather(self, lat: float, lon: float) -> Optional[Dict]:
        """
        Get current weather data for given coordinates
        """
        try:
            async with httpx.AsyncClient() as client:
                url = f"{self.base_url}/weather"
                params = {
                    "lat": lat,
                    "lon": lon,
                    "appid": self.api_key,
                    "units": "metric"
                }
                
                response = await client.get(url, params=params)
                response.raise_for_status()
                
                data = response.json()
                
                return {
                    "temperature": data["main"]["temp"],
                    "humidity": data["main"]["humidity"],
                    "weather_condition": data["weather"][0]["main"].lower(),
                    "feels_like": data["main"]["feels_like"],
                    "pressure": data["main"]["pressure"],
                    "wind_speed": data["wind"]["speed"],
                    "location_lat": lat,
                    "location_lon": lon
                }
                
        except httpx.HTTPError as e:
            logger.error(f"Weather API HTTP error: {e}")
            return None
        except Exception as e:
            logger.error(f"Weather API error: {e}")
            return None
    
    async def get_weather_forecast(self, lat: float, lon: float, days: int = 5) -> Optional[Dict]:
        """
        Get weather forecast for given coordinates
        """
        try:
            async with httpx.AsyncClient() as client:
                url = f"{self.base_url}/forecast"
                params = {
                    "lat": lat,
                    "lon": lon,
                    "appid": self.api_key,
                    "units": "metric",
                    "cnt": days * 8  # 8 forecasts per day (every 3 hours)
                }
                
                response = await client.get(url, params=params)
                response.raise_for_status()
                
                data = response.json()
                
                # Process forecast data
                forecasts = []
                for item in data["list"]:
                    forecasts.append({
                        "datetime": item["dt_txt"],
                        "temperature": item["main"]["temp"],
                        "humidity": item["main"]["humidity"],
                        "weather_condition": item["weather"][0]["main"].lower(),
                        "feels_like": item["main"]["feels_like"]
                    })
                
                return {
                    "forecasts": forecasts,
                    "location_lat": lat,
                    "location_lon": lon
                }
                
        except httpx.HTTPError as e:
            logger.error(f"Weather forecast API HTTP error: {e}")
            return None
        except Exception as e:
            logger.error(f"Weather forecast API error: {e}")
            return None
    
    def calculate_hydration_adjustment(self, temperature: float, humidity: float) -> float:
        """
        Calculate hydration adjustment factor based on weather conditions
        """
        base_adjustment = 1.0
        
        # Temperature adjustment (increase hydration for hot weather)
        if temperature > 25:
            temp_adjustment = 1 + ((temperature - 25) * 0.02)  # 2% increase per degree above 25°C
        elif temperature < 15:
            temp_adjustment = 1 - ((15 - temperature) * 0.01)  # 1% decrease per degree below 15°C
        else:
            temp_adjustment = 1.0
        
        # Humidity adjustment (increase hydration for low humidity)
        if humidity < 40:
            humidity_adjustment = 1 + ((40 - humidity) * 0.01)  # 1% increase per 10% below 40%
        elif humidity > 80:
            humidity_adjustment = 1 - ((humidity - 80) * 0.005)  # 0.5% decrease per 10% above 80%
        else:
            humidity_adjustment = 1.0
        
        # Combine adjustments
        final_adjustment = base_adjustment * temp_adjustment * humidity_adjustment
        
        # Cap adjustment between 0.8 and 1.5
        return max(0.8, min(1.5, final_adjustment))

# Global instance
weather_service = WeatherService()


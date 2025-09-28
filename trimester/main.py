from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from typing import Optional
import httpx
import asyncio
from models import PregnancyWeek, PregnancyResponse, BabySize, QuickActionResponse, SymptomInfo, ScreeningInfo, WellnessInfo, NutritionInfo
from pregnancy_data import PregnancyDataService
from openai_service import OpenAIBabySizeService
from baby_image_generator import BabySizeImageGenerator
from config import settings

app = FastAPI(
    title="Pregnancy Week Development API",
    description="API for getting key developments and information for each pregnancy week",
    version="1.0.0"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize services
pregnancy_service = PregnancyDataService()
openai_service = None
image_generator = BabySizeImageGenerator()

# Initialize OpenAI service if API key is available
try:
    openai_service = OpenAIBabySizeService()
except ValueError as e:
    print(f"Warning: OpenAI service not available: {e}")
    print("Baby size information will use fallback data.")

@app.get("/", response_model=dict)
async def root():
    """Root endpoint with API information"""
    return {
        "message": "Pregnancy Week Development API",
        "version": "1.0.0",
        "endpoints": {
            "get_week": "/pregnancy/week/{week}",
            "get_all_weeks": "/pregnancy/weeks",
            "health": "/health"
        }
    }

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "message": "API is running"}

@app.get("/pregnancy/week/{week}", response_model=PregnancyResponse)
async def get_pregnancy_week(week: int, use_openai: bool = Query(False, description="Use OpenAI for baby size information")):
    """
    Get pregnancy week information including key developments
    
    Args:
        week: Pregnancy week (1-40)
        use_openai: Whether to use OpenAI for baby size information
    
    Returns:
        PregnancyWeek data with key developments, baby size, symptoms, and tips
    """
    try:
        if week < 1 or week > 40:
            raise HTTPException(
                status_code=400, 
                detail="Week must be between 1 and 40"
            )
        
        week_data = pregnancy_service.get_week_data(week)
        
        # Use OpenAI for baby size if requested and available
        if use_openai and openai_service:
            try:
                ai_baby_size = await openai_service.get_baby_size_for_week(week)
                week_data.baby_size = ai_baby_size
            except Exception as e:
                print(f"OpenAI baby size generation failed: {e}")
                # Continue with fallback data
        
        return PregnancyResponse(
            success=True,
            data=week_data,
            message=f"Successfully retrieved data for week {week}"
        )
    
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")

@app.get("/pregnancy/weeks", response_model=dict)
async def get_all_pregnancy_weeks():
    """
    Get all available pregnancy week data
    
    Returns:
        Dictionary containing all pregnancy week data
    """
    try:
        all_weeks = pregnancy_service.get_all_weeks()
        return {
            "success": True,
            "data": all_weeks,
            "message": f"Successfully retrieved data for {len(all_weeks)} weeks"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")

@app.get("/pregnancy/week/{week}/developments", response_model=dict)
async def get_week_developments(week: int):
    """
    Get only the key developments for a specific week
    
    Args:
        week: Pregnancy week (1-40)
    
    Returns:
        Key developments for the specified week
    """
    try:
        if week < 1 or week > 40:
            raise HTTPException(
                status_code=400, 
                detail="Week must be between 1 and 40"
            )
        
        week_data = pregnancy_service.get_week_data(week)
        
        return {
            "success": True,
            "week": week,
            "developments": week_data.key_developments,
            "message": f"Successfully retrieved developments for week {week}"
        }
    
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")

@app.get("/pregnancy/trimester/{trimester}", response_model=dict)
async def get_trimester_weeks(trimester: int):
    """
    Get all weeks for a specific trimester
    
    Args:
        trimester: Trimester number (1, 2, or 3)
    
    Returns:
        All weeks in the specified trimester
    """
    try:
        if trimester not in [1, 2, 3]:
            raise HTTPException(
                status_code=400, 
                detail="Trimester must be 1, 2, or 3"
            )
        
        all_weeks = pregnancy_service.get_all_weeks()
        trimester_weeks = {
            week: data for week, data in all_weeks.items() 
            if data.trimester == trimester
        }
        
        return {
            "success": True,
            "trimester": trimester,
            "weeks": trimester_weeks,
            "message": f"Successfully retrieved weeks for trimester {trimester}"
        }
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")

@app.get("/pregnancy/week/{week}/baby-size", response_model=dict)
async def get_baby_size_openai(week: int):
    """
    Get AI-powered baby size information for a specific week
    
    Args:
        week: Pregnancy week (1-40)
    
    Returns:
        Detailed baby size information generated by OpenAI
    """
    try:
        if week < 1 or week > 40:
            raise HTTPException(
                status_code=400, 
                detail="Week must be between 1 and 40"
            )
        
        if not openai_service:
            raise HTTPException(
                status_code=503, 
                detail="OpenAI service not available. Please check your API key configuration."
            )
        
        # Get basic baby size
        baby_size = await openai_service.get_baby_size_for_week(week)
        
        # Get detailed information
        detailed_info = await openai_service.get_detailed_baby_info(week)
        
        return {
            "success": True,
            "week": week,
            "baby_size": baby_size,
            "detailed_info": detailed_info,
            "message": f"Successfully generated AI-powered baby size for week {week}"
        }
    
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")

@app.get("/pregnancy/openai/status", response_model=dict)
async def get_openai_status():
    """
    Check if OpenAI service is available and configured
    
    Returns:
        OpenAI service status and configuration
    """
    return {
        "success": True,
        "openai_available": openai_service is not None,
        "model": settings.OPENAI_MODEL if openai_service else None,
        "api_key_configured": bool(settings.OPENAI_API_KEY),
        "message": "OpenAI service status retrieved successfully"
    }

@app.get("/pregnancy/week/{week}/baby-image", response_model=dict)
async def get_baby_size_image(week: int, style: str = Query("matplotlib", description="Image style: 'matplotlib' or 'simple'")):
    """
    Get a baby size visualization image for a specific week
    
    Args:
        week: Pregnancy week (1-40)
        style: Image style ('matplotlib' for detailed, 'simple' for basic)
    
    Returns:
        Base64 encoded image data
    """
    try:
        if week < 1 or week > 40:
            raise HTTPException(
                status_code=400, 
                detail="Week must be between 1 and 40"
            )
        
        # Generate image based on style
        if style == "simple":
            image_data = image_generator.generate_simple_baby_image(week)
        else:
            image_data = image_generator.generate_baby_size_image(week)
        
        return {
            "success": True,
            "week": week,
            "image_data": image_data,
            "style": style,
            "message": f"Successfully generated baby size image for week {week}"
        }
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error generating image: {str(e)}")

@app.get("/pregnancy/week/{week}/symptoms", response_model=QuickActionResponse)
async def get_early_symptoms(week: int):
    """
    Get AI-powered early symptoms information for a specific week
    
    Args:
        week: Pregnancy week (1-40)
    
    Returns:
        Detailed symptoms information with relief tips and when to call doctor
    """
    try:
        if week < 1 or week > 40:
            raise HTTPException(
                status_code=400, 
                detail="Week must be between 1 and 40"
            )
        
        if not openai_service:
            raise HTTPException(
                status_code=503, 
                detail="OpenAI service not available. Please check your API key configuration."
            )
        
        # Get week data for trimester info
        week_data = pregnancy_service.get_week_data(week)
        
        # Get AI-powered symptoms
        symptoms_info = await openai_service.get_early_symptoms(week)
        
        return QuickActionResponse(
            success=True,
            week=week,
            trimester=week_data.trimester,
            action_type="early_symptoms",
            data=symptoms_info.dict(),
            message=f"Successfully generated early symptoms information for week {week}"
        )
    
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")

@app.get("/pregnancy/week/{week}/screening", response_model=QuickActionResponse)
async def get_prenatal_screening(week: int):
    """
    Get AI-powered prenatal screening information for a specific week
    
    Args:
        week: Pregnancy week (1-40)
    
    Returns:
        Detailed screening information with recommended tests and timing
    """
    try:
        if week < 1 or week > 40:
            raise HTTPException(
                status_code=400, 
                detail="Week must be between 1 and 40"
            )
        
        if not openai_service:
            raise HTTPException(
                status_code=503, 
                detail="OpenAI service not available. Please check your API key configuration."
            )
        
        # Get week data for trimester info
        week_data = pregnancy_service.get_week_data(week)
        
        # Get AI-powered screening
        screening_info = await openai_service.get_prenatal_screening(week)
        
        return QuickActionResponse(
            success=True,
            week=week,
            trimester=week_data.trimester,
            action_type="prenatal_screening",
            data=screening_info.dict(),
            message=f"Successfully generated prenatal screening information for week {week}"
        )
    
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")

@app.get("/pregnancy/week/{week}/wellness", response_model=QuickActionResponse)
async def get_wellness_tips(week: int):
    """
    Get AI-powered wellness tips for a specific week
    
    Args:
        week: Pregnancy week (1-40)
    
    Returns:
        Detailed wellness information with exercise, sleep, and stress management tips
    """
    try:
        if week < 1 or week > 40:
            raise HTTPException(
                status_code=400, 
                detail="Week must be between 1 and 40"
            )
        
        if not openai_service:
            raise HTTPException(
                status_code=503, 
                detail="OpenAI service not available. Please check your API key configuration."
            )
        
        # Get week data for trimester info
        week_data = pregnancy_service.get_week_data(week)
        
        # Get AI-powered wellness tips
        wellness_info = await openai_service.get_wellness_tips(week)
        
        return QuickActionResponse(
            success=True,
            week=week,
            trimester=week_data.trimester,
            action_type="wellness_tips",
            data=wellness_info.dict(),
            message=f"Successfully generated wellness tips for week {week}"
        )
    
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")

@app.get("/pregnancy/week/{week}/nutrition", response_model=QuickActionResponse)
async def get_nutrition_tips(week: int):
    """
    Get AI-powered nutrition tips for a specific week
    
    Args:
        week: Pregnancy week (1-40)
    
    Returns:
        Detailed nutrition information with essential nutrients and meal suggestions
    """
    try:
        if week < 1 or week > 40:
            raise HTTPException(
                status_code=400, 
                detail="Week must be between 1 and 40"
            )
        
        if not openai_service:
            raise HTTPException(
                status_code=503, 
                detail="OpenAI service not available. Please check your API key configuration."
            )
        
        # Get week data for trimester info
        week_data = pregnancy_service.get_week_data(week)
        
        # Get AI-powered nutrition tips
        nutrition_info = await openai_service.get_nutrition_tips(week)
        
        return QuickActionResponse(
            success=True,
            week=week,
            trimester=week_data.trimester,
            action_type="nutrition_tips",
            data=nutrition_info.dict(),
            message=f"Successfully generated nutrition tips for week {week}"
        )
    
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host=settings.HOST,
        port=settings.PORT,
        reload=settings.DEBUG
    )

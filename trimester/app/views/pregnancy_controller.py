from fastapi import APIRouter, HTTPException, Query, Depends
from typing import Optional
from app.models.pregnancy_models import (
    PregnancyResponse, 
    QuickActionResponse, 
    PregnancyWeek
)
from app.services.pregnancy_data_service import PregnancyDataService
from app.services.openai_service import OpenAIBabySizeService
from app.dependencies import container

class PregnancyController:
    def __init__(self):
        self.router = APIRouter(prefix="/pregnancy", tags=["pregnancy"])
        self._setup_routes()
    
    def get_pregnancy_service(self):
        """Dependency to get pregnancy service"""
        return container.pregnancy_service
    
    def get_openai_service(self):
        """Dependency to get OpenAI service"""
        return container.openai_service
    
    def _setup_routes(self):
        """Setup all the API routes"""
        
        @self.router.get("/week/{week}", response_model=PregnancyResponse)
        async def get_pregnancy_week(
            week: int, 
            use_openai: bool = Query(False, description="Use OpenAI for baby size information"),
            pregnancy_service: PregnancyDataService = Depends(self.get_pregnancy_service),
            openai_service: OpenAIBabySizeService = Depends(self.get_openai_service)
        ):
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
        
        @self.router.get("/weeks", response_model=dict)
        async def get_all_pregnancy_weeks(
            pregnancy_service: PregnancyDataService = Depends(self.get_pregnancy_service)
        ):
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
        
        @self.router.get("/week/{week}/developments", response_model=dict)
        async def get_week_developments(
            week: int,
            pregnancy_service: PregnancyDataService = Depends(self.get_pregnancy_service)
        ):
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
        
        @self.router.get("/trimester/{trimester}", response_model=dict)
        async def get_trimester_weeks(
            trimester: int,
            pregnancy_service: PregnancyDataService = Depends(self.get_pregnancy_service)
        ):
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
    
    def get_router(self):
        """Get the FastAPI router"""
        return self.router
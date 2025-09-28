from fastapi import APIRouter, HTTPException, Query, Depends
from app.services.baby_image_service import BabySizeImageGenerator
from app.dependencies import container

class ImageController:
    def __init__(self):
        self.router = APIRouter(prefix="/pregnancy", tags=["images"])
        self._setup_routes()
    
    def get_image_generator(self):
        """Dependency to get image generator service"""
        return container.image_generator
    
    def _setup_routes(self):
        """Setup all the image-related API routes"""
        
        @self.router.get("/week/{week}/baby-image", response_model=dict)
        async def get_baby_size_image(
            week: int, 
            style: str = Query("matplotlib", description="Image style: 'matplotlib' or 'simple'"),
            image_generator: BabySizeImageGenerator = Depends(self.get_image_generator)
        ):
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
    
    def get_router(self):
        """Get the FastAPI router"""
        return self.router
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config.settings import settings
from app.views import PregnancyController, OpenAIController, ImageController

def create_app() -> FastAPI:
    """Create and configure the FastAPI application"""
    
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
    
    # Initialize controllers
    pregnancy_controller = PregnancyController()
    openai_controller = OpenAIController()
    image_controller = ImageController()
    
    # Include routers
    app.include_router(pregnancy_controller.get_router())
    app.include_router(openai_controller.get_router())
    app.include_router(image_controller.get_router())
    
    # Add root endpoints
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
    
    return app

# Create the app instance
app = create_app()

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "app.main:app",
        host=settings.HOST,
        port=settings.PORT,
        reload=settings.DEBUG
    )

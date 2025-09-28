"""
Pregnancy Week Development API - MVC Version
This is the main entry point for the application using MVC pattern.
"""

from app.main import app

if __name__ == "__main__":
    import uvicorn
    from app.config.settings import settings
    
    uvicorn.run(
        "main_mvc:app",
        host=settings.HOST,
        port=settings.PORT,
        reload=settings.DEBUG
    )

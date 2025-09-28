"""
Dependency injection container for the Pregnancy API
This provides a clean way to manage dependencies across the application
"""

from app.services.pregnancy_data_service import PregnancyDataService
from app.services.openai_service import OpenAIBabySizeService
from app.services.baby_image_service import BabySizeImageGenerator

class DIContainer:
    """Dependency Injection Container"""
    
    def __init__(self):
        self._pregnancy_service = None
        self._openai_service = None
        self._image_generator = None
    
    @property
    def pregnancy_service(self) -> PregnancyDataService:
        """Get pregnancy data service instance"""
        if self._pregnancy_service is None:
            self._pregnancy_service = PregnancyDataService()
        return self._pregnancy_service
    
    @property
    def openai_service(self) -> OpenAIBabySizeService:
        """Get OpenAI service instance"""
        if self._openai_service is None:
            try:
                self._openai_service = OpenAIBabySizeService()
            except ValueError as e:
                print(f"Warning: OpenAI service not available: {e}")
                self._openai_service = None
        return self._openai_service
    
    @property
    def image_generator(self) -> BabySizeImageGenerator:
        """Get baby image generator service instance"""
        if self._image_generator is None:
            self._image_generator = BabySizeImageGenerator()
        return self._image_generator

# Global DI container instance
container = DIContainer()

#!/usr/bin/env python3
"""
Test script to check OpenAI configuration
"""

import os
from app.config import settings
from app.services.openai_service import OpenAIService

def test_openai_config():
    """Test OpenAI configuration"""
    print("🔍 Testing OpenAI Configuration")
    print("=" * 50)
    
    # Check environment variables
    env_key = os.getenv('OPENAI_API_KEY')
    print(f"Environment OPENAI_API_KEY: {'✅ Set' if env_key else '❌ Not set'}")
    if env_key:
        print(f"  Key preview: {env_key[:10]}...")
    
    # Check settings
    print(f"Settings OPENAI_API_KEY: {'✅ Set' if settings.OPENAI_API_KEY else '❌ Not set'}")
    if settings.OPENAI_API_KEY:
        print(f"  Key preview: {settings.OPENAI_API_KEY[:10]}...")
    
    print(f"Settings OPENAI_MODEL: {settings.OPENAI_MODEL}")
    print(f"Settings USE_OPENAI_FALLBACK: {settings.USE_OPENAI_FALLBACK}")
    
    # Test OpenAI service
    print("\n🧪 Testing OpenAI Service")
    print("=" * 50)
    
    try:
        service = OpenAIService()
        is_available = service.is_available()
        print(f"OpenAI Service Available: {'✅ Yes' if is_available else '❌ No'}")
        
        if is_available:
            print("✅ OpenAI service is properly configured and ready to use!")
        else:
            print("❌ OpenAI service is not available. Please set OPENAI_API_KEY in .env file")
            
    except Exception as e:
        print(f"❌ Error testing OpenAI service: {e}")
    
    print("\n📝 To configure OpenAI:")
    print("1. Get your API key from: https://platform.openai.com/api-keys")
    print("2. Add to .env file: OPENAI_API_KEY=your_actual_api_key_here")
    print("3. Restart the backend server")

if __name__ == "__main__":
    test_openai_config()

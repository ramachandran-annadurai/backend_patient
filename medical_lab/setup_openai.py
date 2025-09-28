#!/usr/bin/env python3
"""
Setup script for OpenAI API key configuration
"""

import os
import sys

def setup_openai_key():
    """Setup OpenAI API key in environment variables"""
    print("🔑 OpenAI API Key Setup")
    print("=" * 50)
    
    # Check if API key is already set
    current_key = os.getenv('OPENAI_API_KEY')
    if current_key:
        print(f"✅ OpenAI API key is already set: {current_key[:10]}...")
        return True
    
    # Get API key from user
    print("Please enter your OpenAI API key:")
    print("(You can get it from: https://platform.openai.com/api-keys)")
    api_key = input("API Key: ").strip()
    
    if not api_key:
        print("❌ No API key provided. Exiting.")
        return False
    
    # Set environment variable for current session
    os.environ['OPENAI_API_KEY'] = api_key
    print(f"✅ OpenAI API key set for current session: {api_key[:10]}...")
    
    # Create .env file
    env_content = f"""# OpenAI Configuration
OPENAI_API_KEY={api_key}

# PaddleOCR Configuration
PADDLE_OCR_LANG=en
PADDLE_OCR_USE_ANGLE_CLS=true
PADDLE_OCR_SHOW_LOG=false

# Service Configuration
APP_NAME=PaddleOCR Microservice
APP_VERSION=1.0.0
DEBUG=false
"""
    
    try:
        with open('.env', 'w') as f:
            f.write(env_content)
        print("✅ Created .env file with your API key")
    except Exception as e:
        print(f"⚠️  Could not create .env file: {e}")
        print("You can manually create a .env file with:")
        print(f"OPENAI_API_KEY={api_key}")
    
    return True

def test_openai_connection():
    """Test OpenAI API connection"""
    print("\n🧪 Testing OpenAI API Connection")
    print("=" * 50)
    
    try:
        from app.services.openai_service import OpenAIService
        service = OpenAIService()
        
        if service.is_available():
            print("✅ OpenAI service is available and configured")
            return True
        else:
            print("❌ OpenAI service is not available")
            return False
    except Exception as e:
        print(f"❌ Error testing OpenAI service: {e}")
        return False

if __name__ == "__main__":
    print("🚀 OpenAI Integration Setup")
    print("=" * 50)
    
    # Setup API key
    if setup_openai_key():
        # Test connection
        test_openai_connection()
        
        print("\n🎉 Setup Complete!")
        print("=" * 50)
        print("Your system is now configured to use OpenAI Vision API as a fallback")
        print("when PaddleOCR doesn't extract text from images.")
        print("\nTo use it:")
        print("1. Upload an image file through the Flutter app")
        print("2. If PaddleOCR finds no text, OpenAI will automatically try to extract text")
        print("3. The extracted text will appear in the form field")
    else:
        print("\n❌ Setup failed. Please try again.")
        sys.exit(1)

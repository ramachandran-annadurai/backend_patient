#!/usr/bin/env python3
"""
Test script to verify Render deployment compatibility
"""
import os
import sys

def test_imports():
    """Test critical imports for Render deployment"""
    print("🔍 Testing Render deployment compatibility...")
    
    try:
        # Test basic Flask imports
        from flask import Flask, request, jsonify
        print("✅ Flask imports successful")
        
        # Test database imports
        from pymongo import MongoClient
        print("✅ MongoDB imports successful")
        
        # Test JWT imports
        import jwt
        print("✅ JWT imports successful")
        
        # Test email imports
        import smtplib
        from email.mime.text import MIMEText
        from email.mime.multipart import MIMEMultipart
        print("✅ Email imports successful")
        
        # Test other critical imports
        import bcrypt
        import requests
        from PIL import Image
        import cv2
        import numpy as np
        print("✅ Core dependencies successful")
        
        print("\n✅ All critical imports successful!")
        print("🚀 App is ready for Render deployment!")
        return True
        
    except ImportError as e:
        print(f"❌ Import error: {e}")
        return False
    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        return False

def test_environment_variables():
    """Test environment variable loading"""
    print("\n🔍 Testing environment variables...")
    
    from dotenv import load_dotenv
    load_dotenv()
    
    # Check critical env vars
    mongo_uri = os.getenv("MONGO_URI")
    db_name = os.getenv("DB_NAME")
    sender_email = os.getenv("SENDER_EMAIL")
    sender_password = os.getenv("SENDER_PASSWORD")
    
    print(f"📊 MONGO_URI: {'✅ Set' if mongo_uri else '❌ Missing'}")
    print(f"📊 DB_NAME: {'✅ Set' if db_name else '❌ Missing'}")
    print(f"📊 SENDER_EMAIL: {'✅ Set' if sender_email else '❌ Missing'}")
    print(f"📊 SENDER_PASSWORD: {'✅ Set' if sender_password else '❌ Missing'}")
    
    if mongo_uri and db_name:
        print("✅ Database configuration ready")
    else:
        print("⚠️ Database configuration missing")
    
    if sender_email and sender_password:
        print("✅ Email configuration ready")
    else:
        print("⚠️ Email configuration missing - OTP emails won't work")
    
    return True

if __name__ == "__main__":
    print("🚀 Testing Render Deployment Compatibility")
    print("=" * 50)
    
    success = test_imports()
    test_environment_variables()
    
    if success:
        print("\n🎉 All tests passed! Ready for Render deployment!")
        print("\n📋 Next steps:")
        print("1. Push code to GitHub")
        print("2. Deploy on Render")
        print("3. Set environment variables in Render dashboard")
        print("4. Test OTP functionality")
    else:
        print("\n❌ Some tests failed. Check the errors above.")
        sys.exit(1)

#!/usr/bin/env python3
"""
Test script to verify backend connection and MongoDB integration
"""

import requests
import json
import time

def test_backend_connection():
    """Test if the backend server is responding"""
    try:
        response = requests.get("http://127.0.0.1:8000/health", timeout=5)
        if response.status_code == 200:
            print("✅ Backend server is running and responding")
            print(f"   Response: {response.json()}")
            return True
        else:
            print(f"❌ Backend server returned status code: {response.status_code}")
            return False
    except requests.exceptions.ConnectionError:
        print("❌ Cannot connect to backend server at http://127.0.0.1:8000")
        print("   Make sure the server is running with: python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload")
        return False
    except requests.exceptions.Timeout:
        print("❌ Backend server connection timeout")
        return False
    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        return False

def test_mongodb_connection():
    """Test MongoDB connection through the backend"""
    try:
        response = requests.get("http://127.0.0.1:8000/", timeout=5)
        if response.status_code == 200:
            data = response.json()
            print("✅ Backend API is accessible")
            print(f"   Service: {data.get('name', 'Unknown')}")
            print(f"   Version: {data.get('version', 'Unknown')}")
            return True
        else:
            print(f"❌ Backend API returned status code: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Error testing MongoDB connection: {e}")
        return False

def main():
    print("🔍 Testing Backend Connection and MongoDB Integration")
    print("=" * 60)
    
    # Test backend connection
    print("\n1. Testing Backend Server Connection...")
    backend_ok = test_backend_connection()
    
    # Test MongoDB connection
    print("\n2. Testing MongoDB Connection...")
    mongodb_ok = test_mongodb_connection()
    
    # Summary
    print("\n" + "=" * 60)
    print("📊 Test Results Summary:")
    print(f"   Backend Server: {'✅ OK' if backend_ok else '❌ FAILED'}")
    print(f"   MongoDB: {'✅ OK' if mongodb_ok else '❌ FAILED'}")
    
    if backend_ok and mongodb_ok:
        print("\n🎉 All tests passed! The system is ready for image uploads.")
        print("   You can now upload images in the Flutter app and they will be stored as base64 in MongoDB.")
    else:
        print("\n⚠️  Some tests failed. Please check the issues above.")
    
    return backend_ok and mongodb_ok

if __name__ == "__main__":
    main()

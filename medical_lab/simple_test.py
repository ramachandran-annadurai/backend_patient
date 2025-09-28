#!/usr/bin/env python3
"""
Simple test to check OCR functionality
"""

import requests
import json
import os

def test_simple_upload():
    """Test a simple file upload"""
    print("🔍 Testing simple file upload...")
    
    # Check if test image exists
    test_image_path = "test_image.png"
    if not os.path.exists(test_image_path):
        print(f"❌ Test image not found: {test_image_path}")
        return False
    
    try:
        # Test with a very short timeout first
        with open(test_image_path, 'rb') as f:
            files = {'file': (test_image_path, f, 'image/png')}
            
            print(f"Uploading {test_image_path} to /api/v1/ocr/upload...")
            response = requests.post(
                "http://localhost:8000/api/v1/ocr/upload", 
                files=files, 
                timeout=60  # Longer timeout
            )
        
        print(f"Response status: {response.status_code}")
        print(f"Response headers: {dict(response.headers)}")
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Upload successful!")
            print(f"Success: {result.get('success', False)}")
            print(f"Text: {result.get('extracted_text', 'No text')}")
            return True
        else:
            print(f"❌ Upload failed: {response.status_code}")
            print(f"Response: {response.text}")
            return False
            
    except requests.exceptions.Timeout:
        print("❌ Request timed out - OCR processing is taking too long")
        return False
    except requests.exceptions.RequestException as e:
        print(f"❌ Request error: {e}")
        return False

def test_base64_simple():
    """Test base64 upload with a simple 1x1 pixel image"""
    print("\n🔍 Testing base64 upload...")
    
    # Simple 1x1 pixel PNG
    test_base64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg=="
    
    try:
        payload = {"image": test_base64}
        
        print("Uploading base64 image...")
        response = requests.post(
            "http://localhost:8000/api/v1/ocr/base64",
            json=payload,
            headers={'Content-Type': 'application/json'},
            timeout=30
        )
        
        print(f"Response status: {response.status_code}")
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Base64 upload successful!")
            print(f"Success: {result.get('success', False)}")
            return True
        else:
            print(f"❌ Base64 upload failed: {response.status_code}")
            print(f"Response: {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Base64 upload error: {e}")
        return False

if __name__ == "__main__":
    print("🚀 Simple OCR Test")
    print("=" * 40)
    
    # Test 1: Simple file upload
    upload_success = test_simple_upload()
    
    # Test 2: Base64 upload
    base64_success = test_base64_simple()
    
    print("\n" + "=" * 40)
    print("🎯 Results:")
    print(f"File Upload: {'✅' if upload_success else '❌'}")
    print(f"Base64 Upload: {'✅' if base64_success else '❌'}")
    
    if not upload_success and not base64_success:
        print("\n🔧 The OCR service might be having issues. Check:")
        print("1. Server logs for error messages")
        print("2. If PaddleOCR is properly installed")
        print("3. If all dependencies are available")

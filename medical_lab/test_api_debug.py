#!/usr/bin/env python3
"""
Debug test script for the Medication OCR API
This script will help identify issues with image processing
"""

import requests
import json
import os
import sys
from pathlib import Path

# API Configuration
API_BASE_URL = "http://localhost:8000/api/v1"

def test_api_health():
    """Test if the API is running and healthy"""
    print("🔍 Testing API Health...")
    try:
        response = requests.get("http://localhost:8000/health", timeout=10)
        if response.status_code == 200:
            print("✅ API is healthy!")
            print(f"Response: {response.json()}")
            return True
        else:
            print(f"❌ API health check failed with status: {response.status_code}")
            print(f"Response: {response.text}")
            return False
    except requests.exceptions.RequestException as e:
        print(f"❌ API connection error: {e}")
        return False

def test_ocr_upload_with_test_image():
    """Test OCR upload with a simple test image"""
    print("\n🔍 Testing OCR Upload...")
    
    # Check if test image exists
    test_image_path = "test_image.png"
    if not os.path.exists(test_image_path):
        print(f"❌ Test image not found: {test_image_path}")
        print("Please ensure you have a test image file named 'test_image.png'")
        return False
    
    try:
        # Upload the test image
        with open(test_image_path, 'rb') as f:
            files = {'file': (test_image_path, f, 'image/png')}
            response = requests.post(f"{API_BASE_URL}/ocr/upload", files=files, timeout=30)
        
        print(f"Upload response status: {response.status_code}")
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Upload successful!")
            print(f"Document ID: {result.get('document_id', 'N/A')}")
            print(f"Success: {result.get('success', False)}")
            print(f"Text extracted: {len(result.get('extracted_text', ''))} characters")
            
            if result.get('success'):
                print("\n📝 Extracted Text:")
                print("-" * 50)
                print(result.get('extracted_text', 'No text extracted'))
                print("-" * 50)
                
                # Try to retrieve the original image
                document_id = result.get('document_id')
                if document_id:
                    test_document_retrieval(document_id)
            
            return result
        else:
            print(f"❌ Upload failed with status: {response.status_code}")
            print(f"Response: {response.text}")
            return None
            
    except requests.exceptions.RequestException as e:
        print(f"❌ Upload error: {e}")
        return None

def test_document_retrieval(document_id):
    """Test retrieving document data including original image"""
    print(f"\n🔍 Testing Document Retrieval for ID: {document_id}")
    
    try:
        # Test without base64 data first
        response = requests.get(f"{API_BASE_URL}/documents/{document_id}", timeout=10)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Document retrieval successful!")
            print(f"Success: {result.get('success', False)}")
            
            if result.get('success'):
                doc = result.get('document', {})
                print(f"Filename: {doc.get('filename', 'N/A')}")
                print(f"File Type: {doc.get('file_type', 'N/A')}")
                print(f"File Size: {doc.get('file_size', 0)} bytes")
                print(f"Processing Method: {doc.get('processing_method', 'N/A')}")
        
        # Test with base64 data
        print("\n🔍 Testing Document Retrieval with Base64 Image...")
        response = requests.get(f"{API_BASE_URL}/documents/{document_id}?include_base64=true", timeout=10)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Document retrieval with base64 successful!")
            
            if result.get('success'):
                doc = result.get('document', {})
                has_base64 = bool(doc.get('base64_data'))
                print(f"Base64 data available: {has_base64}")
                
                if has_base64:
                    base64_length = len(doc.get('base64_data', ''))
                    print(f"Base64 data length: {base64_length} characters")
                    
                    # Save the retrieved image for verification
                    save_retrieved_image(doc)
                else:
                    print("❌ No base64 data in response")
        else:
            print(f"❌ Document retrieval with base64 failed: {response.status_code}")
            print(f"Response: {response.text}")
            
    except requests.exceptions.RequestException as e:
        print(f"❌ Document retrieval error: {e}")

def save_retrieved_image(document_data):
    """Save the retrieved base64 image to verify it's working"""
    try:
        import base64
        
        base64_data = document_data.get('base64_data')
        file_type = document_data.get('file_type', 'image/png')
        
        if base64_data:
            # Decode base64 data
            image_data = base64.b64decode(base64_data)
            
            # Determine file extension
            if 'jpeg' in file_type or 'jpg' in file_type:
                ext = 'jpg'
            elif 'png' in file_type:
                ext = 'png'
            else:
                ext = 'bin'
            
            # Save the image
            output_filename = f"retrieved_image.{ext}"
            with open(output_filename, 'wb') as f:
                f.write(image_data)
            
            print(f"✅ Retrieved image saved as: {output_filename}")
            print(f"Image size: {len(image_data)} bytes")
        else:
            print("❌ No base64 data to save")
            
    except Exception as e:
        print(f"❌ Error saving retrieved image: {e}")

def test_base64_upload():
    """Test base64 image upload"""
    print("\n🔍 Testing Base64 Upload...")
    
    # Create a simple test base64 image (1x1 pixel PNG)
    test_base64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg=="
    
    try:
        payload = {
            "image": test_base64
        }
        
        response = requests.post(
            f"{API_BASE_URL}/ocr/base64",
            json=payload,
            headers={'Content-Type': 'application/json'},
            timeout=30
        )
        
        print(f"Base64 upload response status: {response.status_code}")
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Base64 upload successful!")
            print(f"Success: {result.get('success', False)}")
            print(f"Text extracted: {len(result.get('extracted_text', ''))} characters")
            return result
        else:
            print(f"❌ Base64 upload failed: {response.status_code}")
            print(f"Response: {response.text}")
            return None
            
    except requests.exceptions.RequestException as e:
        print(f"❌ Base64 upload error: {e}")
        return None

def main():
    """Main test function"""
    print("🚀 Starting Medication OCR API Debug Tests")
    print("=" * 60)
    
    # Test 1: API Health
    if not test_api_health():
        print("\n❌ API is not accessible. Please ensure the server is running.")
        print("Run: python -m app.main")
        return
    
    # Test 2: OCR Upload (if test image exists)
    upload_result = test_ocr_upload_with_test_image()
    
    # Test 3: Base64 Upload
    base64_result = test_base64_upload()
    
    print("\n" + "=" * 60)
    print("🎯 Test Summary:")
    print(f"API Health: ✅")
    print(f"File Upload: {'✅' if upload_result else '❌'}")
    print(f"Base64 Upload: {'✅' if base64_result else '❌'}")
    
    if not upload_result and not base64_result:
        print("\n🔧 Troubleshooting Tips:")
        print("1. Check if the API server is running: python -m app.main")
        print("2. Verify the API is accessible at: http://localhost:8000")
        print("3. Check server logs for any error messages")
        print("4. Ensure all dependencies are installed: pip install -r requirements.txt")
        print("5. Check if MongoDB is running and accessible")

if __name__ == "__main__":
    main()

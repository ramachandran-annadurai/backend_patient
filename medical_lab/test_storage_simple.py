#!/usr/bin/env python3
"""
Simple test to verify storage functionality
"""

import requests
import json
import base64

# API Configuration
API_BASE_URL = "http://localhost:8000/api/v1"

def test_storage():
    """Test file upload and storage"""
    print("🔍 Testing Storage Functionality...")
    
    # Create a simple test image (1x1 pixel PNG)
    test_image_data = base64.b64decode("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==")
    
    # Test file upload
    files = {
        'file': ('test_image.png', test_image_data, 'image/png')
    }
    
    try:
        print("📤 Uploading test image...")
        response = requests.post(f"{API_BASE_URL}/ocr/upload", files=files, timeout=30)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Upload successful!")
            print(f"📋 Response keys: {list(result.keys())}")
            
            # Check if storage fields are present
            if "document_id" in result:
                print(f"✅ Document ID: {result['document_id']}")
            else:
                print("❌ Document ID missing")
                
            if "patient_id" in result:
                print(f"✅ Patient ID: {result['patient_id']}")
            else:
                print("❌ Patient ID missing")
                
            if "storage_type" in result:
                print(f"✅ Storage Type: {result['storage_type']}")
            else:
                print("❌ Storage Type missing")
                
            # Test retrieving the document
            if "document_id" in result:
                print(f"🔍 Testing document retrieval...")
                doc_response = requests.get(f"{API_BASE_URL}/documents/{result['document_id']}?include_base64=true")
                
                if doc_response.status_code == 200:
                    doc_data = doc_response.json()
                    print("✅ Document retrieval successful!")
                    print(f"📄 Document filename: {doc_data['document']['filename']}")
                    print(f"📄 Document type: {doc_data['document']['document_type']}")
                    print(f"📄 Has base64 data: {'base64_data' in doc_data['document']}")
                else:
                    print(f"❌ Document retrieval failed: {doc_response.status_code}")
                    
        else:
            print(f"❌ Upload failed: {response.status_code}")
            print(f"Response: {response.text}")
            
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    test_storage()

#!/usr/bin/env python3
"""
Test base64 storage functionality (non-image files)
"""

import requests
import json

# API Configuration
API_BASE_URL = "http://localhost:8000/api/v1"

def test_base64_storage():
    """Test base64 storage for non-image files"""
    print("🔍 Testing Base64 Storage Functionality...")
    
    # Create a simple text file
    test_content = "This is a test medical document.\nPatient: arunkumar.loganathan.lm@gmail.com\nDate: 2025-09-17\nContent: Test medical record for storage verification."
    
    # Test file upload (text file)
    files = {
        'file': ('test_medical_record.txt', test_content.encode('utf-8'), 'text/plain')
    }
    
    try:
        print("📤 Uploading test text file...")
        response = requests.post(f"{API_BASE_URL}/ocr/upload", files=files, timeout=10)
        
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
                
            if "processing_type" in result:
                print(f"✅ Processing Type: {result['processing_type']}")
            else:
                print("❌ Processing Type missing")
                
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
                    
                    # Test base64 to text conversion
                    if 'base64_data' in doc_data['document']:
                        import base64
                        decoded_content = base64.b64decode(doc_data['document']['base64_data']).decode('utf-8')
                        print(f"📄 Decoded content: {decoded_content[:100]}...")
                        print("✅ Base64 to text conversion successful!")
                else:
                    print(f"❌ Document retrieval failed: {doc_response.status_code}")
                    
        else:
            print(f"❌ Upload failed: {response.status_code}")
            print(f"Response: {response.text}")
            
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    test_base64_storage()

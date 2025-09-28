#!/usr/bin/env python3
"""
Test to verify storage fields are returned in API response
"""

import requests
import json

# API Configuration
API_BASE_URL = "http://localhost:8000/api/v1"

def test_storage_fields():
    """Test that storage fields are returned in API response"""
    print("🔍 Testing Storage Fields in API Response...")
    
    # Create a simple text file
    test_content = "Test medical document for storage verification."
    
    # Test file upload (text file)
    files = {
        'file': ('test_storage.txt', test_content.encode('utf-8'), 'text/plain')
    }
    
    try:
        print("📤 Uploading test file...")
        response = requests.post(f"{API_BASE_URL}/ocr/upload", files=files, timeout=15)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Upload successful!")
            print(f"📋 Response keys: {list(result.keys())}")
            
            # Check for storage fields
            storage_fields = ['document_id', 'patient_id', 'storage_type', 'processing_type', 'is_image']
            
            for field in storage_fields:
                if field in result:
                    print(f"✅ {field}: {result[field]}")
                else:
                    print(f"❌ {field}: Missing")
                    
            # Test medical history retrieval
            if 'patient_id' in result:
                print(f"\n🔍 Testing medical history retrieval...")
                history_response = requests.get(f"{API_BASE_URL}/patients/{result['patient_id']}/documents")
                
                if history_response.status_code == 200:
                    history_data = history_response.json()
                    print(f"✅ Medical history retrieved: {len(history_data.get('documents', []))} documents")
                    
                    if history_data.get('documents'):
                        latest_doc = history_data['documents'][0]
                        print(f"📄 Latest document: {latest_doc.get('filename')} (ID: {latest_doc.get('id')})")
                else:
                    print(f"❌ Medical history retrieval failed: {history_response.status_code}")
                    
        else:
            print(f"❌ Upload failed: {response.status_code}")
            print(f"Response: {response.text}")
            
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    test_storage_fields()

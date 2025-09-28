#!/usr/bin/env python3
"""
Test API response to see what fields are included
"""

import requests
import json

def test_api_response():
    """Test API response fields"""
    print("🔍 Testing API Response Fields...")
    
    try:
        with open("test_image.png", 'rb') as f:
            files = {'file': ('test_image.png', f, 'image/png')}
            response = requests.post("http://localhost:8000/api/v1/ocr/upload", files=files, timeout=60)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ API Response Fields:")
            for key, value in result.items():
                if key in ['document_id', 'patient_id', 'processing_type', 'is_image', 'storage_type']:
                    print(f"  🔍 {key}: {value}")
                else:
                    print(f"  📄 {key}: {type(value).__name__}")
            
            # Check if the fields we want are present
            has_doc_id = 'document_id' in result
            has_patient_id = 'patient_id' in result
            has_storage_type = 'storage_type' in result
            
            print(f"\n📊 Field Analysis:")
            print(f"  document_id present: {has_doc_id}")
            print(f"  patient_id present: {has_patient_id}")
            print(f"  storage_type present: {has_storage_type}")
            
            if has_doc_id and has_patient_id:
                print("✅ All required fields are present!")
                return True
            else:
                print("❌ Some required fields are missing!")
                return False
        else:
            print(f"❌ API request failed: {response.status_code}")
            print(f"Response: {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

if __name__ == "__main__":
    test_api_response()

#!/usr/bin/env python3
"""
Debug script to test storage functionality
"""

import requests
import json

def test_storage_debug():
    """Test storage with detailed debugging"""
    print("🔍 Testing Storage with Debug Info...")
    
    # Test image upload
    try:
        with open("test_image.png", 'rb') as f:
            files = {'file': ('test_image.png', f, 'image/png')}
            response = requests.post("http://localhost:8000/api/v1/ocr/upload", files=files, timeout=60)
        
        print(f"Response Status: {response.status_code}")
        print(f"Response Headers: {dict(response.headers)}")
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Upload Response:")
            print(json.dumps(result, indent=2))
            
            # Check if we have document_id and patient_id
            doc_id = result.get('document_id')
            patient_id = result.get('patient_id')
            
            if doc_id and patient_id:
                print(f"\n✅ Storage successful!")
                print(f"Document ID: {doc_id}")
                print(f"Patient ID: {patient_id}")
                
                # Test retrieving the document
                print(f"\n🔍 Testing document retrieval...")
                doc_response = requests.get(f"http://localhost:8000/api/v1/documents/{doc_id}?include_base64=true")
                print(f"Document Response Status: {doc_response.status_code}")
                
                if doc_response.status_code == 200:
                    doc_data = doc_response.json()
                    print("✅ Document retrieved:")
                    print(json.dumps(doc_data, indent=2))
                else:
                    print(f"❌ Document retrieval failed: {doc_response.text}")
                
                # Test retrieving patient documents
                print(f"\n🔍 Testing patient documents retrieval...")
                patient_response = requests.get(f"http://localhost:8000/api/v1/patients/{patient_id}/documents")
                print(f"Patient Response Status: {patient_response.status_code}")
                
                if patient_response.status_code == 200:
                    patient_data = patient_response.json()
                    print("✅ Patient documents retrieved:")
                    print(json.dumps(patient_data, indent=2))
                else:
                    print(f"❌ Patient documents retrieval failed: {patient_response.text}")
            else:
                print(f"❌ Storage failed - no document_id or patient_id returned")
                print(f"Document ID: {doc_id}")
                print(f"Patient ID: {patient_id}")
        else:
            print(f"❌ Upload failed: {response.text}")
            
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    test_storage_debug()

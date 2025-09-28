#!/usr/bin/env python3
"""
Test storage directly without OCR processing
"""

import requests
import json
import base64

# API Configuration
API_BASE_URL = "http://localhost:8000/api/v1"

def test_direct_storage():
    """Test storage by directly calling the medical history endpoint"""
    print("🔍 Testing Direct Storage Access...")
    
    try:
        # Test medical history retrieval
        patient_id = "arunkumar.loganathan.lm@gmail.com"
        print(f"🔍 Testing medical history for patient: {patient_id}")
        
        response = requests.get(f"{API_BASE_URL}/patients/{patient_id}/documents", timeout=10)
        
        if response.status_code == 200:
            data = response.json()
            print("✅ Medical history retrieved successfully!")
            print(f"📋 Response keys: {list(data.keys())}")
            
            documents = data.get('documents', [])
            print(f"📄 Found {len(documents)} documents")
            
            for i, doc in enumerate(documents):
                print(f"📄 Document {i+1}:")
                print(f"   - ID: {doc.get('id')}")
                print(f"   - Filename: {doc.get('filename')}")
                print(f"   - Type: {doc.get('document_type')}")
                print(f"   - Patient ID: {doc.get('patient_id')}")
                print(f"   - Created: {doc.get('created_at')}")
                
                # Test retrieving individual document
                if doc.get('id'):
                    print(f"   🔍 Testing document retrieval...")
                    doc_response = requests.get(f"{API_BASE_URL}/documents/{doc['id']}?include_base64=true", timeout=10)
                    
                    if doc_response.status_code == 200:
                        doc_data = doc_response.json()
                        print(f"   ✅ Document retrieved successfully!")
                        print(f"   📄 Has base64 data: {'base64_data' in doc_data['document']}")
                        
                        # Test base64 to content conversion
                        if 'base64_data' in doc_data['document']:
                            try:
                                decoded_content = base64.b64decode(doc_data['document']['base64_data'])
                                print(f"   📄 Decoded content length: {len(decoded_content)} bytes")
                                print(f"   📄 Content preview: {decoded_content[:50]}...")
                                print("   ✅ Base64 to content conversion successful!")
                            except Exception as e:
                                print(f"   ❌ Base64 conversion failed: {e}")
                    else:
                        print(f"   ❌ Document retrieval failed: {doc_response.status_code}")
                        
        else:
            print(f"❌ Medical history retrieval failed: {response.status_code}")
            print(f"Response: {response.text}")
            
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    test_direct_storage()

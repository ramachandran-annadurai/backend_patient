#!/usr/bin/env python3
"""
Test API endpoint directly
"""

import requests
import json

# API Configuration
API_BASE_URL = "http://localhost:8000/api/v1"

def test_api_endpoint():
    """Test API endpoint directly"""
    print("🔍 Testing API Endpoint Directly...")
    
    # Test health endpoint
    try:
        print("🔍 Testing health endpoint...")
        response = requests.get("http://localhost:8000/health", timeout=5)
        if response.status_code == 200:
            print("✅ Health endpoint working")
        else:
            print(f"❌ Health endpoint failed: {response.status_code}")
            return
    except Exception as e:
        print(f"❌ Health endpoint error: {e}")
        return
    
    # Test medical history endpoint
    try:
        print("🔍 Testing medical history endpoint...")
        patient_id = "arunkumar.loganathan.lm@gmail.com"
        response = requests.get(f"{API_BASE_URL}/patients/{patient_id}/documents", timeout=10)
        
        if response.status_code == 200:
            data = response.json()
            print("✅ Medical history endpoint working")
            print(f"📄 Found {len(data.get('documents', []))} documents")
            
            if data.get('documents'):
                latest_doc = data['documents'][0]
                print(f"📄 Latest document: {latest_doc.get('filename')} (ID: {latest_doc.get('id')})")
                
                # Test document retrieval
                if latest_doc.get('id'):
                    print(f"🔍 Testing document retrieval...")
                    doc_response = requests.get(f"{API_BASE_URL}/documents/{latest_doc['id']}?include_base64=true", timeout=10)
                    
                    if doc_response.status_code == 200:
                        doc_data = doc_response.json()
                        print("✅ Document retrieval working")
                        print(f"📄 Has base64 data: {'base64_data' in doc_data['document']}")
                    else:
                        print(f"❌ Document retrieval failed: {doc_response.status_code}")
        else:
            print(f"❌ Medical history endpoint failed: {response.status_code}")
            
    except Exception as e:
        print(f"❌ Medical history endpoint error: {e}")

if __name__ == "__main__":
    test_api_endpoint()

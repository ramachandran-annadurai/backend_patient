#!/usr/bin/env python3
"""
Test the direct storage endpoint
"""

import requests
import json

# API Configuration
API_BASE_URL = "http://localhost:8000/api/v1"

def test_direct_storage():
    """Test the direct storage endpoint"""
    print("🔍 Testing Direct Storage Endpoint...")
    
    try:
        # Test the direct storage endpoint
        print("📤 Testing direct storage endpoint...")
        response = requests.post(f"{API_BASE_URL}/test-storage", timeout=10)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Direct storage successful!")
            print(f"📋 Response: {json.dumps(result, indent=2)}")
            
            # Check if document was stored
            if result.get('document_id'):
                print(f"✅ Document ID: {result['document_id']}")
                
                # Test document retrieval
                print(f"🔍 Testing document retrieval...")
                doc_response = requests.get(f"{API_BASE_URL}/documents/{result['document_id']}?include_base64=true", timeout=10)
                
                if doc_response.status_code == 200:
                    doc_data = doc_response.json()
                    print("✅ Document retrieval successful!")
                    print(f"📄 Document: {doc_data['document']['filename']}")
                else:
                    print(f"❌ Document retrieval failed: {doc_response.status_code}")
            else:
                print("❌ No document ID returned")
                
        else:
            print(f"❌ Direct storage failed: {response.status_code}")
            print(f"Response: {response.text}")
            
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    test_direct_storage()

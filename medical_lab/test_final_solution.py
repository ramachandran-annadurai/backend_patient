#!/usr/bin/env python3
"""
Test the final solution with all fixes
"""

import requests
import json

# API Configuration
API_BASE_URL = "http://localhost:8000/api/v1"

def test_final_solution():
    """Test the complete solution"""
    print("🔍 Testing Final Solution...")
    
    # Create a simple text file
    test_content = "Final test medical document for storage verification."
    
    # Test file upload (text file)
    files = {
        'file': ('final_test.txt', test_content.encode('utf-8'), 'text/plain')
    }
    
    try:
        print("📤 Uploading test file...")
        response = requests.post(f"{API_BASE_URL}/ocr/upload", files=files, timeout=30)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Upload successful!")
            print(f"📋 Response keys: {list(result.keys())}")
            
            # Check for storage fields
            storage_fields = ['document_id', 'patient_id', 'storage_type', 'processing_type', 'is_image']
            
            for field in storage_fields:
                if field in result and result[field] is not None:
                    print(f"✅ {field}: {result[field]}")
                else:
                    print(f"❌ {field}: {result.get(field, 'Missing')}")
                    
            # Test medical history retrieval
            if result.get('patient_id'):
                print(f"\n🔍 Testing medical history retrieval...")
                history_response = requests.get(f"{API_BASE_URL}/patients/{result['patient_id']}/documents")
                
                if history_response.status_code == 200:
                    history_data = history_response.json()
                    print(f"✅ Medical history retrieved: {len(history_data.get('documents', []))} documents")
                    
                    if history_data.get('documents'):
                        latest_doc = history_data['documents'][0]
                        print(f"📄 Latest document: {latest_doc.get('filename')} (ID: {latest_doc.get('id')})")
                        
                        # Test document retrieval with base64
                        if latest_doc.get('id'):
                            print(f"🔍 Testing document retrieval with base64...")
                            doc_response = requests.get(f"{API_BASE_URL}/documents/{latest_doc['id']}?include_base64=true")
                            
                            if doc_response.status_code == 200:
                                doc_data = doc_response.json()
                                print(f"✅ Document retrieved with base64 data!")
                                print(f"📄 Has base64 data: {'base64_data' in doc_data['document']}")
                            else:
                                print(f"❌ Document retrieval failed: {doc_response.status_code}")
                else:
                    print(f"❌ Medical history retrieval failed: {history_response.status_code}")
                    
        else:
            print(f"❌ Upload failed: {response.status_code}")
            print(f"Response: {response.text}")
            
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    test_final_solution()

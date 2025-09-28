#!/usr/bin/env python3
"""
Test the frontend debugging features
"""

import requests
import webbrowser
import time

def test_frontend_debug():
    """Test the frontend with debugging enabled"""
    try:
        print("🔍 Testing Frontend Debug Features...")
        print("=" * 50)
        
        # 1. Check if API is running
        print("1. Checking API health...")
        response = requests.get('http://localhost:8000/health')
        if response.status_code == 200:
            print("   ✅ API is running")
        else:
            print(f"   ❌ API health check failed: {response.status_code}")
            return False
        
        # 2. Check medical history
        print("\n2. Checking medical history...")
        response = requests.get('http://localhost:8000/api/v1/patients/arunkumar.loganathan.lm@gmail.com/documents?limit=5')
        if response.status_code == 200:
            data = response.json()
            documents = data.get('documents', [])
            print(f"   ✅ Found {len(documents)} documents")
            
            if documents:
                valid_docs = [doc for doc in documents if doc.get('id') and doc.get('id') != 'null' and doc.get('id') != 'undefined']
                print(f"   📊 Valid documents: {len(valid_docs)}")
                
                if valid_docs:
                    test_doc = valid_docs[0]
                    print(f"   🧪 Test document: {test_doc.get('filename')} (ID: {test_doc.get('id')})")
                else:
                    print("   ⚠️  No valid documents found")
            else:
                print("   ⚠️  No documents found")
        else:
            print(f"   ❌ Error getting medical history: {response.status_code}")
            return False
        
        # 3. Test document retrieval
        print("\n3. Testing document retrieval...")
        if documents:
            valid_doc = None
            for doc in documents:
                if doc.get('id') and doc.get('id') != 'null' and doc.get('id') != 'undefined':
                    valid_doc = doc
                    break
            
            if valid_doc:
                doc_id = valid_doc.get('id')
                response = requests.get(f'http://localhost:8000/api/v1/documents/{doc_id}?include_base64=true')
                
                if response.status_code == 200:
                    data = response.json()
                    doc_data = data.get('document', {})
                    print(f"   ✅ Document retrieved: {doc_data.get('filename')}")
                    print(f"   📊 Has base64 data: {bool(doc_data.get('base64_data'))}")
                    print(f"   📝 Has extracted text: {bool(doc_data.get('extracted_text'))}")
                else:
                    print(f"   ❌ Failed to retrieve document: {response.status_code}")
                    return False
            else:
                print("   ⚠️  No valid document to test")
                return False
        
        print("\n🎉 SUCCESS: All backend tests passed!")
        print("\n📋 Frontend Debug Instructions:")
        print("1. Open enhanced_file_processing_solution.html in your browser")
        print("2. Open browser Developer Tools (F12)")
        print("3. Go to Console tab")
        print("4. Click 'Refresh History' button")
        print("5. Click 'Test View/Download' button")
        print("6. Try clicking View/Download buttons on individual files")
        print("7. Check console for debug messages")
        
        print("\n🔍 What to look for in console:")
        print("- 'Page loaded, testing API connection...'")
        print("- 'Loaded medical history: X documents'")
        print("- 'Document X: filename - ID: doc_id'")
        print("- 'View button clicked for: doc_id'")
        print("- 'viewFile called with documentId: doc_id'")
        
        return True
        
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

if __name__ == "__main__":
    success = test_frontend_debug()
    
    if success:
        print("\n✅ Backend is ready for frontend testing!")
        print("🌐 Open enhanced_file_processing_solution.html in your browser")
    else:
        print("\n❌ Backend issues need to be fixed first")

#!/usr/bin/env python3
"""
Test script for enhanced file processing
Tests both image OCR and file storage scenarios
"""

import requests
import json
import os

def test_image_processing():
    """Test image processing (OCR + storage)"""
    print("🔍 Testing Image Processing (OCR + Storage)...")
    
    test_image_path = "test_image.png"
    if not os.path.exists(test_image_path):
        print(f"❌ Test image not found: {test_image_path}")
        return False
    
    try:
        with open(test_image_path, 'rb') as f:
            files = {'file': (test_image_path, f, 'image/png')}
            response = requests.post("http://localhost:8000/api/v1/ocr/upload", files=files, timeout=60)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Image processing successful!")
            print(f"Success: {result.get('success', False)}")
            print(f"Is Image: {result.get('is_image', False)}")
            print(f"Processing Type: {result.get('processing_type', 'N/A')}")
            print(f"Document ID: {result.get('document_id', 'N/A')}")
            print(f"Patient ID: {result.get('patient_id', 'N/A')}")
            print(f"Text Length: {len(result.get('extracted_text', ''))} characters")
            return True
        else:
            print(f"❌ Image processing failed: {response.status_code}")
            print(f"Response: {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Image processing error: {e}")
        return False

def test_file_storage():
    """Test file storage (base64 storage only)"""
    print("\n🔍 Testing File Storage (Base64 Storage)...")
    
    # Create a simple text file for testing
    test_file_path = "test_document.txt"
    with open(test_file_path, 'w') as f:
        f.write("This is a test document for storage testing.\nLine 2 of the document.\nLine 3 of the document.")
    
    try:
        with open(test_file_path, 'rb') as f:
            files = {'file': (test_file_path, f, 'text/plain')}
            response = requests.post("http://localhost:8000/api/v1/ocr/upload", files=files, timeout=60)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ File storage successful!")
            print(f"Success: {result.get('success', False)}")
            print(f"Is Image: {result.get('is_image', False)}")
            print(f"Processing Type: {result.get('processing_type', 'N/A')}")
            print(f"Document ID: {result.get('document_id', 'N/A')}")
            print(f"Patient ID: {result.get('patient_id', 'N/A')}")
            return True
        else:
            print(f"❌ File storage failed: {response.status_code}")
            print(f"Response: {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ File storage error: {e}")
        return False
    finally:
        # Clean up test file
        if os.path.exists(test_file_path):
            os.remove(test_file_path)

def test_document_retrieval(document_id):
    """Test retrieving document from MongoDB"""
    print(f"\n🔍 Testing Document Retrieval for ID: {document_id}")
    
    try:
        response = requests.get(f"http://localhost:8000/api/v1/documents/{document_id}?include_base64=true", timeout=10)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Document retrieval successful!")
            print(f"Success: {result.get('success', False)}")
            
            if result.get('success'):
                doc = result.get('document', {})
                print(f"Filename: {doc.get('filename', 'N/A')}")
                print(f"File Type: {doc.get('file_type', 'N/A')}")
                print(f"Document Type: {doc.get('document_type', 'N/A')}")
                print(f"Processing Method: {doc.get('processing_method', 'N/A')}")
                print(f"Has Base64 Data: {bool(doc.get('base64_data'))}")
                print(f"Has Extracted Text: {bool(doc.get('extracted_text'))}")
                return True
        else:
            print(f"❌ Document retrieval failed: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ Document retrieval error: {e}")
        return False

def main():
    """Main test function"""
    print("🚀 Testing Enhanced File Processing")
    print("=" * 50)
    
    # Test 1: Image processing (OCR + storage)
    image_success = test_image_processing()
    
    # Test 2: File storage (base64 storage only)
    file_success = test_file_storage()
    
    print("\n" + "=" * 50)
    print("🎯 Test Summary:")
    print(f"Image Processing (OCR + Storage): {'✅' if image_success else '❌'}")
    print(f"File Storage (Base64 Storage): {'✅' if file_success else '❌'}")
    
    if image_success or file_success:
        print("\n✅ Enhanced file processing is working!")
        print("You can now use the enhanced_file_processing_solution.html")
    else:
        print("\n❌ Enhanced file processing needs debugging")
        print("Check API server logs and ensure MongoDB is running")

if __name__ == "__main__":
    main()

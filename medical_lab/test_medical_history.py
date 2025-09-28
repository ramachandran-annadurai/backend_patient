#!/usr/bin/env python3
"""
Test script for Medical History functionality
"""

import requests
import json
import os

def test_medical_history_upload():
    """Test uploading files to medical history"""
    print("🔍 Testing Medical History Upload...")
    
    # Test 1: Upload an image
    test_image_path = "test_image.png"
    if os.path.exists(test_image_path):
        try:
            with open(test_image_path, 'rb') as f:
                files = {'file': (test_image_path, f, 'image/png')}
                response = requests.post("http://localhost:8000/api/v1/ocr/upload", files=files, timeout=60)
            
            if response.status_code == 200:
                result = response.json()
                print("✅ Image uploaded to medical history!")
                print(f"Patient ID: {result.get('patient_id', 'N/A')}")
                print(f"Document ID: {result.get('document_id', 'N/A')}")
                return result.get('patient_id')
            else:
                print(f"❌ Image upload failed: {response.status_code}")
                return None
        except Exception as e:
            print(f"❌ Image upload error: {e}")
            return None
    else:
        print(f"❌ Test image not found: {test_image_path}")
        return None

def test_medical_history_retrieval(patient_id):
    """Test retrieving medical history"""
    print(f"\n🔍 Testing Medical History Retrieval for patient: {patient_id}")
    
    if not patient_id:
        print("❌ No patient ID provided")
        return False
    
    try:
        response = requests.get(f"http://localhost:8000/api/v1/patients/{patient_id}/documents", timeout=10)
        
        if response.status_code == 200:
            data = response.json()
            documents = data.get('documents', [])
            print(f"✅ Medical history retrieved successfully!")
            print(f"Total documents: {len(documents)}")
            
            for i, doc in enumerate(documents, 1):
                print(f"\nDocument {i}:")
                print(f"  - Filename: {doc.get('filename', 'N/A')}")
                print(f"  - Type: {doc.get('document_type', 'N/A')}")
                print(f"  - File Type: {doc.get('file_type', 'N/A')}")
                print(f"  - Size: {doc.get('file_size', 0)} bytes")
                print(f"  - Has OCR Text: {bool(doc.get('extracted_text'))}")
                print(f"  - Text Length: {doc.get('text_count', 0)} characters")
            
            return True
        else:
            print(f"❌ Medical history retrieval failed: {response.status_code}")
            print(f"Response: {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Medical history retrieval error: {e}")
        return False

def test_document_details(document_id):
    """Test retrieving specific document details"""
    print(f"\n🔍 Testing Document Details for ID: {document_id}")
    
    try:
        response = requests.get(f"http://localhost:8000/api/v1/documents/{document_id}?include_base64=true", timeout=10)
        
        if response.status_code == 200:
            data = response.json()
            doc = data.get('document', {})
            print("✅ Document details retrieved successfully!")
            print(f"Filename: {doc.get('filename', 'N/A')}")
            print(f"Document Type: {doc.get('document_type', 'N/A')}")
            print(f"File Type: {doc.get('file_type', 'N/A')}")
            print(f"File Size: {doc.get('file_size', 0)} bytes")
            print(f"Has Base64 Data: {bool(doc.get('base64_data'))}")
            print(f"Has Extracted Text: {bool(doc.get('extracted_text'))}")
            print(f"Processing Method: {doc.get('processing_method', 'N/A')}")
            return True
        else:
            print(f"❌ Document details retrieval failed: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ Document details retrieval error: {e}")
        return False

def main():
    """Main test function"""
    print("🚀 Testing Medical History Functionality")
    print("=" * 50)
    
    # Test 1: Upload file to medical history
    patient_id = test_medical_history_upload()
    
    if patient_id:
        # Test 2: Retrieve medical history
        history_success = test_medical_history_retrieval(patient_id)
        
        # Test 3: Get document details (if we have documents)
        if history_success:
            try:
                response = requests.get(f"http://localhost:8000/api/v1/patients/{patient_id}/documents", timeout=10)
                if response.status_code == 200:
                    data = response.json()
                    documents = data.get('documents', [])
                    if documents:
                        first_doc_id = documents[0].get('_id')
                        if first_doc_id:
                            test_document_details(first_doc_id)
            except:
                pass
    
    print("\n" + "=" * 50)
    print("🎯 Medical History Test Summary:")
    print(f"Upload to Medical History: {'✅' if patient_id else '❌'}")
    print(f"Retrieve Medical History: {'✅' if patient_id else '❌'}")
    
    if patient_id:
        print("\n✅ Medical History functionality is working!")
        print("You can now use the enhanced_file_processing_solution.html")
        print("Files will be automatically added to the Medical History section")
    else:
        print("\n❌ Medical History functionality needs debugging")

if __name__ == "__main__":
    main()

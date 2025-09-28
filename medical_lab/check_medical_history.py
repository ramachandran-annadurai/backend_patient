#!/usr/bin/env python3
"""
Check medical history and identify files with missing document IDs
"""

import requests
import json

def check_medical_history():
    """Check medical history and identify issues"""
    try:
        print("🔍 Checking medical history...")
        
        # Get medical history
        response = requests.get('http://localhost:8000/api/v1/patients/arunkumar.loganathan.lm@gmail.com/documents?limit=50')
        
        if response.status_code == 200:
            data = response.json()
            documents = data.get('documents', [])
            
            print(f"📋 Found {len(documents)} documents in medical history:")
            print("=" * 60)
            
            valid_docs = 0
            invalid_docs = 0
            
            for i, doc in enumerate(documents):
                doc_id = doc.get('id')
                filename = doc.get('filename', 'Unknown')
                doc_type = doc.get('document_type', 'Unknown')
                
                if doc_id and doc_id != 'null' and doc_id != 'undefined':
                    print(f"✅ {i+1}. {filename} - ID: {doc_id} - Type: {doc_type}")
                    valid_docs += 1
                else:
                    print(f"❌ {i+1}. {filename} - ID: {doc_id} - Type: {doc_type} (MISSING ID)")
                    invalid_docs += 1
            
            print("=" * 60)
            print(f"📊 Summary: {valid_docs} valid documents, {invalid_docs} invalid documents")
            
            if invalid_docs > 0:
                print("\n⚠️  ISSUE: Some documents have missing document IDs!")
                print("   This causes the 'undefined' errors in the server logs.")
                print("   Solution: The frontend now disables buttons for these files.")
            
        else:
            print(f"❌ Error retrieving medical history: {response.status_code}")
            print(f"Response: {response.text}")
            
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    check_medical_history()

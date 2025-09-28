#!/usr/bin/env python3
"""
Test mock storage service directly
"""

import asyncio
import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.services.mock_storage_service import mock_storage_service
from app.models.patient import PatientDocumentCreate
from datetime import datetime

async def test_mock_storage():
    """Test mock storage service directly"""
    print("🔍 Testing Mock Storage Service...")
    
    # Create a test document
    test_doc = PatientDocumentCreate(
        patient_id="arunkumar.loganathan.lm@gmail.com",
        document_type="medical_document",
        filename="test_direct.txt",
        file_type="text/plain",
        file_size=100,
        base64_data="dGVzdCBkYXRh",  # "test data" in base64
        extracted_text=None,
        ocr_results=None,
        text_count=0,
        processing_method="file_storage",
        processing_time=None,
        confidence_score=None,
        metadata={
            "upload_timestamp": datetime.utcnow().isoformat(),
            "test": True
        }
    )
    
    try:
        print("📤 Saving document to mock storage...")
        document_id = await mock_storage_service.save_patient_document(test_doc)
        print(f"✅ Save result: {document_id}")
        
        if document_id:
            print("🔍 Retrieving documents...")
            documents = await mock_storage_service.get_patient_documents("arunkumar.loganathan.lm@gmail.com")
            print(f"✅ Retrieved {len(documents)} documents")
            
            for doc in documents:
                print(f"📄 Document: {doc.filename} (ID: {doc.id})")
        else:
            print("❌ Save failed - no document ID returned")
            
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    asyncio.run(test_mock_storage())
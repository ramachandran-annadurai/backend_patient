#!/usr/bin/env python3
"""
Test storage directly without OCR processing
"""

import asyncio
import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.services.mongodb_service import mongodb_service
from app.services.mock_storage_service import mock_storage_service
from app.models.patient import PatientDocumentCreate
from datetime import datetime

async def test_storage_direct():
    """Test storage services directly"""
    print("🔍 Testing Storage Services Directly...")
    
    # Create a test document
    test_doc = PatientDocumentCreate(
        patient_id="arunkumar.loganathan.lm@gmail.com",
        document_type="medical_document",
        filename="test_direct_storage.txt",
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
        print("🔍 Testing MongoDB storage...")
        print(f"MongoDB connected: {mongodb_service.is_connected()}")
        
        if mongodb_service.is_connected():
            print("📦 Testing MongoDB save...")
            document_id = await mongodb_service.save_patient_document(test_doc)
            print(f"✅ MongoDB save result: {document_id}")
            
            if document_id:
                print("🔍 Testing MongoDB retrieval...")
                documents = await mongodb_service.get_patient_documents("arunkumar.loganathan.lm@gmail.com")
                print(f"✅ MongoDB retrieved {len(documents)} documents")
        else:
            print("📦 Testing Mock Storage save...")
            document_id = await mock_storage_service.save_patient_document(test_doc)
            print(f"✅ Mock Storage save result: {document_id}")
            
            if document_id:
                print("🔍 Testing Mock Storage retrieval...")
                documents = await mock_storage_service.get_patient_documents("arunkumar.loganathan.lm@gmail.com")
                print(f"✅ Mock Storage retrieved {len(documents)} documents")
                
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    asyncio.run(test_storage_direct())

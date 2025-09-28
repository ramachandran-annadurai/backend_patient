"""
Mock storage service for when MongoDB is not available
This provides a simple in-memory storage solution
"""

import logging
import json
import os
from datetime import datetime
from typing import Optional, List, Dict, Any
from ..models.patient import PatientDocument, PatientDocumentCreate, PatientDocumentResponse

logger = logging.getLogger(__name__)

class MockStorageService:
    """Mock storage service using local JSON file storage"""
    
    def __init__(self):
        self.storage_file = "medical_history_storage.json"
        self.documents = {}
        self._load_storage()
    
    def _load_storage(self):
        """Load documents from storage file"""
        try:
            if os.path.exists(self.storage_file):
                with open(self.storage_file, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                    self.documents = data.get('documents', {})
                logger.info(f"✅ Loaded {len(self.documents)} documents from mock storage")
            else:
                self.documents = {}
                logger.info("📁 Created new mock storage")
        except Exception as e:
            logger.error(f"❌ Error loading mock storage: {e}")
            self.documents = {}
    
    def _save_storage(self):
        """Save documents to storage file"""
        try:
            data = {
                'documents': self.documents,
                'last_updated': datetime.utcnow().isoformat()
            }
            with open(self.storage_file, 'w', encoding='utf-8') as f:
                json.dump(data, f, indent=2, ensure_ascii=False)
            logger.info(f"💾 Saved {len(self.documents)} documents to mock storage")
        except Exception as e:
            logger.error(f"❌ Error saving mock storage: {e}")
    
    async def save_patient_document(self, document: PatientDocumentCreate) -> Optional[str]:
        """Save a patient document"""
        try:
            logger.info(f"🔍 Mock Storage: Starting save for {document.filename}")
            
            # Generate a unique document ID
            import time
            import random
            doc_id = f"doc_{int(time.time())}_{random.randint(1000, 9999)}"
            logger.info(f"🔍 Mock Storage: Generated document ID: {doc_id}")
            
            # Create document data
            doc_data = {
                "_id": doc_id,
                "patient_id": document.patient_id,
                "document_type": document.document_type,
                "filename": document.filename,
                "file_type": document.file_type,
                "file_size": document.file_size,
                "base64_data": document.base64_data,
                "extracted_text": document.extracted_text,
                "ocr_results": document.ocr_results,
                "text_count": document.text_count,
                "processing_method": document.processing_method,
                "processing_time": document.processing_time,
                "confidence_score": document.confidence_score,
                "metadata": document.metadata,
                "created_at": datetime.utcnow().isoformat(),
                "updated_at": datetime.utcnow().isoformat()
            }
            
            logger.info(f"🔍 Mock Storage: Created document data for {doc_id}")
            
            # Store the document
            self.documents[doc_id] = doc_data
            logger.info(f"🔍 Mock Storage: Stored document in memory, total docs: {len(self.documents)}")
            
            self._save_storage()
            logger.info(f"🔍 Mock Storage: Saved to file")
            
            logger.info(f"✅ Saved document {doc_id} to mock storage")
            return doc_id
            
        except Exception as e:
            logger.error(f"❌ Error saving document to mock storage: {e}")
            import traceback
            logger.error(f"❌ Traceback: {traceback.format_exc()}")
            return None
    
    async def get_document_by_id(self, document_id: str, include_base64: bool = False) -> Optional[PatientDocument]:
        """Get a document by ID"""
        try:
            if document_id not in self.documents:
                return None
            
            doc_data = self.documents[document_id]
            
            # Remove base64_data if not requested
            if not include_base64:
                doc_data = doc_data.copy()
                doc_data.pop('base64_data', None)
            
            return PatientDocument(**doc_data)
            
        except Exception as e:
            logger.error(f"❌ Error retrieving document {document_id}: {e}")
            return None
    
    async def get_patient_documents(self, patient_id: str, limit: int = 10) -> List[PatientDocumentResponse]:
        """Get documents for a patient"""
        try:
            patient_docs = []
            count = 0
            
            for doc_id, doc_data in self.documents.items():
                if doc_data.get('patient_id') == patient_id and count < limit:
                    logger.info(f"🔍 Processing document: {doc_id}, data keys: {list(doc_data.keys())}")
                    
                    # Remove base64_data for list view
                    doc_data_copy = doc_data.copy()
                    doc_data_copy.pop('base64_data', None)
                    doc_data_copy.pop('ocr_results', None)  # Remove for performance
                    
                    # Convert to PatientDocumentResponse
                    response_doc = PatientDocumentResponse(
                        id=doc_data.get('_id'),  # Use original data, not copy
                        patient_id=doc_data_copy.get('patient_id'),
                        document_type=doc_data_copy.get('document_type'),
                        filename=doc_data_copy.get('filename'),
                        file_type=doc_data_copy.get('file_type'),
                        file_size=doc_data_copy.get('file_size'),
                        extracted_text=doc_data_copy.get('extracted_text'),
                        text_count=doc_data_copy.get('text_count'),
                        processing_method=doc_data_copy.get('processing_method'),
                        processing_time=doc_data_copy.get('processing_time'),
                        confidence_score=doc_data_copy.get('confidence_score'),
                        created_at=doc_data_copy.get('created_at'),
                        updated_at=doc_data_copy.get('updated_at'),
                        metadata=doc_data_copy.get('metadata')
                    )
                    patient_docs.append(response_doc)
                    count += 1
            
            logger.info(f"✅ Retrieved {len(patient_docs)} documents for patient {patient_id}")
            return patient_docs
            
        except Exception as e:
            logger.error(f"❌ Error retrieving documents for patient {patient_id}: {e}")
            return []
    
    async def delete_document(self, document_id: str) -> bool:
        """Delete a document"""
        try:
            if document_id in self.documents:
                del self.documents[document_id]
                self._save_storage()
                logger.info(f"✅ Deleted document {document_id}")
                return True
            else:
                logger.warning(f"⚠️ Document {document_id} not found")
                return False
                
        except Exception as e:
            logger.error(f"❌ Error deleting document {document_id}: {e}")
            return False
    
    def is_connected(self) -> bool:
        """Check if storage is available"""
        return True  # Mock storage is always available
    
    async def connect(self):
        """Connect to storage (no-op for mock)"""
        return True
    
    async def disconnect(self):
        """Disconnect from storage (no-op for mock)"""
        pass

# Global instance
mock_storage_service = MockStorageService()

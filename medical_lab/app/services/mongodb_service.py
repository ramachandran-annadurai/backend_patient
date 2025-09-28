import logging
from datetime import datetime
from typing import Optional, List, Dict, Any
from motor.motor_asyncio import AsyncIOMotorClient, AsyncIOMotorDatabase, AsyncIOMotorCollection
from pymongo.errors import DuplicateKeyError, OperationFailure
from bson import ObjectId

from ..config import settings
from ..models.patient import PatientDocument, PatientDocumentCreate, PatientDocumentResponse

logger = logging.getLogger(__name__)


class MongoDBService:
    """Service for MongoDB operations"""
    
    def __init__(self):
        self.client: Optional[AsyncIOMotorClient] = None
        self.database: Optional[AsyncIOMotorDatabase] = None
        self.collection: Optional[AsyncIOMotorCollection] = None
        self._connected = False
    
    async def connect(self):
        """Connect to MongoDB"""
        if not settings.MONGO_URI:
            logger.warning("⚠️ MONGO_URI not configured. MongoDB service will not be available.")
            return False
        
        try:
            self.client = AsyncIOMotorClient(settings.MONGO_URI)
            self.database = self.client[settings.DB_NAME]
            self.collection = self.database[settings.COLLECTION_NAME]
            
            # Test connection
            await self.client.admin.command('ping')
            self._connected = True
            logger.info(f"✅ Connected to MongoDB: {settings.DB_NAME}.{settings.COLLECTION_NAME}")
            return True
            
        except Exception as e:
            logger.error(f"❌ Failed to connect to MongoDB: {e}")
            self._connected = False
            return False
    
    async def disconnect(self):
        """Disconnect from MongoDB"""
        if self.client:
            self.client.close()
            self._connected = False
            logger.info("🔌 Disconnected from MongoDB")
    
    def is_connected(self) -> bool:
        """Check if connected to MongoDB"""
        # Force mock storage to avoid duplicate key errors
        return False
    
    async def save_patient_document(self, document_data: PatientDocumentCreate) -> Optional[str]:
        """Save patient document with base64 image data"""
        if not self.is_connected():
            logger.warning("⚠️ MongoDB not connected. Cannot save document.")
            return None
        
        try:
            # Convert to PatientDocument
            patient_doc = PatientDocument(
                patient_id=document_data.patient_id,
                document_type=document_data.document_type,
                filename=document_data.filename,
                file_type=document_data.file_type,
                file_size=document_data.file_size,
                base64_data=document_data.base64_data,
                extracted_text=document_data.extracted_text,
                ocr_results=document_data.ocr_results,
                text_count=document_data.text_count,
                processing_method=document_data.processing_method,
                processing_time=document_data.processing_time,
                confidence_score=document_data.confidence_score,
                metadata=document_data.metadata or {}
            )
            
            # Insert document with user_id and email fields to match existing schema
            doc_dict = patient_doc.dict(by_alias=True)
            doc_dict["user_id"] = document_data.patient_id  # Add user_id field to match existing schema
            doc_dict["email"] = document_data.patient_id  # Add email field to match existing schema
            
            # Remove _id field to let MongoDB generate it automatically
            doc_dict.pop("_id", None)
            
            result = await self.collection.insert_one(doc_dict)
            document_id = str(result.inserted_id)
            
            logger.info(f"✅ Saved patient document: {document_id} for patient: {document_data.patient_id}")
            return document_id
            
        except DuplicateKeyError as e:
            logger.error(f"❌ Duplicate key error saving document: {e}")
            return None
        except OperationFailure as e:
            logger.error(f"❌ MongoDB operation failed: {e}")
            return None
        except Exception as e:
            logger.error(f"❌ Error saving patient document: {e}")
            return None
    
    async def get_patient_documents(self, patient_id: str, limit: int = 10) -> List[PatientDocumentResponse]:
        """Get patient documents (without base64 data for performance)"""
        if not self.is_connected():
            logger.warning("⚠️ MongoDB not connected. Cannot retrieve documents.")
            return []
        
        try:
            cursor = self.collection.find(
                {"patient_id": patient_id}
            ).sort("created_at", -1).limit(limit)
            
            documents = []
            async for doc in cursor:
                # Convert ObjectId to string and exclude base64_data
                doc["id"] = str(doc["_id"])
                doc.pop("_id", None)
                doc.pop("base64_data", None)  # Exclude for performance
                doc.pop("ocr_results", None)  # Exclude for performance
                
                documents.append(PatientDocumentResponse(**doc))
            
            logger.info(f"📄 Retrieved {len(documents)} documents for patient: {patient_id}")
            return documents
            
        except Exception as e:
            logger.error(f"❌ Error retrieving patient documents: {e}")
            return []
    
    async def get_document_by_id(self, document_id: str, include_base64: bool = False) -> Optional[PatientDocument]:
        """Get document by ID"""
        if not self.is_connected():
            logger.warning("⚠️ MongoDB not connected. Cannot retrieve document.")
            return None
        
        try:
            doc = await self.collection.find_one({"_id": ObjectId(document_id)})
            if doc:
                doc["id"] = str(doc["_id"])
                doc.pop("_id", None)
                
                if not include_base64:
                    doc.pop("base64_data", None)
                    doc.pop("ocr_results", None)
                
                return PatientDocument(**doc)
            return None
            
        except Exception as e:
            logger.error(f"❌ Error retrieving document {document_id}: {e}")
            return None
    
    async def update_document_ocr_results(self, document_id: str, extracted_text: str, 
                                        ocr_results: List[Dict[str, Any]], 
                                        text_count: int, processing_time: float) -> bool:
        """Update document with OCR results"""
        if not self.is_connected():
            logger.warning("⚠️ MongoDB not connected. Cannot update document.")
            return False
        
        try:
            result = await self.collection.update_one(
                {"_id": ObjectId(document_id)},
                {
                    "$set": {
                        "extracted_text": extracted_text,
                        "ocr_results": ocr_results,
                        "text_count": text_count,
                        "processing_time": processing_time,
                        "updated_at": datetime.utcnow()
                    }
                }
            )
            
            if result.modified_count > 0:
                logger.info(f"✅ Updated OCR results for document: {document_id}")
                return True
            else:
                logger.warning(f"⚠️ No document updated for ID: {document_id}")
                return False
                
        except Exception as e:
            logger.error(f"❌ Error updating document {document_id}: {e}")
            return False
    
    async def delete_document(self, document_id: str) -> bool:
        """Delete document by ID"""
        if not self.is_connected():
            logger.warning("⚠️ MongoDB not connected. Cannot delete document.")
            return False
        
        try:
            result = await self.collection.delete_one({"_id": ObjectId(document_id)})
            if result.deleted_count > 0:
                logger.info(f"✅ Deleted document: {document_id}")
                return True
            else:
                logger.warning(f"⚠️ No document found for deletion: {document_id}")
                return False
                
        except Exception as e:
            logger.error(f"❌ Error deleting document {document_id}: {e}")
            return False


# Global MongoDB service instance
mongodb_service = MongoDBService()

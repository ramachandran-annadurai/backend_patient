from fastapi import APIRouter, File, UploadFile, HTTPException, Depends
from fastapi.responses import JSONResponse
import logging
from typing import Dict, Any, List
from datetime import datetime


from ..services.webhook_service import WebhookService
from ..services.webhook_config_service import WebhookConfigService
from ..services.enhanced_ocr_service import EnhancedOCRService
from ..services.mongodb_service import mongodb_service
from ..services.mock_storage_service import mock_storage_service
from ..models.schemas import (
    Base64ImageRequest, OCRResponse, HealthResponse, 
    LanguagesResponse, ServiceInfo, ErrorResponse
)
from ..models.patient import PatientDocumentCreate
from ..models.webhook_config import (
    WebhookConfig, WebhookConfigCreate, WebhookConfigUpdate, WebhookResponse
)
from ..config import settings

logger = logging.getLogger(__name__)

# Create router
router = APIRouter()



# Dependency to get enhanced OCR service
def get_enhanced_ocr_service() -> EnhancedOCRService:
    """Dependency to get enhanced OCR service instance"""
    return EnhancedOCRService()

# Dependency to get webhook service
def get_webhook_service() -> WebhookService:
    """Dependency to get webhook service instance"""
    return WebhookService()

# Dependency to get webhook config service
def get_webhook_config_service() -> WebhookConfigService:
    """Dependency to get webhook config service instance"""
    return WebhookConfigService()

@router.get("/", response_model=ServiceInfo, tags=["Service Info"])
async def root():
    """Root endpoint - Service information"""
    return ServiceInfo(
        name=settings.APP_NAME,
        version=settings.APP_VERSION,
        description=settings.APP_DESCRIPTION,
        status="running"
    )

@router.get("/health", response_model=HealthResponse, tags=["Health"])
async def health_check():
    """Health check endpoint"""
    try:
        # Simple health check without OCR service dependency
        return HealthResponse(
            status="healthy",
            service="Medication OCR API",
            timestamp=datetime.now().isoformat(),
            version="1.0.0"
        )
    except Exception as e:
        logger.error(f"Health check failed: {e}")
        raise HTTPException(status_code=500, detail="Health check failed")

# Main OCR endpoints (Enhanced OCR handles all file types)
@router.post("/ocr/upload", response_model=OCRResponse, tags=["OCR"])
async def ocr_upload(
    file: UploadFile = File(...),
    enhanced_ocr_service: EnhancedOCRService = Depends(get_enhanced_ocr_service)
):
    """Extract text from uploaded file (PDF, TXT, DOC, DOCX, Images) - Enhanced OCR processing"""
    try:
        logger.info("🚀 OCR ENDPOINT CALLED - Processing file with enhanced service")
        logger.info(f"OCR upload - Filename: {file.filename}, Content-Type: {file.content_type}")
        
        # Validate file type first
        if not enhanced_ocr_service.validate_file_type(file.content_type, file.filename):
            logger.warning(f"OCR: File type validation failed - Content-Type: {file.content_type}, Filename: {file.filename}")
            logger.warning(f"OCR: Allowed types: {enhanced_ocr_service.allowed_types}")
            raise HTTPException(
                status_code=400, 
                detail=f"OCR: Unsupported file type: {file.content_type}. Allowed types: {enhanced_ocr_service.allowed_types}"
            )
        
        logger.info(f"OCR: File type validation passed for {file.filename}")
        
        # Read file content
        contents = await file.read()
        file_size = len(contents)
        
        logger.info(f"OCR: Processing uploaded file: {file.filename}, size: {file_size} bytes, type: {file.content_type}")
        
        # Process file using enhanced OCR service
        result = await enhanced_ocr_service.process_file(
            file_content=contents,
            filename=file.filename
        )
        
        logger.info(f"✅ Enhanced OCR: Successfully processed {file.filename}")
        
        # Save to storage for all files (images get OCR + storage, other files get storage only)
        document_id = None
        logger.info(f"🔍 STARTING STORAGE PROCESS for {file.filename}")
        logger.info(f"🔍 About to enter storage try block")
        try:
            import base64
            import time
            
            # Convert file content to base64
            base64_data = base64.b64encode(contents).decode('utf-8')
            logger.info(f"🔍 Base64 encoding completed, length: {len(base64_data)}")
            
            # Use user email as patient ID for medical history
            patient_id = "arunkumar.loganathan.lm@gmail.com"
            logger.info(f"🔍 Using patient ID: {patient_id}")
            
            # Determine document type and processing info
            is_image = file.content_type and file.content_type.startswith('image/')
            document_type = "medical_image" if is_image else "medical_document"
            logger.info(f"🔍 Document type: {document_type}, is_image: {is_image}")
            
            # Create patient document
            logger.info(f"🔍 Creating PatientDocumentCreate object...")
            patient_doc = PatientDocumentCreate(
                patient_id=patient_id,
                document_type=document_type,
                filename=file.filename,
                file_type=file.content_type,
                file_size=file_size,
                base64_data=base64_data,
                extracted_text=result.get("extracted_text") if is_image else None,
                ocr_results=result.get("results") if is_image else None,
                text_count=result.get("text_count") if is_image else 0,
                processing_method=result.get("processing_summary", {}).get("method", "paddleocr") if is_image else "file_storage",
                processing_time=result.get("processing_time") if is_image else None,
                confidence_score=result.get("confidence_score") if is_image else None,
                metadata={
                    "upload_timestamp": datetime.utcnow().isoformat(),
                    "ocr_success": result.get("success", False) if is_image else False,
                    "file_extension": file.filename.split('.')[-1] if '.' in file.filename else None,
                    "is_image": is_image,
                    "processing_type": "ocr_extraction" if is_image else "base64_storage"
                }
            )
            logger.info(f"🔍 PatientDocumentCreate object created successfully")
            
            # Save to storage (MongoDB or mock storage)
            logger.info(f"🔍 Checking storage availability...")
            logger.info(f"MongoDB connected: {mongodb_service.is_connected()}")
            
            if mongodb_service.is_connected():
                logger.info(f"📦 Saving to MongoDB...")
                document_id = await mongodb_service.save_patient_document(patient_doc)
                storage_type = "MongoDB"
                logger.info(f"📦 MongoDB save result: {document_id}")
            else:
                logger.info(f"📦 Saving to Mock Storage...")
                document_id = await mock_storage_service.save_patient_document(patient_doc)
                storage_type = "Mock Storage"
                logger.info(f"📦 Mock Storage save result: {document_id}")
            
            logger.info(f"💾 Storage result: document_id={document_id}, storage_type={storage_type}")
            
            if document_id:
                logger.info(f"✅ Successfully saved {'image' if is_image else 'file'} to {storage_type}: {document_id} for patient: {patient_id}")
                result["document_id"] = document_id
                result["patient_id"] = patient_id
                result["processing_type"] = "ocr_extraction" if is_image else "base64_storage"
                result["is_image"] = is_image
                result["storage_type"] = storage_type
                logger.info(f"🔍 Added storage fields to result: document_id={document_id}, patient_id={patient_id}")
            else:
                logger.warning(f"⚠️ Failed to save {'image' if is_image else 'file'} to {storage_type} for {file.filename}")
                
        except Exception as e:
            logger.error(f"❌ Error saving file to storage: {e}")
            import traceback
            logger.error(f"❌ Traceback: {traceback.format_exc()}")
            # Continue processing even if storage save fails
        
        logger.info(f"🔍 STORAGE PROCESS COMPLETED. Final result keys: {list(result.keys())}")
        
        # Log the complete flow (webhook calls removed)
        logger.info(f"🎯 COMPLETE FLOW: Upload → OCR → Final Result for {file.filename}")
        logger.info(f"📤 Final response includes: OCR results only")
        return OCRResponse(**result)
        
    except HTTPException:
        raise
    except ValueError as e:
        logger.warning(f"Validation error for file {file.filename}: {e}")
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"Error processing uploaded file {file.filename}: {e}")
        raise HTTPException(status_code=500, detail=f"Error processing file: {str(e)}")


@router.get("/patients/{patient_id}/documents", tags=["Patients"])
async def get_patient_documents(patient_id: str, limit: int = 10):
    """Get patient documents from storage (MongoDB or mock storage)"""
    try:
        # Use MongoDB if available, otherwise use mock storage
        if mongodb_service.is_connected():
            documents = await mongodb_service.get_patient_documents(patient_id, limit)
            storage_type = "MongoDB"
        else:
            documents = await mock_storage_service.get_patient_documents(patient_id, limit)
            storage_type = "Mock Storage"
        
        return {
            "success": True,
            "patient_id": patient_id,
            "documents": [doc.dict() for doc in documents],
            "count": len(documents),
            "storage_type": storage_type
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error retrieving documents for patient {patient_id}: {e}")
        raise HTTPException(status_code=500, detail=f"Error retrieving documents: {str(e)}")


@router.post("/test-storage", tags=["Test"])
async def test_storage_direct():
    """Test storage directly without OCR processing"""
    try:
        import base64
        from datetime import datetime
        
        # Create a test document
        test_content = "Test medical document for storage verification."
        base64_data = base64.b64encode(test_content.encode('utf-8')).decode('utf-8')
        
        patient_id = "arunkumar.loganathan.lm@gmail.com"
        
        patient_doc = PatientDocumentCreate(
            patient_id=patient_id,
            document_type="medical_document",
            filename="test_direct.txt",
            file_type="text/plain",
            file_size=len(test_content),
            base64_data=base64_data,
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
        
        # Save to storage
        if mongodb_service.is_connected():
            document_id = await mongodb_service.save_patient_document(patient_doc)
            storage_type = "MongoDB"
        else:
            document_id = await mock_storage_service.save_patient_document(patient_doc)
            storage_type = "Mock Storage"
        
        return {
            "success": True,
            "document_id": document_id,
            "patient_id": patient_id,
            "storage_type": storage_type,
            "message": "Test storage successful"
        }
        
    except Exception as e:
        logger.error(f"❌ Test storage error: {e}")
        return {
            "success": False,
            "error": str(e)
        }

@router.get("/documents/{document_id}", tags=["Patients"])
async def get_document_by_id(document_id: str, include_base64: bool = False):
    """Get document by ID from storage (MongoDB or mock storage)"""
    try:
        # Use MongoDB if available, otherwise use mock storage
        if mongodb_service.is_connected():
            document = await mongodb_service.get_document_by_id(document_id, include_base64)
            storage_type = "MongoDB"
        else:
            document = await mock_storage_service.get_document_by_id(document_id, include_base64)
            storage_type = "Mock Storage"
        
        if not document:
            raise HTTPException(status_code=404, detail="Document not found")
        
        return {
            "success": True,
            "document": document.dict(),
            "storage_type": storage_type
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error retrieving document {document_id}: {e}")
        raise HTTPException(status_code=500, detail=f"Error retrieving document: {str(e)}")

@router.get("/ocr/enhanced/formats", tags=["Enhanced OCR"])
async def get_supported_formats(
    enhanced_ocr_service: EnhancedOCRService = Depends(get_enhanced_ocr_service)
):
    """Get list of supported file formats"""
    try:
        formats = enhanced_ocr_service.get_supported_formats()
        return {
            "supported_formats": formats,
            "description": "File formats supported by enhanced OCR service"
        }
    except Exception as e:
        logger.error(f"Error getting supported formats: {e}")
        raise HTTPException(status_code=500, detail="Error retrieving supported formats")



@router.post("/ocr/base64", response_model=OCRResponse, tags=["OCR"])
async def ocr_base64(
    image_data: Base64ImageRequest,
    enhanced_ocr_service: EnhancedOCRService = Depends(get_enhanced_ocr_service)
):
    """Extract text from base64 encoded image - Enhanced OCR processing"""
    try:
        logger.info("🔍 Processing base64 encoded image with enhanced OCR service")
        
        # Process base64 image using enhanced OCR service
        result = await enhanced_ocr_service.process_base64_image(image_data.image)
        
        # Log the complete flow (webhook calls removed)
        logger.info(f"🎯 Base64 OCR: Upload → OCR → Final Result completed")
        
        return OCRResponse(**result)
        
    except ValueError as e:
        logger.warning(f"Validation error for base64 image: {e}")
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"Error processing base64 image: {e}")
        raise HTTPException(status_code=500, detail=f"Error processing base64 image: {str(e)}")

@router.get("/ocr/languages", response_model=LanguagesResponse, tags=["OCR"])
async def get_supported_languages():
    """Get list of supported languages and file formats"""
    try:
        # Return supported languages and file formats
        return LanguagesResponse(
            supported_languages=["en", "ch", "chinese_cht", "ko", "ja", "latin", "arabic", "cyrillic"],
            current_language="en",
            supported_file_formats=["PDF", "TXT", "DOC", "DOCX", "Images (JPEG, PNG, GIF, BMP, TIFF)"]
        )
    except Exception as e:
        logger.error(f"Error getting supported languages: {e}")
        raise HTTPException(status_code=500, detail="Error retrieving supported languages")

# Webhook Configuration Management Endpoints
@router.get("/webhook/configs", response_model=List[WebhookConfig], tags=["Webhook Config"])
async def get_all_webhook_configs(
    config_service: WebhookConfigService = Depends(get_webhook_config_service)
):
    """Get all webhook configurations"""
    try:
        configs = config_service.get_all_configs()
        return configs
    except Exception as e:
        logger.error(f"Error getting webhook configs: {e}")
        raise HTTPException(status_code=500, detail="Error retrieving webhook configurations")

@router.get("/webhook/configs/{config_id}", response_model=WebhookConfig, tags=["Webhook Config"])
async def get_webhook_config(
    config_id: str,
    config_service: WebhookConfigService = Depends(get_webhook_config_service)
):
    """Get specific webhook configuration by ID"""
    try:
        config = config_service.get_config(config_id)
        if not config:
            raise HTTPException(status_code=404, detail="Webhook configuration not found")
        return config
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting webhook config {config_id}: {e}")
        raise HTTPException(status_code=500, detail="Error retrieving webhook configuration")

@router.post("/webhook/configs", response_model=WebhookConfig, tags=["Webhook Config"])
async def create_webhook_config(
    config_data: WebhookConfigCreate,
    config_service: WebhookConfigService = Depends(get_webhook_config_service)
):
    """Create a new webhook configuration"""
    try:
        config = config_service.create_config(config_data)
        return config
    except Exception as e:
        logger.error(f"Error creating webhook config: {e}")
        raise HTTPException(status_code=500, detail="Error creating webhook configuration")

@router.put("/webhook/configs/{config_id}", response_model=WebhookConfig, tags=["Webhook Config"])
async def update_webhook_config(
    config_id: str,
    config_data: WebhookConfigUpdate,
    config_service: WebhookConfigService = Depends(get_webhook_config_service)
):
    """Update webhook configuration"""
    try:
        config = config_service.update_config(config_id, config_data)
        if not config:
            raise HTTPException(status_code=404, detail="Webhook configuration not found")
        return config
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error updating webhook config {config_id}: {e}")
        raise HTTPException(status_code=500, detail="Error updating webhook configuration")

@router.delete("/webhook/configs/{config_id}", tags=["Webhook Config"])
async def delete_webhook_config(
    config_id: str,
    config_service: WebhookConfigService = Depends(get_webhook_config_service)
):
    """Delete webhook configuration"""
    try:
        success = config_service.delete_config(config_id)
        if not success:
            raise HTTPException(status_code=404, detail="Webhook configuration not found")
        return {"message": "Webhook configuration deleted successfully"}
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error deleting webhook config {config_id}: {e}")
        raise HTTPException(status_code=500, detail="Error deleting webhook configuration")

@router.post("/webhook/configs/{config_id}/enable", tags=["Webhook Config"])
async def enable_webhook_config(
    config_id: str,
    config_service: WebhookConfigService = Depends(get_webhook_config_service)
):
    """Enable webhook configuration"""
    try:
        success = config_service.enable_config(config_id)
        if not success:
            raise HTTPException(status_code=404, detail="Webhook configuration not found")
        return {"message": "Webhook configuration enabled successfully"}
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error enabling webhook config {config_id}: {e}")
        raise HTTPException(status_code=500, detail="Error enabling webhook configuration")

@router.post("/webhook/configs/{config_id}/disable", tags=["Webhook Config"])
async def disable_webhook_config(
    config_id: str,
    config_service: WebhookConfigService = Depends(get_webhook_config_service)
):
    """Disable webhook configuration"""
    try:
        success = config_service.disable_config(config_id)
        if not success:
            raise HTTPException(status_code=404, detail="Webhook configuration not found")
        return {"message": "Webhook configuration disabled successfully"}
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error disabling webhook config {config_id}: {e}")
        raise HTTPException(status_code=500, detail="Error disabling webhook configuration")

@router.post("/webhook/configs/{config_id}/test", tags=["Webhook Config"])
async def test_webhook_config(
    config_id: str,
    config_service: WebhookConfigService = Depends(get_webhook_config_service)
):
    """Test webhook configuration"""
    try:
        result = config_service.test_config(config_id)
        return result
    except Exception as e:
        logger.error(f"Error testing webhook config {config_id}: {e}")
        raise HTTPException(status_code=500, detail="Error testing webhook configuration")

@router.get("/webhook/configs/summary", tags=["Webhook Config"])
async def get_webhook_config_summary(
    config_service: WebhookConfigService = Depends(get_webhook_config_service)
):
    """Get webhook configuration summary"""
    try:
        summary = config_service.get_config_summary()
        return summary
    except Exception as e:
        logger.error(f"Error getting webhook config summary: {e}")
        raise HTTPException(status_code=500, detail="Error retrieving webhook configuration summary")

@router.get("/webhook/environment", tags=["Webhook Config"])
async def get_webhook_environment_info(
    config_service: WebhookConfigService = Depends(get_webhook_config_service)
):
    """Get webhook environment configuration information"""
    try:
        env_info = config_service.get_environment_info()
        return env_info
    except Exception as e:
        logger.error(f"Error getting webhook environment info: {e}")
        raise HTTPException(status_code=500, detail="Error retrieving webhook environment information")

# Webhook Service Endpoints
@router.get("/webhook/status", tags=["Webhook"])
async def get_webhook_status(webhook_service: WebhookService = Depends(get_webhook_service)):
    """Get webhook service status and configuration"""
    try:
        status = webhook_service.get_webhook_status()
        return {
            "webhook_status": status,
            "timestamp": datetime.utcnow().isoformat()
        }
    except Exception as e:
        logger.error(f"Error getting webhook status: {e}")
        raise HTTPException(status_code=500, detail="Error retrieving webhook status")

@router.post("/webhook/test", tags=["Webhook"])
async def test_webhook(
    webhook_service: WebhookService = Depends(get_webhook_service)
):
    """Test webhook delivery to n8n"""
    try:
        # Create test OCR data
        test_data = {
            "success": True,
            "filename": "test_pdf.pdf",
            "text_count": 3,
            "results": [
                {
                    "text": "Test Text 1",
                    "confidence": 0.95,
                    "bbox": [[0.0, 0.0], [0.0, 0.0], [0.0, 0.0], [0.0, 0.0]]
                },
                {
                    "text": "Test Text 2", 
                    "confidence": 0.98,
                    "bbox": [[0.0, 0.0], [0.0, 0.0], [0.0, 0.0], [0.0, 0.0]]
                },
                {
                    "text": "Test Text 3",
                    "confidence": 0.92,
                    "bbox": [[0.0, 0.0], [0.0, 0.0], [0.0, 0.0], [0.0, 0.0]]
                }
            ]
        }
        
        logger.info("🧪 Testing webhook delivery to n8n...")
        webhook_results = await webhook_service.send_ocr_result(test_data, "test_pdf.pdf")
        
        return {
            "message": "Webhook test completed",
            "test_data": test_data,
            "webhook_results": webhook_results,
            "timestamp": datetime.utcnow().isoformat()
        }
        
    except Exception as e:
        logger.error(f"Webhook test failed: {e}")
        raise HTTPException(status_code=500, detail=f"Webhook test failed: {str(e)}")

@router.get("/metrics", tags=["Monitoring"])
async def get_metrics():
    """Get service metrics (placeholder for monitoring)"""
    return {
        "timestamp": datetime.utcnow().isoformat(),
        "service": settings.APP_NAME,
        "version": settings.APP_VERSION,
        "status": "operational"
    }

# Webhook Receiver Endpoint for Chrome
@router.post("/webhook/receive", tags=["Webhook"])
async def receive_webhook_result(data: dict):
    """Receive OCR results from webhook (for Chrome display)"""
    try:
        logger.info(f"📥 Received webhook result: {data.get('filename', 'Unknown file')}")
        
        # In a real implementation, you would:
        # 1. Store the result in a database
        # 2. Send it via WebSocket to connected Chrome clients
        # 3. Or use Server-Sent Events (SSE)
        
        # For now, we'll just log and return success
        return {
            "status": "received",
            "message": "OCR result received successfully",
            "filename": data.get('filename', 'Unknown'),
            "timestamp": datetime.utcnow().isoformat()
        }
    except Exception as e:
        logger.error(f"Error receiving webhook result: {e}")
        raise HTTPException(status_code=500, detail="Error processing webhook result")

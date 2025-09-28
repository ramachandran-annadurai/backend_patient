from datetime import datetime
from typing import Optional, Dict, Any, List
from pydantic import BaseModel, Field
from bson import ObjectId


class PatientDocument(BaseModel):
    """Model for patient document with base64 image storage"""
    id: Optional[str] = Field(None, alias="_id")
    patient_id: str = Field(..., description="Unique patient identifier")
    document_type: str = Field(..., description="Type of document (e.g., 'medical_record', 'prescription')")
    filename: str = Field(..., description="Original filename")
    file_type: str = Field(..., description="MIME type of the file")
    file_size: int = Field(..., description="File size in bytes")
    
    # Base64 encoded image data
    base64_data: str = Field(..., description="Base64 encoded file content")
    
    # OCR extracted data
    extracted_text: Optional[str] = Field(None, description="Text extracted from the document")
    ocr_results: Optional[List[Dict[str, Any]]] = Field(None, description="Detailed OCR results")
    text_count: Optional[int] = Field(None, description="Number of text elements found")
    
    # Processing metadata
    processing_method: str = Field(default="paddleocr", description="OCR method used (paddleocr, openai)")
    processing_time: Optional[float] = Field(None, description="Processing time in seconds")
    confidence_score: Optional[float] = Field(None, description="Average confidence score")
    
    # Timestamps
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)
    
    # Additional metadata
    metadata: Optional[Dict[str, Any]] = Field(default_factory=dict, description="Additional metadata")

    class Config:
        populate_by_name = True
        arbitrary_types_allowed = True


class PatientDocumentCreate(BaseModel):
    """Model for creating a new patient document"""
    patient_id: str
    document_type: str
    filename: str
    file_type: str
    file_size: int
    base64_data: str
    extracted_text: Optional[str] = None
    ocr_results: Optional[List[Dict[str, Any]]] = None
    text_count: Optional[int] = None
    processing_method: str = "paddleocr"
    processing_time: Optional[float] = None
    confidence_score: Optional[float] = None
    metadata: Optional[Dict[str, Any]] = None


class PatientDocumentResponse(BaseModel):
    """Model for patient document response"""
    id: str
    patient_id: str
    document_type: str
    filename: str
    file_type: str
    file_size: int
    extracted_text: Optional[str] = None
    text_count: Optional[int] = None
    processing_method: str
    processing_time: Optional[float] = None
    confidence_score: Optional[float] = None
    created_at: datetime
    updated_at: datetime
    metadata: Optional[Dict[str, Any]] = None
    
    # Note: base64_data and ocr_results are excluded from response for performance

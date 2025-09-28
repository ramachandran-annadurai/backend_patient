import logging
import base64
import io
from typing import Dict, Any, Optional
from PIL import Image
import requests
from ..config import settings

logger = logging.getLogger(__name__)

class OpenAIService:
    """Service for text extraction using OpenAI Vision API"""
    
    def __init__(self):
        self.api_key = settings.OPENAI_API_KEY
        self.model = settings.OPENAI_MODEL
        self.base_url = "https://api.openai.com/v1/chat/completions"
    
    def is_available(self) -> bool:
        """Check if OpenAI service is available"""
        return bool(self.api_key and self.api_key.strip())
    
    async def extract_text_from_image(self, image_data: bytes, filename: str) -> Dict[str, Any]:
        """Extract text from image using OpenAI Vision API"""
        try:
            if not self.is_available():
                logger.warning("OpenAI API key not configured")
                return {
                    "success": False,
                    "error": "OpenAI API key not configured",
                    "filename": filename
                }
            
            # Convert image to base64
            base64_image = base64.b64encode(image_data).decode('utf-8')
            
            # Get image format
            image = Image.open(io.BytesIO(image_data))
            image_format = image.format.lower() if image.format else 'png'
            
            # Prepare the request
            headers = {
                "Content-Type": "application/json",
                "Authorization": f"Bearer {self.api_key}"
            }
            
            payload = {
                "model": self.model,
                "messages": [
                    {
                        "role": "user",
                        "content": [
                            {
                                "type": "text",
                                "text": "Please extract all text content from this image. This appears to be a medical document or report. Extract all visible text including: patient names, dates, medical conditions, medications, dosages, doctor names, addresses, phone numbers, percentages, and any other textual information. Preserve the formatting and structure. Return only the extracted text content, nothing else."
                            },
                            {
                                "type": "image_url",
                                "image_url": {
                                    "url": f"data:image/{image_format};base64,{base64_image}"
                                }
                            }
                        ]
                    }
                ],
                "max_tokens": 2000,
                "temperature": 0.1
            }
            
            # Make the API request
            response = requests.post(self.base_url, headers=headers, json=payload, timeout=30)
            
            if response.status_code == 200:
                result = response.json()
                extracted_text = result['choices'][0]['message']['content'].strip()
                
                if extracted_text:
                    return {
                        "success": True,
                        "filename": filename,
                        "file_type": "IMAGE",
                        "total_pages": 1,
                        "text_count": 1,
                        "extracted_text": extracted_text,
                        "full_content": f"Text extracted using OpenAI Vision API: {extracted_text[:100]}...",
                        "results": [{
                            "text": extracted_text,
                            "confidence": 0.95,  # OpenAI doesn't provide confidence scores
                            "bbox": [[0.0, 0.0], [100.0, 0.0], [100.0, 100.0], [0.0, 100.0]]
                        }],
                        "processing_summary": {
                            "total_pages": 1,
                            "native_text_pages": 0,
                            "ocr_pages": 1,
                            "mixed_processing": False,
                            "method": "openai_vision"
                        }
                    }
                else:
                    return {
                        "success": False,
                        "filename": filename,
                        "file_type": "IMAGE",
                        "total_pages": 1,
                        "text_count": 0,
                        "extracted_text": "",
                        "full_content": "No text found in image using OpenAI Vision API",
                        "results": [],
                        "processing_summary": {
                            "total_pages": 1,
                            "native_text_pages": 0,
                            "ocr_pages": 1,
                            "mixed_processing": False,
                            "method": "openai_vision"
                        },
                        "error": "No text found in image"
                    }
            else:
                error_msg = f"OpenAI API error: {response.status_code} - {response.text}"
                logger.error(error_msg)
                return {
                    "success": False,
                    "filename": filename,
                    "file_type": "IMAGE",
                    "total_pages": 1,
                    "text_count": 0,
                    "extracted_text": "",
                    "full_content": f"OpenAI API error: {response.status_code}",
                    "results": [],
                    "processing_summary": {
                        "total_pages": 1,
                        "native_text_pages": 0,
                        "ocr_pages": 0,
                        "mixed_processing": False,
                        "method": "openai_vision",
                        "error": error_msg
                    },
                    "error": error_msg
                }
                
        except Exception as e:
            logger.error(f"Error in OpenAI text extraction: {e}")
            return {
                "success": False,
                "filename": filename,
                "file_type": "IMAGE",
                "total_pages": 1,
                "text_count": 0,
                "extracted_text": "",
                "full_content": f"OpenAI processing error: {str(e)}",
                "results": [],
                "processing_summary": {
                    "total_pages": 1,
                    "native_text_pages": 0,
                    "ocr_pages": 0,
                    "mixed_processing": False,
                    "method": "openai_vision",
                    "error": str(e)
                },
                "error": f"OpenAI processing error: {str(e)}"
            }

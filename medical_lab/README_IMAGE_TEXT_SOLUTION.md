# 🖼️ Image Text Extraction & Display Solution

This solution demonstrates how to extract text from images and display both the original image and extracted text using your Medication OCR API.

## 🎯 What This Solution Provides

✅ **Text Extraction**: Extract text from images using OCR  
✅ **Image Display**: View the original uploaded image  
✅ **Multiple Input Methods**: File upload or base64 encoded images  
✅ **Complete Workflow**: Upload → Extract → Display → Retrieve  
✅ **Multiple Interfaces**: Web UI, Python client, cURL examples  

## 📁 Files Included

| File | Description |
|------|-------------|
| `image_text_extraction_solution.html` | **Interactive web interface** - Upload images and see results |
| `python_client_example.py` | **Python client** - Programmatic access to the API |
| `curl_examples.sh` | **cURL examples** - Command-line API testing |
| `README_IMAGE_TEXT_SOLUTION.md` | This documentation file |

## 🚀 Quick Start

### Option 1: Web Interface (Recommended)

1. **Start your API server**:
   ```bash
   python -m app.main
   ```

2. **Open the web interface**:
   - Open `image_text_extraction_solution.html` in your browser
   - Update the API URL if needed (default: `http://localhost:8000`)

3. **Upload an image**:
   - Click "Choose Image File" and select an image
   - OR paste base64 encoded image data
   - Click "Extract Text & Display Image"

4. **View results**:
   - See the original image on the left
   - See extracted text on the right
   - View metadata and processing details

### Option 2: Python Client

```python
from python_client_example import ImageTextExtractor

# Initialize client
client = ImageTextExtractor("http://localhost:8000")

# Extract text from image file
result = client.extract_text_from_file("your_image.png")

# Get original image data
if result.get("document_id"):
    document_data = client.get_document_with_image(result["document_id"])
    client.save_image_from_document(document_data, "original_image")

# Display results
client.display_results(result, document_data)
```

### Option 3: cURL Commands

```bash
# Make script executable
chmod +x curl_examples.sh

# Run examples
./curl_examples.sh

# Or run individual commands:
# Upload image and extract text
curl -X POST "http://localhost:8000/ocr/upload" -F "file=@your_image.png"

# Get document with original image
curl "http://localhost:8000/documents/DOCUMENT_ID?include_base64=true"
```

## 🔧 API Endpoints Used

### 1. Upload Image and Extract Text
```http
POST /ocr/upload
Content-Type: multipart/form-data

Form Data:
- file: [image file]
```

**Response:**
```json
{
  "success": true,
  "filename": "image.png",
  "extracted_text": "Extracted text content...",
  "text_count": 150,
  "document_id": "doc_12345",
  "patient_id": "patient_67890",
  "processing_time": "2.5s",
  "confidence_score": 0.95,
  "results": [
    {
      "text": "Text block 1",
      "confidence": 0.95,
      "bbox": [[x1, y1], [x2, y2], [x3, y3], [x4, y4]]
    }
  ],
  "webhook_delivery": {
    "status": "completed",
    "results": [...]
  }
}
```

### 2. Extract Text from Base64 Image
```http
POST /ocr/base64
Content-Type: application/json

{
  "image": "base64_encoded_image_data"
}
```

### 3. Retrieve Document with Original Image
```http
GET /documents/{document_id}?include_base64=true
```

**Response:**
```json
{
  "success": true,
  "document": {
    "document_id": "doc_12345",
    "patient_id": "patient_67890",
    "filename": "image.png",
    "file_type": "image/png",
    "file_size": 245760,
    "base64_data": "iVBORw0KGgoAAAANSUhEUgAA...",
    "extracted_text": "Extracted text content...",
    "processing_method": "paddleocr",
    "confidence_score": 0.95,
    "metadata": {
      "upload_timestamp": "2024-01-15T10:30:00Z",
      "ocr_success": true
    }
  }
}
```

## 🎨 Features

### Web Interface Features
- **Drag & Drop**: Easy file selection
- **Base64 Support**: Paste base64 encoded images
- **Real-time Processing**: Live status updates
- **Responsive Design**: Works on desktop and mobile
- **Error Handling**: Clear error messages
- **Metadata Display**: Processing details and file info

### Python Client Features
- **Type Hints**: Full type annotations
- **Error Handling**: Comprehensive error management
- **Image Saving**: Automatically save retrieved images
- **Formatted Output**: Pretty-printed results
- **Interactive Mode**: Command-line interface

### cURL Examples Features
- **Complete Workflow**: Step-by-step examples
- **Multiple Formats**: Various request types
- **JSON Formatting**: Pretty-printed responses
- **Documentation**: Inline comments and explanations

## 📊 Supported File Formats

| Format | Extension | Description |
|--------|-----------|-------------|
| **Images** | `.jpg`, `.jpeg`, `.png`, `.gif`, `.bmp`, `.tiff` | All common image formats |
| **Documents** | `.pdf`, `.doc`, `.docx`, `.txt` | Document formats |
| **Base64** | Any | Base64 encoded image data |

## 🔍 How It Works

### 1. Image Upload Process
```
User Uploads Image → API Validates File → OCR Processing → MongoDB Storage → Webhook Delivery → Response
```

### 2. Text Extraction Flow
```
Image → PaddleOCR → Text Detection → Confidence Scoring → Bounding Boxes → JSON Response
```

### 3. Image Retrieval Flow
```
Document ID → MongoDB Query → Base64 Decode → Image Display
```

## 🛠️ Customization

### Change API URL
In `image_text_extraction_solution.html`:
```javascript
const API_BASE_URL = 'https://your-api-domain.com'; // Update this
```

### Add New File Types
The API automatically supports all formats handled by the Enhanced OCR Service.

### Modify Display Layout
Edit the CSS in the HTML file to change colors, layout, or styling.

## 🐛 Troubleshooting

### Common Issues

1. **API Connection Failed**
   - Check if API server is running
   - Verify API URL in client
   - Check firewall/network settings

2. **File Upload Failed**
   - Verify file format is supported
   - Check file size limits
   - Ensure file is not corrupted

3. **No Image Displayed**
   - Check if document_id was returned
   - Verify MongoDB connection
   - Check base64 data integrity

4. **Text Extraction Failed**
   - Ensure image has readable text
   - Check image quality/resolution
   - Verify OCR service is working

### Debug Mode

Enable debug logging in the Python client:
```python
import logging
logging.basicConfig(level=logging.DEBUG)
```

## 📈 Performance Tips

1. **Image Optimization**:
   - Use appropriate image sizes (not too large)
   - Optimize image quality for better OCR results

2. **Batch Processing**:
   - Process multiple images sequentially
   - Use async requests for better performance

3. **Caching**:
   - Cache document data to avoid re-downloading
   - Store base64 data locally for repeated access

## 🔒 Security Considerations

1. **File Validation**: API validates file types and sizes
2. **Base64 Sanitization**: Clean base64 data before processing
3. **Error Handling**: Don't expose sensitive error details
4. **Rate Limiting**: Consider implementing rate limits for production

## 📚 Additional Resources

- **API Documentation**: Visit `/docs` endpoint for interactive API docs
- **Postman Collection**: Use the provided Postman collection for testing
- **Flutter App**: Check the Flutter implementation in the project
- **Webhook Integration**: Set up webhooks for automated processing

## 🤝 Contributing

To improve this solution:

1. **Add Features**: New input methods, output formats, or display options
2. **Improve UI**: Better styling, animations, or user experience
3. **Add Tests**: Unit tests for the Python client
4. **Documentation**: Improve examples or add more use cases

## 📄 License

This solution is part of the Medication OCR API project. Please refer to the main project license.

---

**🎉 You now have a complete solution for extracting text from images and displaying both the original image and extracted text!**

Choose the interface that works best for your needs:
- **Web Interface**: Best for interactive use and demos
- **Python Client**: Best for automation and integration
- **cURL Examples**: Best for testing and debugging

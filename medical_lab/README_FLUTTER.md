# Medical Record Flutter App

A Flutter application for managing medical records with OCR capabilities using PaddleOCR backend integration.

## Features

- **Medical Record Form**: Complete form matching the design from the provided image
- **File Upload**: Upload PDF, images, or text files for automatic text extraction
- **OCR Integration**: Uses PaddleOCR backend for text recognition
- **Real-time Processing**: Shows loading states and progress indicators
- **Responsive Design**: Mobile-friendly interface with modern UI
- **State Management**: Uses Provider for efficient state management

## Screenshots

The app includes a medical record form with the following sections:
- Medical Conditions
- Allergies & Sensitivities  
- Current Medications
- Previous Pregnancies
- Family Health History

Each section has:
- Upload button for file processing
- Text input field for manual entry
- OCR text extraction from uploaded files
- Visual feedback for successful uploads

## Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK
- PaddleOCR backend running on localhost:8000

## Installation

1. **Clone or download the Flutter project files**

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Start the PaddleOCR backend**:
   ```bash
   # In the backend directory
   python -m uvicorn app.main:app --host 0.0.0.0 --port 8000
   ```

4. **Run the Flutter app**:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── models/
│   ├── medical_record.dart            # Medical record data model
│   └── ocr_response.dart              # OCR response data model
├── providers/
│   └── medical_record_provider.dart   # State management
├── screens/
│   └── medical_record_form_screen.dart # Main form screen
├── services/
│   └── api_service.dart               # API communication
└── widgets/
    ├── medical_form_section.dart      # Reusable form section
    └── loading_overlay.dart           # Loading indicator
```

## API Integration

The app communicates with the PaddleOCR backend through the following endpoints:

- `POST /api/v1/ocr/upload` - Upload files for OCR processing
- `POST /api/v1/ocr/base64` - Process base64 encoded images
- `GET /api/v1/health` - Health check
- `GET /api/v1/ocr/enhanced/formats` - Get supported file formats

## Supported File Types

- **PDF**: .pdf
- **Images**: .jpg, .jpeg, .png, .bmp, .tiff
- **Text**: .txt, .doc, .docx

## Usage

1. **Open the app** - The medical record form will be displayed
2. **Upload files** - Click the "Upload" button next to any section
3. **Select file** - Choose a supported file type from your device
4. **Wait for processing** - The app will show a loading indicator
5. **Review extracted text** - OCR results will populate the text field
6. **Edit if needed** - You can manually edit the extracted text
7. **Save record** - Click "Save Medical Record" to store the data

## Configuration

To change the backend URL, modify the `baseUrl` in `lib/services/api_service.dart`:

```dart
static const String baseUrl = 'http://your-backend-url:8000/api/v1';
```

## Error Handling

The app includes comprehensive error handling for:
- Network connectivity issues
- File upload failures
- OCR processing errors
- Invalid file types
- Server errors

## Dependencies

Key dependencies used in this project:

- `provider` - State management
- `dio` - HTTP client
- `file_picker` - File selection
- `material_design_icons_flutter` - Icons

## Development

To customize the app:

1. **Modify form sections** - Edit `MedicalFormSection` widget
2. **Change styling** - Update theme in `main.dart`
3. **Add new fields** - Extend the `MedicalRecord` model
4. **Customize API** - Modify `ApiService` class

## Troubleshooting

**Common issues:**

1. **Backend not running**: Ensure the PaddleOCR backend is running on port 8000
2. **File upload fails**: Check file size and format compatibility
3. **OCR not working**: Verify backend health and file format support
4. **Network errors**: Check internet connection and backend accessibility

## License

This project is part of the medical OCR system and follows the same licensing terms.

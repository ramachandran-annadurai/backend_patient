# Mobile Patient Backend

Flask API for mobile patient management system with 136 endpoints.

## Features

- User authentication & management
- Pregnancy tracking
- Medication management
- Vital signs monitoring
- OCR document processing
- AI-powered health analysis

## Deployment

This app is configured for Render deployment with:
- Python 3.11.9
- Minimal dependencies for 512MB memory limit
- Fallback modes for advanced features

## API Documentation

See `Complete_136_Endpoints_Postman_Collection.json` for full API documentation.

## Environment Variables

- `MONGO_URI` - MongoDB connection string
- `DB_NAME` - Database name
- `OPENAI_API_KEY` - OpenAI API key (optional)
- `QDRANT_URL` - Qdrant URL (optional)
- `QDRANT_API_KEY` - Qdrant API key (optional)

## Local Development

```bash
pip install -r requirements.txt
python app_simple.py
```

## Render Deployment

1. Connect your GitHub repository to Render
2. Select "Web Service"
3. Render will automatically detect the configuration
4. Set environment variables in Render dashboard
5. Deploy!

## Fallback Modes

The app is designed to work even without optional dependencies:
- Advanced AI analysis → Simple text responses
- Vector search → Empty results
- Voice features → "Service not available" messages
- Heavy ML processing → Basic processing only
# Render Deployment Guide

## Prerequisites
- Python 3.11.0
- MongoDB database (can be added via Render's database service)
- Optional: OpenAI API key, Qdrant credentials

## Deployment Steps

### 1. Prepare Your Repository
- Ensure all files are committed to your Git repository
- The following files are already configured:
  - `render.yaml` - Render service configuration
  - `Procfile` - Process file for Render
  - `runtime.txt` - Python version specification
  - `requirements.txt` - Python dependencies
  - `env.example` - Environment variables template

### 2. Deploy to Render

#### Option A: Using Render Dashboard
1. Go to [render.com](https://render.com) and sign in
2. Click "New +" → "Web Service"
3. Connect your GitHub repository
4. Select your repository and branch
5. Render will automatically detect the `render.yaml` configuration
6. Click "Create Web Service"

#### Option B: Using Render CLI
```bash
# Install Render CLI
npm install -g @render/cli

# Login to Render
render login

# Deploy from current directory
render deploy
```

### 3. Environment Variables
Set these in Render dashboard under "Environment":

**Required:**
- `MONGO_URI` - Your MongoDB connection string
- `DB_NAME` - Database name (default: patients_db)

**Optional (app will work with fallbacks):**
- `OPENAI_API_KEY` - For AI features
- `QDRANT_URL` - For vector search
- `QDRANT_API_KEY` - For vector search
- `DEFAULT_WEBHOOK_URL` - Webhook URL (already set)

### 4. Database Setup
- Add MongoDB service in Render dashboard
- Copy the connection string to `MONGO_URI` environment variable
- The app will automatically create necessary collections

### 5. Post-Deployment
- Your app will be available at: `https://your-app-name.onrender.com`
- Check logs for any startup issues
- Test API endpoints using the provided Postman collections

## Troubleshooting

### Common Issues:
1. **Protobuf errors**: Fixed with `protobuf==3.19.0` and `PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python`
2. **Memory issues**: The free tier has 512MB RAM limit
3. **Build timeouts**: Large ML dependencies may cause timeouts on free tier

### Fallback Modes:
- The app is designed to work even without optional dependencies
- ML features will use fallback responses if services are unavailable
- OCR services will work with basic functionality

## API Documentation
- Complete API documentation: `Complete_API_Documentation.md`
- Postman collections available for testing
- All endpoints support CORS for frontend integration

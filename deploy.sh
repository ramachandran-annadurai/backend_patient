#!/bin/bash
# Deploy script for Render
echo "🚀 Starting deployment..."

# Upgrade pip and install build tools
python -m pip install --upgrade pip
python -m pip install setuptools wheel

# Install requirements
python -m pip install -r requirements-minimal.txt

echo "✅ Dependencies installed successfully"
echo "🚀 Starting application..."

# Start the application
gunicorn --bind 0.0.0.0:$PORT app_simple:app

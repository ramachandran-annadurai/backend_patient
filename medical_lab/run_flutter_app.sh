#!/bin/bash

echo "🚀 Starting Medical Record Flutter App"
echo

echo "📋 Checking Flutter installation..."
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found. Please install Flutter first."
    exit 1
fi

flutter --version

echo
echo "📦 Getting Flutter dependencies..."
flutter pub get
if [ $? -ne 0 ]; then
    echo "❌ Failed to get dependencies."
    exit 1
fi

echo
echo "🧪 Testing backend connection..."
dart test_flutter_backend_connection.dart
if [ $? -ne 0 ]; then
    echo "⚠️  Backend connection test failed. Make sure the PaddleOCR backend is running."
    echo "   Run: python -m uvicorn app.main:app --host 0.0.0.0 --port 8000"
    echo
    read -p "Continue anyway? (y/n): " continue
    if [[ ! "$continue" =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo
echo "🎯 Starting Flutter app..."
echo "   Make sure you have a device connected or emulator running."
echo
flutter run

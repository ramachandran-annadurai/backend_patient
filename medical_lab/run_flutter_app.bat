@echo off
echo 🚀 Starting Medical Record Flutter App
echo.

echo 📋 Checking Flutter installation...
flutter --version
if %errorlevel% neq 0 (
    echo ❌ Flutter not found. Please install Flutter first.
    pause
    exit /b 1
)

echo.
echo 📦 Getting Flutter dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo ❌ Failed to get dependencies.
    pause
    exit /b 1
)

echo.
echo 🧪 Testing backend connection...
dart test_flutter_backend_connection.dart
if %errorlevel% neq 0 (
    echo ⚠️  Backend connection test failed. Make sure the PaddleOCR backend is running.
    echo    Run: python -m uvicorn app.main:app --host 0.0.0.0 --port 8000
    echo.
    set /p continue="Continue anyway? (y/n): "
    if /i not "%continue%"=="y" (
        pause
        exit /b 1
    )
)

echo.
echo 🎯 Starting Flutter app...
echo    Make sure you have a device connected or emulator running.
echo.
flutter run

pause

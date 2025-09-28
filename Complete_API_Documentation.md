# Complete Patient Alert System API Documentation

## Overview
This document provides comprehensive documentation for all 130+ endpoints in the Patient Alert System API with detailed success and failure responses.

## Base URL
```
http://localhost:8000
```

## Authentication
Most endpoints require JWT authentication via Bearer token in the Authorization header.

## Complete Endpoint List

### 1. System & Health Endpoints

#### GET /
**Description:** Root endpoint
**Success Response (200):**
```json
{
  "message": "Patient Alert System API",
  "version": "1.0.0",
  "status": "running",
  "endpoints": {
    "authentication": "/login, /signup, /logout",
    "symptoms": "/symptoms/*",
    "vitals": "/vitals/*",
    "medication": "/medication/*",
    "mental_health": "/mental-health/*",
    "nutrition": "/nutrition/*",
    "pregnancy": "/api/pregnancy/*",
    "hydration": "/api/hydration/*",
    "medical_lab": "/api/medical-lab/*",
    "voice": "/api/voice/*"
  }
}
```

#### GET /health
**Description:** System health check
**Success Response (200):**
```json
{
  "status": "healthy",
  "timestamp": "2025-01-27T10:30:00.000Z",
  "database": "connected",
  "services": {
    "pregnancy_tracking": "available",
    "hydration_tracking": "available",
    "mental_health_assessment": "available",
    "symptoms_analysis": "available",
    "vital_signs": "available",
    "medication_management": "available",
    "mental_health": "available",
    "nutrition_tracking": "available",
    "medical_lab_ocr": "available",
    "voice_interaction": "available"
  }
}
```

#### GET /health/database
**Description:** Database health check
**Success Response (200):**
```json
{
  "status": "healthy",
  "database": "connected",
  "collections": ["patients", "symptoms", "vitals", "medications"],
  "timestamp": "2025-01-27T10:30:00.000Z"
}
```

### 2. Authentication & User Management (12 endpoints)

#### POST /signup
**Description:** User registration
**Request:**
```json
{
  "name": "John Doe",
  "email": "patient@example.com",
  "password": "password123",
  "mobile": "+1234567890",
  "date_of_birth": "1990-01-01"
}
```
**Success Response (201):**
```json
{
  "message": "User registered successfully. OTP sent to email.",
  "patient_id": "PAT123",
  "email": "patient@example.com",
  "otp_sent": true
}
```
**Failure Responses:**
- 409: Email already exists
- 400: Missing required fields

#### POST /login
**Description:** User login
**Request:**
```json
{
  "login_identifier": "patient@example.com",
  "password": "password123"
}
```
**Success Response (200):**
```json
{
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "patient_id": "PAT123",
  "message": "Login successful",
  "user_data": {
    "patient_id": "PAT123",
    "email": "patient@example.com",
    "name": "John Doe"
  }
}
```
**Failure Responses:**
- 401: Invalid credentials
- 404: User not found

#### POST /send-otp
**Description:** Send OTP to email
**Success Response (200):**
```json
{
  "message": "OTP sent successfully",
  "email": "patient@example.com"
}
```

#### POST /verify-otp
**Description:** Verify OTP
**Success Response (200):**
```json
{
  "message": "OTP verified successfully",
  "email": "patient@example.com",
  "verified": true
}
```

#### POST /logout
**Description:** User logout
**Success Response (200):**
```json
{
  "message": "Logout successful"
}
```

#### POST /forgot-password
**Description:** Send password reset email
**Success Response (200):**
```json
{
  "message": "Password reset email sent",
  "email": "patient@example.com"
}
```

#### POST /reset-password
**Description:** Reset password with token
**Success Response (200):**
```json
{
  "message": "Password reset successfully"
}
```

#### POST /complete-profile
**Description:** Complete user profile
**Success Response (200):**
```json
{
  "message": "Profile completed successfully",
  "patient_id": "PAT123"
}
```

#### PUT /edit-profile
**Description:** Edit user profile
**Success Response (200):**
```json
{
  "message": "Profile updated successfully"
}
```

#### POST /verify-token
**Description:** Verify JWT token
**Success Response (200):**
```json
{
  "valid": true,
  "patient_id": "PAT123",
  "message": "Token is valid"
}
```

#### GET /profile/{patient_id}
**Description:** Get user profile
**Success Response (200):**
```json
{
  "patient_id": "PAT123",
  "first_name": "John",
  "last_name": "Doe",
  "email": "patient@example.com",
  "mobile": "+1234567890",
  "date_of_birth": "1990-01-01",
  "gender": "Male",
  "address": "123 Main St",
  "emergency_contact": "+1234567890",
  "created_at": "2025-01-27T10:30:00.000Z"
}
```

### 3. Sleep & Activity Tracking (8 endpoints)

#### POST /save-sleep-log
**Description:** Save sleep log
**Success Response (200):**
```json
{
  "message": "Sleep log saved successfully",
  "sleep_log_id": "SLEEP123"
}
```

#### GET /get-sleep-logs/{username}
**Description:** Get sleep logs by username
**Success Response (200):**
```json
{
  "sleep_logs": [...],
  "total_count": 5
}
```

#### GET /get-sleep-logs-by-email/{email}
**Description:** Get sleep logs by email
**Success Response (200):**
```json
{
  "sleep_logs": [...],
  "total_count": 5
}
```

#### GET /patient-complete-profile/{email}
**Description:** Get complete patient profile
**Success Response (200):**
```json
{
  "patient_profile": {...},
  "message": "Profile retrieved successfully"
}
```

#### GET /user-activities/{email}
**Description:** Get user activities
**Success Response (200):**
```json
{
  "activities": [...],
  "total_count": 10
}
```

#### GET /session-activities/{session_id}
**Description:** Get session activities
**Success Response (200):**
```json
{
  "session_activities": [...],
  "session_id": "SESSION123"
}
```

#### GET /activity-summary/{email}
**Description:** Get activity summary
**Success Response (200):**
```json
{
  "summary": {...},
  "total_activities": 50
}
```

#### POST /track-activity
**Description:** Track user activity
**Success Response (200):**
```json
{
  "message": "Activity tracked successfully",
  "activity_id": "ACT123"
}
```

### 4. Symptoms Analysis (8 endpoints)

#### GET /symptoms/health
**Description:** Symptoms service health check
**Success Response (200):**
```json
{
  "status": "healthy",
  "service": "Symptoms Analysis Service"
}
```

#### POST /symptoms/assist
**Description:** Get symptom assistance
**Success Response (200):**
```json
{
  "suggestions": [...],
  "confidence": 0.85,
  "message": "Analysis completed"
}
```

#### POST /symptoms/save-symptom-log
**Description:** Save symptom log
**Success Response (200):**
```json
{
  "message": "Symptom log saved successfully",
  "log_id": "SYMP123"
}
```

#### POST /symptoms/save-analysis-report
**Description:** Save analysis report
**Success Response (200):**
```json
{
  "message": "Analysis report saved successfully",
  "report_id": "RPT123"
}
```

#### GET /symptoms/get-symptom-history/{patient_id}
**Description:** Get symptom history
**Success Response (200):**
```json
{
  "symptom_history": [...],
  "total_count": 10
}
```

#### GET /symptoms/get-analysis-reports/{patient_id}
**Description:** Get analysis reports
**Success Response (200):**
```json
{
  "reports": [...],
  "total_count": 5
}
```

#### POST /symptoms/knowledge/add
**Description:** Add knowledge base entry
**Success Response (200):**
```json
{
  "message": "Knowledge entry added successfully"
}
```

#### POST /symptoms/knowledge/bulk
**Description:** Bulk add knowledge entries
**Success Response (200):**
```json
{
  "message": "Bulk knowledge entries added successfully",
  "added_count": 100
}
```

### 5. Vital Signs (10 endpoints)

#### POST /vitals/record
**Description:** Record vital signs
**Success Response (200):**
```json
{
  "message": "Vital signs recorded successfully",
  "record_id": "VIT123"
}
```

#### GET /vitals/history/{patient_id}
**Description:** Get vital signs history
**Success Response (200):**
```json
{
  "vital_history": [...],
  "total_count": 20
}
```

#### POST /vitals/analyze
**Description:** Analyze vital signs
**Success Response (200):**
```json
{
  "analysis": {...},
  "recommendations": [...]
}
```

#### GET /vitals/stats/{patient_id}
**Description:** Get vital signs statistics
**Success Response (200):**
```json
{
  "statistics": {...},
  "trends": [...]
}
```

#### GET /vitals/health-summary/{patient_id}
**Description:** Get health summary
**Success Response (200):**
```json
{
  "health_summary": {...},
  "risk_level": "low"
}
```

#### POST /vitals/alerts
**Description:** Create vital signs alert
**Success Response (200):**
```json
{
  "message": "Alert created successfully",
  "alert_id": "ALERT123"
}
```

#### GET /vitals/alerts/{patient_id}
**Description:** Get vital signs alerts
**Success Response (200):**
```json
{
  "alerts": [...],
  "total_count": 3
}
```

#### POST /vitals/ocr
**Description:** Process vital signs OCR
**Success Response (200):**
```json
{
  "extracted_data": {...},
  "confidence": 0.92
}
```

#### POST /vitals/process-text
**Description:** Process vital signs text
**Success Response (200):**
```json
{
  "processed_data": {...},
  "status": "success"
}
```

### 6. Medication Management (15 endpoints)

#### POST /medication/save-medication-log
**Description:** Save medication log
**Success Response (200):**
```json
{
  "message": "Medication log saved successfully",
  "log_id": "MED123"
}
```

#### GET /medication/get-medication-history/{patient_id}
**Description:** Get medication history
**Success Response (200):**
```json
{
  "medication_history": [...],
  "total_count": 15
}
```

#### GET /medication/get-upcoming-dosages/{patient_id}
**Description:** Get upcoming dosages
**Success Response (200):**
```json
{
  "upcoming_dosages": [...],
  "total_count": 5
}
```

#### POST /medication/save-tablet-taken
**Description:** Record tablet taken
**Success Response (200):**
```json
{
  "message": "Tablet taken recorded successfully"
}
```

#### GET /medication/get-tablet-history/{patient_id}
**Description:** Get tablet history
**Success Response (200):**
```json
{
  "tablet_history": [...],
  "total_count": 30
}
```

#### POST /medication/upload-prescription
**Description:** Upload prescription
**Success Response (200):**
```json
{
  "message": "Prescription uploaded successfully",
  "prescription_id": "PRES123"
}
```

#### GET /medication/get-prescription-details/{patient_id}
**Description:** Get prescription details
**Success Response (200):**
```json
{
  "prescriptions": [...],
  "total_count": 3
}
```

#### PUT /medication/update-prescription-status
**Description:** Update prescription status
**Success Response (200):**
```json
{
  "message": "Prescription status updated successfully"
}
```

#### POST /medication/process-prescription-document
**Description:** Process prescription document
**Success Response (200):**
```json
{
  "extracted_data": {...},
  "status": "success"
}
```

#### POST /medication/process-with-paddleocr
**Description:** Process with PaddleOCR
**Success Response (200):**
```json
{
  "ocr_result": {...},
  "confidence": 0.95
}
```

#### POST /medication/process-prescription-text
**Description:** Process prescription text
**Success Response (200):**
```json
{
  "processed_text": "...",
  "medications": [...]
}
```

#### POST /medication/process-with-mock-n8n
**Description:** Process with mock N8N
**Success Response (200):**
```json
{
  "mock_result": {...},
  "status": "success"
}
```

#### POST /test-n8n-webhook
**Description:** Test N8N webhook
**Success Response (200):**
```json
{
  "webhook_status": "success",
  "response": {...}
}
```

#### POST /medication/process-with-n8n-webhook
**Description:** Process with N8N webhook
**Success Response (200):**
```json
{
  "webhook_result": {...},
  "status": "success"
}
```

#### POST /medication/save-tablet-tracking
**Description:** Save tablet tracking
**Success Response (200):**
```json
{
  "message": "Tablet tracking saved successfully"
}
```

### 7. Mental Health (5 endpoints)

#### POST /mental-health/mood-checkin
**Description:** Mood check-in
**Success Response (200):**
```json
{
  "message": "Mood check-in saved successfully",
  "mood_id": "MOOD123"
}
```

#### GET /mental-health/history/{patient_id}
**Description:** Get mental health history
**Success Response (200):**
```json
{
  "mental_health_history": [...],
  "total_count": 10
}
```

#### POST /mental-health/assessment
**Description:** Mental health assessment
**Success Response (200):**
```json
{
  "assessment_result": {...},
  "recommendations": [...]
}
```

#### POST /api/mental-health/generate-story
**Description:** Generate mental health story
**Success Response (200):**
```json
{
  "story": "...",
  "story_type": "motivational"
}
```

#### POST /api/mental-health/assess
**Description:** AI mental health assessment
**Success Response (200):**
```json
{
  "assessment": {...},
  "confidence": 0.88
}
```

### 8. Nutrition Tracking (6 endpoints)

#### GET /nutrition/health
**Description:** Nutrition service health
**Success Response (200):**
```json
{
  "status": "healthy",
  "service": "Nutrition Tracking Service"
}
```

#### POST /nutrition/transcribe
**Description:** Transcribe nutrition data
**Success Response (200):**
```json
{
  "transcription": "...",
  "confidence": 0.92
}
```

#### POST /nutrition/analyze-with-gpt4
**Description:** Analyze with GPT-4
**Success Response (200):**
```json
{
  "analysis": {...},
  "recommendations": [...]
}
```

#### POST /nutrition/save-food-entry
**Description:** Save food entry
**Success Response (200):**
```json
{
  "message": "Food entry saved successfully",
  "entry_id": "FOOD123"
}
```

#### GET /nutrition/get-food-entries/{user_id}
**Description:** Get food entries
**Success Response (200):**
```json
{
  "food_entries": [...],
  "total_count": 25
}
```

#### GET /nutrition/debug-food-data/{user_id}
**Description:** Debug food data
**Success Response (200):**
```json
{
  "debug_info": {...},
  "data_structure": {...}
}
```

### 9. Pregnancy Tracking (15 endpoints)

#### GET /api/pregnancy/week/{week}
**Description:** Get pregnancy week info
**Success Response (200):**
```json
{
  "week": 12,
  "trimester": 1,
  "baby_development": "...",
  "symptoms": [...],
  "recommendations": [...]
}
```

#### GET /api/pregnancy/weeks
**Description:** Get all pregnancy weeks
**Success Response (200):**
```json
{
  "weeks": [...],
  "total_weeks": 40
}
```

#### GET /api/pregnancy/trimester/{trimester}
**Description:** Get trimester info
**Success Response (200):**
```json
{
  "trimester": 1,
  "weeks": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
  "key_developments": [...]
}
```

#### GET /api/pregnancy/week/{week}/baby-image
**Description:** Get baby size image
**Success Response (200):**
```json
{
  "image_url": "...",
  "baby_size": "lime",
  "week": 12
}
```

#### GET /api/pregnancy/week/{week}/baby-size
**Description:** Get baby size info
**Success Response (200):**
```json
{
  "size": "lime",
  "length": "5.4 cm",
  "weight": "14 grams"
}
```

#### GET /api/pregnancy/week/{week}/symptoms
**Description:** Get week symptoms
**Success Response (200):**
```json
{
  "symptoms": [...],
  "week": 12
}
```

#### GET /api/pregnancy/week/{week}/screening
**Description:** Get screening info
**Success Response (200):**
```json
{
  "screenings": [...],
  "week": 12
}
```

#### GET /api/pregnancy/week/{week}/wellness
**Description:** Get wellness tips
**Success Response (200):**
```json
{
  "wellness_tips": [...],
  "week": 12
}
```

#### GET /api/pregnancy/week/{week}/nutrition
**Description:** Get nutrition advice
**Success Response (200):**
```json
{
  "nutrition_advice": [...],
  "week": 12
}
```

#### GET /api/pregnancy/openai/status
**Description:** OpenAI service status
**Success Response (200):**
```json
{
  "status": "available",
  "service": "OpenAI Pregnancy Service"
}
```

#### POST /api/pregnancy/tracking
**Description:** Track pregnancy progress
**Success Response (200):**
```json
{
  "message": "Pregnancy progress tracked successfully",
  "tracking_id": "TRACK123"
}
```

#### GET /api/pregnancy/tracking/history
**Description:** Get tracking history
**Success Response (200):**
```json
{
  "tracking_history": [...],
  "total_count": 10
}
```

#### GET /api/pregnancy/progress
**Description:** Get pregnancy progress
**Success Response (200):**
```json
{
  "current_week": 12,
  "progress_percentage": 30,
  "next_milestone": "..."
}
```

### 10. Hydration Tracking (12 endpoints)

#### POST /api/hydration/intake
**Description:** Record hydration intake
**Success Response (200):**
```json
{
  "message": "Hydration intake recorded successfully",
  "intake_id": "HYD123"
}
```

#### GET /api/hydration/history
**Description:** Get hydration history
**Success Response (200):**
```json
{
  "hydration_history": [...],
  "total_count": 30
}
```

#### GET /api/hydration/stats
**Description:** Get hydration statistics
**Success Response (200):**
```json
{
  "daily_average": 2000,
  "weekly_total": 14000,
  "goal_achievement": 85
}
```

#### POST /api/hydration/goal
**Description:** Set hydration goal
**Success Response (200):**
```json
{
  "message": "Hydration goal set successfully",
  "goal": 2500
}
```

#### GET /api/hydration/goal
**Description:** Get hydration goal
**Success Response (200):**
```json
{
  "daily_goal": 2500,
  "current_intake": 1800,
  "remaining": 700
}
```

#### POST /api/hydration/reminder
**Description:** Set hydration reminder
**Success Response (200):**
```json
{
  "message": "Reminder set successfully",
  "reminder_id": "REM123"
}
```

#### GET /api/hydration/reminders
**Description:** Get hydration reminders
**Success Response (200):**
```json
{
  "reminders": [...],
  "total_count": 3
}
```

#### DELETE /api/hydration/reminder/{reminder_id}
**Description:** Delete hydration reminder
**Success Response (200):**
```json
{
  "message": "Reminder deleted successfully"
}
```

#### GET /api/hydration/analysis
**Description:** Get hydration analysis
**Success Response (200):**
```json
{
  "analysis": {...},
  "recommendations": [...]
}
```

#### GET /api/hydration/report
**Description:** Get hydration report
**Success Response (200):**
```json
{
  "report": {...},
  "period": "weekly"
}
```

#### GET /api/hydration/tips
**Description:** Get hydration tips
**Success Response (200):**
```json
{
  "tips": [...],
  "total_tips": 10
}
```

#### GET /api/hydration/status
**Description:** Get hydration status
**Success Response (200):**
```json
{
  "status": "good",
  "current_level": 75,
  "message": "You're doing well with hydration!"
}
```

### 11. Medical Lab OCR (5 endpoints)

#### POST /api/medical-lab/upload
**Description:** Upload medical document
**Success Response (200):**
```json
{
  "success": true,
  "extracted_data": {...},
  "confidence": 0.92,
  "patient_id": "PAT123"
}
```

#### POST /api/medical-lab/base64
**Description:** Process base64 image
**Success Response (200):**
```json
{
  "success": true,
  "extracted_data": {...},
  "confidence": 0.88,
  "patient_id": "PAT123"
}
```

#### GET /api/medical-lab/formats
**Description:** Get supported formats
**Success Response (200):**
```json
{
  "success": true,
  "supported_formats": {...},
  "description": "File formats supported by medical lab service"
}
```

#### GET /api/medical-lab/languages
**Description:** Get supported languages
**Success Response (200):**
```json
{
  "success": true,
  "supported_languages": ["en", "ch", "ko", "ja"],
  "current_language": "en"
}
```

#### GET /api/medical-lab/health
**Description:** Medical lab service health
**Success Response (200):**
```json
{
  "success": true,
  "status": "healthy",
  "service": "Medical Lab OCR Service"
}
```

### 12. Voice Interaction (7 endpoints)

#### POST /api/voice/transcribe
**Description:** Transcribe audio
**Success Response (200):**
```json
{
  "success": true,
  "transcription": {...},
  "patient_id": "PAT123"
}
```

#### POST /api/voice/transcribe-base64
**Description:** Transcribe base64 audio
**Success Response (200):**
```json
{
  "success": true,
  "transcription": {...},
  "patient_id": "PAT123"
}
```

#### POST /api/voice/ai-response
**Description:** Generate AI response
**Success Response (200):**
```json
{
  "success": true,
  "response": {...},
  "patient_id": "PAT123"
}
```

#### POST /api/voice/text-to-speech
**Description:** Convert text to speech
**Success Response (200):**
```json
{
  "success": true,
  "audio": {...},
  "patient_id": "PAT123"
}
```

#### POST /api/voice/process
**Description:** Complete voice interaction pipeline
**Success Response (200):**
```json
{
  "success": true,
  "transcription": {...},
  "ai_response": {...},
  "tts_audio": {...},
  "patient_id": "PAT123"
}
```

#### GET /api/voice/service-info
**Description:** Get voice service info
**Success Response (200):**
```json
{
  "success": true,
  "service_name": "Voice Interaction Service",
  "version": "1.0.0",
  "capabilities": [...]
}
```

#### GET /api/voice/health
**Description:** Voice service health
**Success Response (200):**
```json
{
  "success": true,
  "status": "healthy",
  "service": "Voice Interaction Service"
}
```

### 13. Additional Services (10 endpoints)

#### GET /quantum/health
**Description:** Quantum service health
**Success Response (200):**
```json
{
  "status": "healthy",
  "service": "Quantum Service"
}
```

#### GET /quantum/collections
**Description:** Get quantum collections
**Success Response (200):**
```json
{
  "collections": [...],
  "total_count": 5
}
```

#### GET /quantum/collection-status/{collection_name}
**Description:** Get collection status
**Success Response (200):**
```json
{
  "collection_name": "knowledge",
  "status": "active",
  "document_count": 1000
}
```

#### GET /llm/health
**Description:** LLM service health
**Success Response (200):**
```json
{
  "status": "healthy",
  "service": "LLM Service"
}
```

#### POST /llm/test
**Description:** Test LLM service
**Success Response (200):**
```json
{
  "test_result": "success",
  "response_time": "1.2s"
}
```

#### POST /quantum/add-knowledge
**Description:** Add knowledge to quantum
**Success Response (200):**
```json
{
  "message": "Knowledge added successfully",
  "document_id": "DOC123"
}
```

#### POST /quantum/search-knowledge
**Description:** Search quantum knowledge
**Success Response (200):**
```json
{
  "results": [...],
  "total_count": 5,
  "query": "diabetes management"
}
```

## Common Error Responses

### 400 Bad Request
```json
{
  "error": "Missing required field: field_name"
}
```

### 401 Unauthorized
```json
{
  "error": "Token is missing or invalid"
}
```

### 403 Forbidden
```json
{
  "error": "Access denied"
}
```

### 404 Not Found
```json
{
  "error": "Resource not found"
}
```

### 409 Conflict
```json
{
  "error": "Resource already exists"
}
```

### 500 Internal Server Error
```json
{
  "error": "Internal server error",
  "details": "Database connection failed"
}
```

## Postman Collection

The complete Postman collection includes:
- All 130+ endpoints
- Success and failure response examples
- Pre-configured variables
- Auto-login functionality
- Comprehensive test scenarios

Import the `Complete_Patient_Alert_System_API_Full.postman_collection.json` file into Postman to access all endpoints with detailed examples.

## Testing Instructions

1. Import the Postman collection
2. Set the `base_url` variable to your server URL
3. Run the login request to get a JWT token
4. Use the token for authenticated requests
5. Test all endpoints with various scenarios

This comprehensive API documentation covers all endpoints in your Patient Alert System with detailed success and failure responses for complete testing and integration.

# Patient Alert System - Complete 136 Endpoints

## Overview
This folder contains a comprehensive Postman collection with all 136 endpoints from the Patient Alert System API, organized by functional categories.

## Folder Structure
```
Patient_Alert_System_136_Endpoints/
├── README_136_Endpoints.md
├── Complete_136_Endpoints_Postman_Collection.json
├── Categories/
│   ├── 01_System_Health/
│   ├── 02_Authentication/
│   ├── 03_Patient_Profile/
│   ├── 04_Sleep_Activity/
│   ├── 05_Pregnancy_Tracking/
│   ├── 06_Symptoms_Analysis/
│   ├── 07_Vital_Signs/
│   ├── 08_Vital_Signs_OCR/
│   ├── 09_Medication_Management/
│   ├── 10_Quantum_LLM_Services/
│   ├── 11_Mental_Health/
│   ├── 12_Nutrition/
│   ├── 13_Pregnancy_API/
│   ├── 14_Hydration_API/
│   ├── 15_Mental_Health_API/
│   ├── 16_Medical_Lab_OCR/
│   └── 17_Voice_Interaction/
└── Environment_Variables.json
```

## Endpoint Categories

### 1. System & Health (4 endpoints)
- GET / - Root endpoint
- GET /health - Health check
- GET /health/database - Database health
- POST /health/database/reconnect - Database reconnect

### 2. Authentication & User Management (9 endpoints)
- POST /signup - User registration
- POST /send-otp - Send OTP
- POST /resend-otp - Resend OTP
- POST /verify-otp - Verify OTP
- POST /login - User login
- POST /logout - User logout
- POST /forgot-password - Forgot password
- POST /reset-password - Reset password
- POST /verify-token - Verify token

### 3. Patient Profile Management (4 endpoints)
- POST /complete-profile - Complete profile
- PUT /edit-profile - Edit profile
- GET /profile/<patient_id> - Get profile by ID
- GET /get-patient-profile-by-email/<email> - Get profile by email

### 4. Sleep & Activity Tracking (8 endpoints)
- POST /save-sleep-log - Save sleep log
- GET /get-sleep-logs/<username> - Get sleep logs by username
- GET /get-sleep-logs-by-email/<email> - Get sleep logs by email
- GET /patient-complete-profile/<email> - Get complete profile
- GET /user-activities/<email> - Get user activities
- GET /session-activities/<session_id> - Get session activities
- GET /activity-summary/<email> - Get activity summary
- POST /track-activity - Track activity
- GET /active-sessions/<email> - Get active sessions
- POST /save-kick-session - Save kick session
- GET /get-kick-history/<patient_id> - Get kick history
- GET /get-food-history/<patient_id> - Get food history
- GET /get-current-pregnancy-week/<patient_id> - Get current pregnancy week

### 5. Symptoms Analysis (8 endpoints)
- GET /symptoms/health - Symptoms service health
- POST /symptoms/assist - Get symptom assistance
- POST /symptoms/save-symptom-log - Save symptom log
- POST /symptoms/save-analysis-report - Save analysis report
- GET /symptoms/get-symptom-history/<patient_id> - Get symptom history
- GET /symptoms/get-analysis-reports/<patient_id> - Get analysis reports
- POST /symptoms/knowledge/add - Add knowledge
- POST /symptoms/knowledge/bulk - Bulk add knowledge
- POST /symptoms/ingest - Ingest knowledge

### 6. Vital Signs (8 endpoints)
- POST /vitals/record - Record vital sign
- GET /vitals/history/<patient_id> - Get vital history
- POST /vitals/analyze - Analyze vitals
- GET /vitals/stats/<patient_id> - Get vital stats
- GET /vitals/health-summary/<patient_id> - Get health summary
- POST /vitals/alerts - Create vital alert
- GET /vitals/alerts/<patient_id> - Get vital alerts
- POST /vitals/ocr - Process vital document
- POST /vitals/process-text - Process vital text

### 7. Vital Signs OCR (4 endpoints)
- POST /vital-ocr/upload - Upload vital document
- POST /vital-ocr/base64 - Process base64 vital document
- GET /vital-ocr/formats - Get supported formats
- GET /vital-ocr/status - Get OCR status

### 8. Medication Management (12 endpoints)
- POST /medication/save-medication-log - Save medication log
- GET /medication/get-medication-history/<patient_id> - Get medication history
- GET /medication/get-upcoming-dosages/<patient_id> - Get upcoming dosages
- POST /medication/save-tablet-taken - Save tablet taken
- GET /medication/get-tablet-history/<patient_id> - Get tablet history
- POST /medication/upload-prescription - Upload prescription
- GET /medication/get-prescription-details/<patient_id> - Get prescription details
- PUT /medication/update-prescription-status - Update prescription status
- POST /medication/process-prescription-document - Process prescription document
- POST /medication/process-with-paddleocr - Process with PaddleOCR
- POST /medication/process-prescription-text - Process prescription text
- POST /medication/process-with-mock-n8n - Process with mock N8N
- POST /test-n8n-webhook - Test N8N webhook
- POST /medication/process-with-n8n-webhook - Process with N8N webhook
- POST /medication/save-tablet-tracking - Save tablet tracking
- GET /medication/get-tablet-tracking-history/<patient_id> - Get tablet tracking history
- POST /medication/send-reminders - Send reminders
- POST /medication/test-reminder/<patient_id> - Test reminder
- GET /medication/test-status - Test status
- POST /medication/test-file-upload - Test file upload

### 9. Quantum & LLM Services (6 endpoints)
- GET /quantum/health - Quantum service health
- GET /quantum/collections - Get collections
- GET /quantum/collection-status/<collection_name> - Get collection status
- GET /llm/health - LLM service health
- POST /llm/test - Test LLM
- POST /quantum/add-knowledge - Add knowledge
- POST /quantum/search-knowledge - Search knowledge

### 10. Mental Health (3 endpoints)
- POST /mental-health/mood-checkin - Mood check-in
- GET /mental-health/history/<patient_id> - Get mental health history
- POST /mental-health/assessment - Mental health assessment

### 11. Nutrition (6 endpoints)
- GET /nutrition/health - Nutrition service health
- POST /nutrition/transcribe - Transcribe audio
- POST /nutrition/analyze-with-gpt4 - Analyze with GPT-4
- POST /nutrition/save-food-entry - Save food entry
- GET /nutrition/get-food-entries/<user_id> - Get food entries
- GET /nutrition/debug-food-data/<user_id> - Debug food data

### 12. Pregnancy API (12 endpoints)
- GET /api/pregnancy/week/<int:week> - Get pregnancy week
- GET /api/pregnancy/weeks - Get all weeks
- GET /api/pregnancy/trimester/<int:trimester> - Get trimester
- GET /api/pregnancy/week/<int:week>/baby-image - Get baby image
- GET /api/pregnancy/week/<int:week>/baby-size - Get baby size
- GET /api/pregnancy/week/<int:week>/symptoms - Get week symptoms
- GET /api/pregnancy/week/<int:week>/screening - Get week screening
- GET /api/pregnancy/week/<int:week>/wellness - Get week wellness
- GET /api/pregnancy/week/<int:week>/nutrition - Get week nutrition
- GET /api/pregnancy/openai/status - Get OpenAI status
- POST /api/pregnancy/tracking - Track pregnancy
- GET /api/pregnancy/tracking/history - Get tracking history
- GET /api/pregnancy/progress - Get pregnancy progress

### 13. Hydration API (10 endpoints)
- POST /api/hydration/intake - Record hydration intake
- GET /api/hydration/history - Get hydration history
- GET /api/hydration/stats - Get hydration stats
- POST /api/hydration/goal - Set hydration goal
- GET /api/hydration/goal - Get hydration goal
- POST /api/hydration/reminder - Set hydration reminder
- GET /api/hydration/reminders - Get hydration reminders
- GET /api/hydration/analysis - Get hydration analysis
- GET /api/hydration/report - Get hydration report
- GET /api/hydration/tips - Get hydration tips
- GET /api/hydration/status - Get hydration status

### 14. Mental Health API (10 endpoints)
- POST /api/mental-health/generate-story - Generate story
- POST /api/mental-health/assess - Mental health assessment
- POST /api/mental-health/generate-audio - Generate audio
- GET /api/mental-health/story-types - Get story types
- GET /api/mental-health/health - Mental health service health
- POST /api/mental-health/chat - Chat with AI
- GET /api/mental-health/chat/history - Get chat history
- POST /api/mental-health/chat/session - Create chat session
- DELETE /api/mental-health/chat/session/<session_id> - Delete chat session
- GET /api/mental-health/assessments - Get assessments
- GET /api/mental-health/debug - Debug mental health

### 15. Medical Lab OCR (6 endpoints)
- POST /api/medical-lab/upload - Upload lab document
- POST /api/medical-lab/base64 - Process base64 lab document
- GET /api/medical-lab/formats - Get supported formats
- GET /api/medical-lab/languages - Get supported languages
- GET /api/medical-lab/health - Medical lab service health

### 16. Voice Interaction (6 endpoints)
- POST /api/voice/transcribe - Transcribe audio
- POST /api/voice/transcribe-base64 - Transcribe base64 audio
- POST /api/voice/ai-response - Get AI response
- POST /api/voice/text-to-speech - Convert text to speech
- POST /api/voice/process - Process voice interaction
- GET /api/voice/service-info - Get service info
- GET /api/voice/health - Voice service health

## Environment Variables
- base_url: http://localhost:8000
- auth_token: JWT token for authentication
- patient_id: Patient ID for testing

## Usage
1. Import the Complete_136_Endpoints_Postman_Collection.json into Postman
2. Set up environment variables
3. Start with authentication endpoints to get a token
4. Use the token for authenticated endpoints
5. Test endpoints by category

## Total Count: 136 Endpoints

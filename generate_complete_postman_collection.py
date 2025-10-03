#!/usr/bin/env python3
"""
Generate Complete Postman Collection for Patient Alert System
All 136 endpoints organized by categories
"""

import json

def create_complete_postman_collection():
    """Create the complete Postman collection with all 136 endpoints"""
    
    collection = {
        "info": {
            "name": "Patient Alert System - Complete 136 Endpoints",
            "description": "Comprehensive Postman collection for all 136 endpoints in the Patient Alert System API",
            "version": "1.0.0",
            "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
        },
        "variable": [
            {
                "key": "base_url",
                "value": "http://localhost:8000",
                "type": "string"
            },
            {
                "key": "auth_token",
                "value": "",
                "type": "string"
            },
            {
                "key": "patient_id",
                "value": "PAT123",
                "type": "string"
            }
        ],
        "auth": {
            "type": "bearer",
            "bearer": [
                {
                    "key": "token",
                    "value": "{{auth_token}}",
                    "type": "string"
                }
            ]
        },
        "item": []
    }
    
    # Define all 136 endpoints organized by categories
    categories = [
        {
            "name": "1. System & Health (4 endpoints)",
            "endpoints": [
                {"name": "Root Endpoint", "method": "GET", "path": "/", "auth": False},
                {"name": "Health Check", "method": "GET", "path": "/health", "auth": False},
                {"name": "Database Health", "method": "GET", "path": "/health/database", "auth": False},
                {"name": "Database Reconnect", "method": "POST", "path": "/health/database/reconnect", "auth": False}
            ]
        },
        {
            "name": "2. Authentication & User Management (9 endpoints)",
            "endpoints": [
                {"name": "User Signup", "method": "POST", "path": "/signup", "auth": False, "body": {
                    "username": "john_doe", "email": "john@example.com", "mobile": "+1234567890", "password": "password123"
                }},
                {"name": "Send OTP", "method": "POST", "path": "/send-otp", "auth": False, "body": {
                    "email": "john@example.com"
                }},
                {"name": "Resend OTP", "method": "POST", "path": "/resend-otp", "auth": False, "body": {
                    "email": "john@example.com"
                }},
                {"name": "Verify OTP", "method": "POST", "path": "/verify-otp", "auth": False, "body": {
                    "email": "john@example.com", "otp": "123456"
                }},
                {"name": "User Login", "method": "POST", "path": "/login", "auth": False, "body": {
                    "email": "john@example.com", "password": "password123"
                }},
                {"name": "User Logout", "method": "POST", "path": "/logout", "auth": True},
                {"name": "Forgot Password", "method": "POST", "path": "/forgot-password", "auth": False, "body": {
                    "email": "john@example.com"
                }},
                {"name": "Reset Password", "method": "POST", "path": "/reset-password", "auth": False, "body": {
                    "email": "john@example.com", "otp": "123456", "new_password": "newpassword123"
                }},
                {"name": "Verify Token", "method": "POST", "path": "/verify-token", "auth": True}
            ]
        },
        {
            "name": "3. Patient Profile Management (4 endpoints)",
            "endpoints": [
                {"name": "Complete Profile", "method": "POST", "path": "/complete-profile", "auth": True, "body": {
                    "first_name": "John", "last_name": "Doe", "date_of_birth": "1990-01-01", 
                    "blood_type": "O+", "address": "123 Main St", "emergency_contact": "+1234567890"
                }},
                {"name": "Edit Profile", "method": "PUT", "path": "/edit-profile", "auth": True, "body": {
                    "first_name": "John", "last_name": "Doe", "address": "456 New St"
                }},
                {"name": "Get Profile by ID", "method": "GET", "path": "/profile/{{patient_id}}", "auth": True},
                {"name": "Get Patient Profile by Email", "method": "GET", "path": "/get-patient-profile-by-email/john@example.com", "auth": True}
            ]
        },
        {
            "name": "4. Sleep & Activity Tracking (13 endpoints)",
            "endpoints": [
                {"name": "Save Sleep Log", "method": "POST", "path": "/save-sleep-log", "auth": True, "body": {
                    "username": "john_doe", "sleep_hours": 8, "sleep_quality": "good", 
                    "bedtime": "22:00", "wake_time": "06:00"
                }},
                {"name": "Get Sleep Logs by Username", "method": "GET", "path": "/get-sleep-logs/john_doe", "auth": True},
                {"name": "Get Sleep Logs by Email", "method": "GET", "path": "/get-sleep-logs-by-email/john@example.com", "auth": True},
                {"name": "Get Patient Complete Profile", "method": "GET", "path": "/patient-complete-profile/john@example.com", "auth": True},
                {"name": "Get User Activities", "method": "GET", "path": "/user-activities/john@example.com", "auth": True},
                {"name": "Get Session Activities", "method": "GET", "path": "/session-activities/session123", "auth": True},
                {"name": "Get Activity Summary", "method": "GET", "path": "/activity-summary/john@example.com", "auth": True},
                {"name": "Track Activity", "method": "POST", "path": "/track-activity", "auth": True, "body": {
                    "email": "john@example.com", "activity_type": "walking", "duration": 30, "intensity": "moderate"
                }},
                {"name": "Get Active Sessions", "method": "GET", "path": "/active-sessions/john@example.com", "auth": True},
                {"name": "Save Kick Session", "method": "POST", "path": "/save-kick-session", "auth": True, "body": {
                    "patient_id": "{{patient_id}}", "kick_count": 10, "session_duration": 30, "notes": "Baby was very active"
                }},
                {"name": "Get Kick History", "method": "GET", "path": "/get-kick-history/{{patient_id}}", "auth": True},
                {"name": "Get Food History", "method": "GET", "path": "/get-food-history/{{patient_id}}", "auth": True},
                {"name": "Get Current Pregnancy Week", "method": "GET", "path": "/get-current-pregnancy-week/{{patient_id}}", "auth": True}
            ]
        },
        {
            "name": "5. Symptoms Analysis (9 endpoints)",
            "endpoints": [
                {"name": "Symptoms Service Health", "method": "GET", "path": "/symptoms/health", "auth": False},
                {"name": "Get Symptom Assistance", "method": "POST", "path": "/symptoms/assist", "auth": True, "body": {
                    "patient_id": "{{patient_id}}", "symptoms": ["nausea", "fatigue"], "week": 12
                }},
                {"name": "Save Symptom Log", "method": "POST", "path": "/symptoms/save-symptom-log", "auth": True, "body": {
                    "patient_id": "{{patient_id}}", "symptoms": ["nausea", "fatigue"], "severity": "moderate", "notes": "Feeling tired"
                }},
                {"name": "Save Analysis Report", "method": "POST", "path": "/symptoms/save-analysis-report", "auth": True, "body": {
                    "patient_id": "{{patient_id}}", "analysis": "Normal pregnancy symptoms", "recommendations": "Rest more"
                }},
                {"name": "Get Symptom History", "method": "GET", "path": "/symptoms/get-symptom-history/{{patient_id}}", "auth": True},
                {"name": "Get Analysis Reports", "method": "GET", "path": "/symptoms/get-analysis-reports/{{patient_id}}", "auth": True},
                {"name": "Add Knowledge", "method": "POST", "path": "/symptoms/knowledge/add", "auth": True, "body": {
                    "title": "Pregnancy Symptoms", "content": "Common pregnancy symptoms include...", "category": "pregnancy"
                }},
                {"name": "Bulk Add Knowledge", "method": "POST", "path": "/symptoms/knowledge/bulk", "auth": True, "body": {
                    "knowledge_items": [{"title": "Symptom 1", "content": "Content 1"}, {"title": "Symptom 2", "content": "Content 2"}]
                }},
                {"name": "Ingest Knowledge", "method": "POST", "path": "/symptoms/ingest", "auth": True, "body": {
                    "collection_name": "pregnancy_symptoms"
                }}
            ]
        },
        {
            "name": "6. Vital Signs (8 endpoints)",
            "endpoints": [
                {"name": "Record Vital Sign", "method": "POST", "path": "/vitals/record", "auth": True, "body": {
                    "patient_id": "{{patient_id}}", "blood_pressure": "120/80", "heart_rate": 72, "temperature": 98.6
                }},
                {"name": "Get Vital History", "method": "GET", "path": "/vitals/history/{{patient_id}}", "auth": True},
                {"name": "Analyze Vitals", "method": "POST", "path": "/vitals/analyze", "auth": True, "body": {
                    "patient_id": "{{patient_id}}", "vitals": {"blood_pressure": "120/80", "heart_rate": 72}
                }},
                {"name": "Get Vital Stats", "method": "GET", "path": "/vitals/stats/{{patient_id}}", "auth": True},
                {"name": "Get Health Summary", "method": "GET", "path": "/vitals/health-summary/{{patient_id}}", "auth": True},
                {"name": "Create Vital Alert", "method": "POST", "path": "/vitals/alerts", "auth": True, "body": {
                    "patient_id": "{{patient_id}}", "alert_type": "high_blood_pressure", "message": "Blood pressure is high"
                }},
                {"name": "Get Vital Alerts", "method": "GET", "path": "/vitals/alerts/{{patient_id}}", "auth": True},
                {"name": "Process Vital OCR", "method": "POST", "path": "/vitals/ocr", "auth": True, "body": {
                    "patient_id": "{{patient_id}}", "image_data": "base64_encoded_image"
                }},
                {"name": "Process Vital Text", "method": "POST", "path": "/vitals/process-text", "auth": True, "body": {
                    "patient_id": "{{patient_id}}", "text": "Blood Pressure: 120/80, Heart Rate: 72"
                }}
            ]
        },
        {
            "name": "7. Vital Signs OCR (4 endpoints)",
            "endpoints": [
                {"name": "Upload Vital Document", "method": "POST", "path": "/vital-ocr/upload", "auth": True, "body": {
                    "patient_id": "{{patient_id}}", "file": "vital_signs_document.pdf"
                }},
                {"name": "Process Base64 Vital Document", "method": "POST", "path": "/vital-ocr/base64", "auth": True, "body": {
                    "patient_id": "{{patient_id}}", "base64_data": "base64_encoded_document"
                }},
                {"name": "Get Supported Formats", "method": "GET", "path": "/vital-ocr/formats", "auth": False},
                {"name": "Get OCR Status", "method": "GET", "path": "/vital-ocr/status", "auth": False}
            ]
        },
        {
            "name": "8. Medication Management (20 endpoints)",
            "endpoints": [
                {"name": "Save Medication Log", "method": "POST", "path": "/medication/save-medication-log", "auth": True, "body": {
                    "patient_id": "{{patient_id}}", "medication_name": "Prenatal Vitamins", "dosage": "1 tablet", "frequency": "daily"
                }},
                {"name": "Get Medication History", "method": "GET", "path": "/medication/get-medication-history/{{patient_id}}", "auth": True},
                {"name": "Get Upcoming Dosages", "method": "GET", "path": "/medication/get-upcoming-dosages/{{patient_id}}", "auth": True},
                {"name": "Save Tablet Taken", "method": "POST", "path": "/medication/save-tablet-taken", "auth": True, "body": {
                    "patient_id": "{{patient_id}}", "medication_id": "med123", "taken_at": "2024-01-27T10:00:00Z"
                }},
                {"name": "Get Tablet History", "method": "GET", "path": "/medication/get-tablet-history/{{patient_id}}", "auth": True},
                {"name": "Upload Prescription", "method": "POST", "path": "/medication/upload-prescription", "auth": True, "body": {
                    "patient_id": "{{patient_id}}", "prescription_file": "prescription.pdf"
                }},
                {"name": "Get Prescription Details", "method": "GET", "path": "/medication/get-prescription-details/{{patient_id}}", "auth": True},
                {"name": "Update Prescription Status", "method": "PUT", "path": "/medication/update-prescription-status", "auth": True, "body": {
                    "prescription_id": "pres123", "status": "completed"
                }},
                {"name": "Process Prescription Document", "method": "POST", "path": "/medication/process-prescription-document", "auth": True, "body": {
                    "patient_id": "{{patient_id}}", "document_data": "base64_encoded_document"
                }},
                {"name": "Process with PaddleOCR", "method": "POST", "path": "/medication/process-with-paddleocr", "auth": True, "body": {
                    "patient_id": "{{patient_id}}", "image_data": "base64_encoded_image"
                }},
                {"name": "Process Prescription Text", "method": "POST", "path": "/medication/process-prescription-text", "auth": True, "body": {
                    "patient_id": "{{patient_id}}", "text": "Prescription text content"
                }},
                {"name": "Process with Mock N8N", "method": "POST", "path": "/medication/process-with-mock-n8n", "auth": True, "body": {
                    "patient_id": "{{patient_id}}", "prescription_data": "prescription_data"
                }},
                {"name": "Test N8N Webhook", "method": "POST", "path": "/test-n8n-webhook", "auth": True, "body": {
                    "test_data": "webhook_test_data"
                }},
                {"name": "Process with N8N Webhook", "method": "POST", "path": "/medication/process-with-n8n-webhook", "auth": True, "body": {
                    "patient_id": "{{patient_id}}", "webhook_data": "webhook_data"
                }},
                {"name": "Save Tablet Tracking", "method": "POST", "path": "/medication/save-tablet-tracking", "auth": True, "body": {
                    "patient_id": "{{patient_id}}", "medication_name": "Prenatal Vitamins", "taken": True, "timestamp": "2024-01-27T10:00:00Z"
                }},
                {"name": "Get Tablet Tracking History", "method": "GET", "path": "/medication/get-tablet-tracking-history/{{patient_id}}", "auth": True},
                {"name": "Send Reminders", "method": "POST", "path": "/medication/send-reminders", "auth": True, "body": {
                    "patient_id": "{{patient_id}}"
                }},
                {"name": "Test Reminder", "method": "POST", "path": "/medication/test-reminder/{{patient_id}}", "auth": True},
                {"name": "Test Status", "method": "GET", "path": "/medication/test-status", "auth": False},
                {"name": "Test File Upload", "method": "POST", "path": "/medication/test-file-upload", "auth": True, "body": {
                    "test_file": "test_prescription.pdf"
                }}
            ]
        },
        {
            "name": "9. Quantum & LLM Services (7 endpoints)",
            "endpoints": [
                {"name": "Quantum Service Health", "method": "GET", "path": "/quantum/health", "auth": False},
                {"name": "Get Collections", "method": "GET", "path": "/quantum/collections", "auth": False},
                {"name": "Get Collection Status", "method": "GET", "path": "/quantum/collection-status/pregnancy_symptoms", "auth": False},
                {"name": "LLM Service Health", "method": "GET", "path": "/llm/health", "auth": False},
                {"name": "Test LLM", "method": "POST", "path": "/llm/test", "auth": True, "body": {
                    "prompt": "Test prompt for LLM", "model": "gpt-4"
                }},
                {"name": "Add Knowledge", "method": "POST", "path": "/quantum/add-knowledge", "auth": True, "body": {
                    "title": "Pregnancy Knowledge", "content": "Knowledge content", "category": "pregnancy"
                }},
                {"name": "Search Knowledge", "method": "POST", "path": "/quantum/search-knowledge", "auth": True, "body": {
                    "query": "pregnancy symptoms", "limit": 10
                }}
            ]
        },
        {
            "name": "10. Mental Health (3 endpoints)",
            "endpoints": [
                {"name": "Mood Check-in", "method": "POST", "path": "/mental-health/mood-checkin", "auth": True, "body": {
                    "patient_id": "{{patient_id}}", "mood": "happy", "energy_level": 8, "notes": "Feeling good today"
                }},
                {"name": "Get Mental Health History", "method": "GET", "path": "/mental-health/history/{{patient_id}}", "auth": True},
                {"name": "Mental Health Assessment", "method": "POST", "path": "/mental-health/assessment", "auth": True, "body": {
                    "patient_id": "{{patient_id}}", "responses": {"question1": "answer1", "question2": "answer2"}
                }}
            ]
        },
        {
            "name": "11. Nutrition (6 endpoints)",
            "endpoints": [
                {"name": "Nutrition Service Health", "method": "GET", "path": "/nutrition/health", "auth": False},
                {"name": "Transcribe Audio", "method": "POST", "path": "/nutrition/transcribe", "auth": True, "body": {
                    "audio_data": "base64_encoded_audio", "language": "en"
                }},
                {"name": "Analyze with GPT-4", "method": "POST", "path": "/nutrition/analyze-with-gpt4", "auth": True, "body": {
                    "patient_id": "{{patient_id}}", "food_description": "Grilled chicken with vegetables"
                }},
                {"name": "Save Food Entry", "method": "POST", "path": "/nutrition/save-food-entry", "auth": True, "body": {
                    "patient_id": "{{patient_id}}", "food_name": "Grilled Chicken", "calories": 300, "meal_type": "lunch"
                }},
                {"name": "Get Food Entries", "method": "GET", "path": "/nutrition/get-food-entries/{{patient_id}}", "auth": True},
                {"name": "Debug Food Data", "method": "GET", "path": "/nutrition/debug-food-data/{{patient_id}}", "auth": True}
            ]
        },
        {
            "name": "12. Pregnancy API (12 endpoints)",
            "endpoints": [
                {"name": "Get Pregnancy Week", "method": "GET", "path": "/api/pregnancy/week/12", "auth": False},
                {"name": "Get All Weeks", "method": "GET", "path": "/api/pregnancy/weeks", "auth": False},
                {"name": "Get Trimester", "method": "GET", "path": "/api/pregnancy/trimester/1", "auth": False},
                {"name": "Get Baby Image", "method": "GET", "path": "/api/pregnancy/week/12/baby-image", "auth": False},
                {"name": "Get Baby Size", "method": "GET", "path": "/api/pregnancy/week/12/baby-size", "auth": False},
                {"name": "Get Week Symptoms", "method": "GET", "path": "/api/pregnancy/week/12/symptoms", "auth": False},
                {"name": "Get Week Screening", "method": "GET", "path": "/api/pregnancy/week/12/screening", "auth": False},
                {"name": "Get Week Wellness", "method": "GET", "path": "/api/pregnancy/week/12/wellness", "auth": False},
                {"name": "Get Week Nutrition", "method": "GET", "path": "/api/pregnancy/week/12/nutrition", "auth": False},
                {"name": "Get OpenAI Status", "method": "GET", "path": "/api/pregnancy/openai/status", "auth": False},
                {"name": "Track Pregnancy", "method": "POST", "path": "/api/pregnancy/tracking", "auth": True, "body": {
                    "patient_id": "{{patient_id}}", "current_week": 12, "notes": "Feeling good"
                }},
                {"name": "Get Tracking History", "method": "GET", "path": "/api/pregnancy/tracking/history", "auth": True},
                {"name": "Get Pregnancy Progress", "method": "GET", "path": "/api/pregnancy/progress", "auth": True}
            ]
        },
        {
            "name": "13. Hydration API (10 endpoints)",
            "endpoints": [
                {"name": "Record Hydration Intake", "method": "POST", "path": "/api/hydration/intake", "auth": True, "body": {
                    "patient_id": "{{patient_id}}", "amount": 250, "unit": "ml", "timestamp": "2024-01-27T10:00:00Z"
                }},
                {"name": "Get Hydration History", "method": "GET", "path": "/api/hydration/history", "auth": True},
                {"name": "Get Hydration Stats", "method": "GET", "path": "/api/hydration/stats", "auth": True},
                {"name": "Set Hydration Goal", "method": "POST", "path": "/api/hydration/goal", "auth": True, "body": {
                    "patient_id": "{{patient_id}}", "daily_goal": 2000, "unit": "ml"
                }},
                {"name": "Get Hydration Goal", "method": "GET", "path": "/api/hydration/goal", "auth": True},
                {"name": "Set Hydration Reminder", "method": "POST", "path": "/api/hydration/reminder", "auth": True, "body": {
                    "patient_id": "{{patient_id}}", "reminder_time": "10:00", "frequency": "hourly"
                }},
                {"name": "Get Hydration Reminders", "method": "GET", "path": "/api/hydration/reminders", "auth": True},
                {"name": "Get Hydration Analysis", "method": "GET", "path": "/api/hydration/analysis", "auth": True},
                {"name": "Get Hydration Report", "method": "GET", "path": "/api/hydration/report", "auth": True},
                {"name": "Get Hydration Tips", "method": "GET", "path": "/api/hydration/tips", "auth": True},
                {"name": "Get Hydration Status", "method": "GET", "path": "/api/hydration/status", "auth": True}
            ]
        },
        {
            "name": "14. Mental Health API (10 endpoints)",
            "endpoints": [
                {"name": "Generate Story", "method": "POST", "path": "/api/mental-health/generate-story", "auth": True, "body": {
                    "patient_id": "{{patient_id}}", "story_type": "motivational", "mood": "anxious"
                }},
                {"name": "Mental Health Assessment", "method": "POST", "path": "/api/mental-health/assess", "auth": True, "body": {
                    "patient_id": "{{patient_id}}", "responses": {"stress_level": 7, "sleep_quality": 6}
                }},
                {"name": "Generate Audio", "method": "POST", "path": "/api/mental-health/generate-audio", "auth": True, "body": {
                    "patient_id": "{{patient_id}}", "text": "Relaxation story", "voice_type": "calm"
                }},
                {"name": "Get Story Types", "method": "GET", "path": "/api/mental-health/story-types", "auth": False},
                {"name": "Mental Health Service Health", "method": "GET", "path": "/api/mental-health/health", "auth": False},
                {"name": "Chat with AI", "method": "POST", "path": "/api/mental-health/chat", "auth": True, "body": {
                    "patient_id": "{{patient_id}}", "message": "I'm feeling anxious", "session_id": "session123"
                }},
                {"name": "Get Chat History", "method": "GET", "path": "/api/mental-health/chat/history", "auth": True},
                {"name": "Create Chat Session", "method": "POST", "path": "/api/mental-health/chat/session", "auth": True, "body": {
                    "patient_id": "{{patient_id}}", "session_type": "therapy"
                }},
                {"name": "Delete Chat Session", "method": "DELETE", "path": "/api/mental-health/chat/session/session123", "auth": True},
                {"name": "Get Assessments", "method": "GET", "path": "/api/mental-health/assessments", "auth": True},
                {"name": "Debug Mental Health", "method": "GET", "path": "/api/mental-health/debug", "auth": True}
            ]
        },
        {
            "name": "15. Medical Lab OCR (5 endpoints)",
            "endpoints": [
                {"name": "Upload Lab Document", "method": "POST", "path": "/api/medical-lab/upload", "auth": True, "body": {
                    "patient_id": "{{patient_id}}", "lab_file": "lab_results.pdf"
                }},
                {"name": "Process Base64 Lab Document", "method": "POST", "path": "/api/medical-lab/base64", "auth": True, "body": {
                    "patient_id": "{{patient_id}}", "base64_data": "base64_encoded_lab_document"
                }},
                {"name": "Get Supported Formats", "method": "GET", "path": "/api/medical-lab/formats", "auth": False},
                {"name": "Get Supported Languages", "method": "GET", "path": "/api/medical-lab/languages", "auth": False},
                {"name": "Medical Lab Service Health", "method": "GET", "path": "/api/medical-lab/health", "auth": False}
            ]
        },
        {
            "name": "16. Voice Interaction (7 endpoints)",
            "endpoints": [
                {"name": "Transcribe Audio", "method": "POST", "path": "/api/voice/transcribe", "auth": True, "body": {
                    "patient_id": "{{patient_id}}", "audio_data": "base64_encoded_audio", "language": "en"
                }},
                {"name": "Transcribe Base64 Audio", "method": "POST", "path": "/api/voice/transcribe-base64", "auth": True, "body": {
                    "patient_id": "{{patient_id}}", "base64_audio": "base64_encoded_audio"
                }},
                {"name": "Get AI Response", "method": "POST", "path": "/api/voice/ai-response", "auth": True, "body": {
                    "patient_id": "{{patient_id}}", "transcript": "Hello, I need help with my symptoms"
                }},
                {"name": "Text to Speech", "method": "POST", "path": "/api/voice/text-to-speech", "auth": True, "body": {
                    "patient_id": "{{patient_id}}", "text": "Hello, how can I help you today?", "voice": "friendly"
                }},
                {"name": "Process Voice Interaction", "method": "POST", "path": "/api/voice/process", "auth": True, "body": {
                    "patient_id": "{{patient_id}}", "audio_data": "base64_encoded_audio", "interaction_type": "symptom_check"
                }},
                {"name": "Get Service Info", "method": "GET", "path": "/api/voice/service-info", "auth": False},
                {"name": "Voice Service Health", "method": "GET", "path": "/api/voice/health", "auth": False}
            ]
        }
    ]
    
    # Generate the collection items
    for category in categories:
        category_item = {
            "name": category["name"],
            "item": []
        }
        
        for endpoint in category["endpoints"]:
            request = {
                "method": endpoint["method"],
                "header": [
                    {"key": "Content-Type", "value": "application/json"}
                ],
                "url": {
                    "raw": f"{{{{base_url}}}}{endpoint['path']}",
                    "host": ["{{base_url}}"],
                    "path": endpoint['path'].split('/')[1:] if endpoint['path'].startswith('/') else endpoint['path'].split('/')
                }
            }
            
            # Add authentication header if required
            if endpoint.get("auth", False):
                request["header"].append({"key": "Authorization", "value": "Bearer {{auth_token}}"})
            
            # Add request body if specified
            if "body" in endpoint:
                request["body"] = {
                    "mode": "raw",
                    "raw": json.dumps(endpoint["body"], indent=2)
                }
            
            category_item["item"].append({
                "name": endpoint["name"],
                "request": request
            })
        
        collection["item"].append(category_item)
    
    return collection

def main():
    """Generate and save the complete Postman collection"""
    collection = create_complete_postman_collection()
    
    # Save to file
    with open("Complete_136_Endpoints_Postman_Collection.json", "w", encoding="utf-8") as f:
        json.dump(collection, f, indent=2, ensure_ascii=False)
    
    print("✅ Complete Postman collection generated successfully!")
    print(f"📊 Total categories: {len(collection['item'])}")
    
    total_endpoints = sum(len(category["item"]) for category in collection["item"])
    print(f"📊 Total endpoints: {total_endpoints}")
    
    print("\n📁 Files created:")
    print("- Complete_136_Endpoints_Postman_Collection.json")
    print("- README_136_Endpoints.md")

if __name__ == "__main__":
    main()



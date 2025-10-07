# Pregnancy Tracking Module - API Documentation

Complete documentation for the Pregnancy Tracking API endpoints.

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Authentication](#authentication)
3. [API Endpoints](#api-endpoints)
   - [Pregnancy Week Information](#pregnancy-week-information)
   - [AI-Powered Insights](#ai-powered-insights)
   - [Pregnancy Tracking & History](#pregnancy-tracking--history)
   - [Pregnancy Week Management](#pregnancy-week-management)
   - [Service Status](#service-status)
4. [Request/Response Examples](#requestresponse-examples)
5. [Error Handling](#error-handling)
6. [Integration Guide](#integration-guide)

---

## Overview

The Pregnancy Tracking Module provides comprehensive APIs for:
- 📅 **Week-by-week pregnancy information** (40 weeks)
- 🤖 **AI-powered insights** (baby size, symptoms, screening, wellness, nutrition)
- 📊 **Progress tracking** (weight, symptoms, mood, baby movements)
- 📈 **Historical data** and analytics
- 🔄 **Automatic week calculation** based on last period date

**Base URL:** `http://localhost:8000`

---

## Authentication

Most endpoints require JWT Bearer token authentication.

### Headers Required:
```
Authorization: Bearer YOUR_JWT_TOKEN
Content-Type: application/json
```

### Get Token:
Use the login endpoint to obtain a JWT token:
```bash
POST /login
{
  "email": "patient@example.com",
  "password": "your_password"
}
```

---

## API Endpoints

### Pregnancy Week Information

#### 1. Get Specific Pregnancy Week
Get detailed information for a specific pregnancy week (1-40).

**Endpoint:** `GET /api/pregnancy/week/{week}`  
**Authentication:** Required  
**Parameters:**
- `week` (path parameter, integer, 1-40): Pregnancy week number

**Response:**
```json
{
  "success": true,
  "data": {
    "week": 12,
    "trimester": 1,
    "baby_size_cm": 5.4,
    "baby_weight_grams": 14,
    "size_comparison": "Lime",
    "mother_symptoms": ["Nausea", "Fatigue"],
    "baby_development": "Baby's organs are forming...",
    "tips": ["Stay hydrated", "Rest when needed"]
  }
}
```

---

#### 2. Get All Pregnancy Weeks
Get information for all pregnancy weeks (1-40).

**Endpoint:** `GET /api/pregnancy/weeks`  
**Authentication:** Required

**Response:**
```json
{
  "success": true,
  "data": {
    "1": { "week": 1, "trimester": 1, ... },
    "2": { "week": 2, "trimester": 1, ... },
    ...
    "40": { "week": 40, "trimester": 3, ... }
  },
  "message": "Successfully retrieved data for 40 weeks"
}
```

---

#### 3. Get Trimester Weeks
Get all weeks for a specific trimester.

**Endpoint:** `GET /api/pregnancy/trimester/{trimester}`  
**Authentication:** Required  
**Parameters:**
- `trimester` (path parameter, integer, 1-3):
  - Trimester 1: Weeks 1-13
  - Trimester 2: Weeks 14-27
  - Trimester 3: Weeks 28-40

**Response:**
```json
{
  "success": true,
  "trimester": 2,
  "weeks": {
    "14": { "week": 14, ... },
    "15": { "week": 15, ... },
    ...
    "27": { "week": 27, ... }
  },
  "message": "Successfully retrieved weeks for trimester 2"
}
```

---

#### 4. Get Current Pregnancy Week
Get the current pregnancy week for a specific patient. Auto-calculates based on last period date if available.

**Endpoint:** `GET /get-current-pregnancy-week/{patient_id}`  
**Authentication:** Not required  
**Parameters:**
- `patient_id` (path parameter, string): Patient ID (e.g., "PAT123456789")

**Response:**
```json
{
  "success": true,
  "patientId": "PAT123456789",
  "patientEmail": "patient@example.com",
  "current_pregnancy_week": 20,
  "pregnancy_info": {
    "current_week": 20,
    "expected_delivery": "2025-06-15",
    "days_until_delivery": 140
  },
  "auto_fetched": true,
  "timestamp": "2025-10-07T10:30:00"
}
```

---

### AI-Powered Insights

All AI-powered endpoints require OpenAI service to be available.

#### 5. Get Baby Size (AI)
Get AI-powered baby size information for a specific week.

**Endpoint:** `GET /api/pregnancy/week/{week}/baby-size`  
**Authentication:** Required  
**Parameters:**
- `week` (path parameter, integer, 1-40): Pregnancy week number

**Response:**
```json
{
  "success": true,
  "week": 20,
  "data": {
    "size_cm": 16.4,
    "weight_grams": 300,
    "comparison": "Banana",
    "description": "Your baby is about the size of a banana...",
    "development_highlights": [
      "Baby can hear sounds",
      "Practicing swallowing",
      "Growing hair"
    ]
  }
}
```

---

#### 6. Get Baby Size Image
Get baby size visualization image for a specific week.

**Endpoint:** `GET /api/pregnancy/week/{week}/baby-image`  
**Authentication:** Required  
**Parameters:**
- `week` (path parameter, integer, 1-40): Pregnancy week number
- `style` (query parameter, string, optional): Image style (default: "matplotlib")

**Response:**
```json
{
  "success": true,
  "week": 20,
  "image_url": "data:image/png;base64,iVBORw0KG...",
  "format": "base64",
  "style": "matplotlib"
}
```

---

#### 7. Get Early Symptoms (AI)
Get AI-powered early symptoms information for a specific week.

**Endpoint:** `GET /api/pregnancy/week/{week}/symptoms`  
**Authentication:** Required  
**Parameters:**
- `week` (path parameter, integer, 1-40): Pregnancy week number

**Response:**
```json
{
  "success": true,
  "week": 8,
  "data": {
    "common_symptoms": [
      {
        "symptom": "Morning sickness",
        "severity": "moderate",
        "frequency": "common",
        "relief_tips": ["Eat small frequent meals", "Stay hydrated"]
      },
      {
        "symptom": "Fatigue",
        "severity": "high",
        "frequency": "very common",
        "relief_tips": ["Rest when possible", "Light exercise"]
      }
    ],
    "red_flags": ["Severe bleeding", "Severe abdominal pain"],
    "when_to_call_doctor": "If you experience any red flag symptoms"
  }
}
```

---

#### 8. Get Prenatal Screening (AI)
Get AI-powered prenatal screening information for a specific week.

**Endpoint:** `GET /api/pregnancy/week/{week}/screening`  
**Authentication:** Required  
**Parameters:**
- `week` (path parameter, integer, 1-40): Pregnancy week number

**Response:**
```json
{
  "success": true,
  "week": 12,
  "data": {
    "recommended_tests": [
      {
        "test_name": "First Trimester Screening",
        "description": "Blood test and ultrasound to check for chromosomal abnormalities",
        "timing": "11-14 weeks",
        "importance": "high"
      },
      {
        "test_name": "NT Scan",
        "description": "Nuchal translucency scan",
        "timing": "11-13 weeks",
        "importance": "high"
      }
    ],
    "upcoming_tests": ["Quadruple screen at 15-20 weeks"]
  }
}
```

---

#### 9. Get Wellness Tips (AI)
Get AI-powered wellness tips for a specific week.

**Endpoint:** `GET /api/pregnancy/week/{week}/wellness`  
**Authentication:** Required  
**Parameters:**
- `week` (path parameter, integer, 1-40): Pregnancy week number

**Response:**
```json
{
  "success": true,
  "week": 15,
  "data": {
    "physical_wellness": [
      "Continue prenatal exercise",
      "Practice pelvic floor exercises",
      "Maintain good posture"
    ],
    "mental_wellness": [
      "Practice relaxation techniques",
      "Connect with other expectant mothers",
      "Get adequate sleep"
    ],
    "self_care": [
      "Pamper yourself",
      "Take short walks",
      "Read pregnancy books"
    ]
  }
}
```

---

#### 10. Get Nutrition Tips (AI)
Get AI-powered nutrition tips for a specific week.

**Endpoint:** `GET /api/pregnancy/week/{week}/nutrition`  
**Authentication:** Required  
**Parameters:**
- `week` (path parameter, integer, 1-40): Pregnancy week number

**Response:**
```json
{
  "success": true,
  "week": 18,
  "data": {
    "recommended_foods": [
      {
        "food": "Leafy greens",
        "benefit": "Rich in folate and iron",
        "serving": "2-3 cups daily"
      },
      {
        "food": "Fatty fish",
        "benefit": "Omega-3 for baby brain development",
        "serving": "2 servings per week"
      }
    ],
    "foods_to_avoid": [
      "Raw fish",
      "Unpasteurized cheese",
      "High-mercury fish"
    ],
    "supplements": [
      "Prenatal vitamin",
      "Folic acid (400-800 mcg)",
      "Vitamin D"
    ],
    "hydration": "Drink 8-10 glasses of water daily"
  }
}
```

---

### Pregnancy Tracking & History

#### 11. Save Pregnancy Tracking
Save pregnancy tracking data including weight, symptoms, mood, and baby movements.

**Endpoint:** `POST /api/pregnancy/tracking`  
**Authentication:** Required  
**Request Body:**
```json
{
  "week": 20,
  "weight": 65.5,
  "blood_pressure": "120/80",
  "symptoms": ["back pain", "fatigue"],
  "notes": "Feeling better this week",
  "mood": "happy",
  "energy_level": "medium",
  "baby_movements": true,
  "baby_kicks_count": 15,
  "date": "2025-10-07"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Pregnancy tracking data saved successfully",
  "data": {
    "tracking_id": "TRK123456",
    "patient_id": "PAT123456789",
    "week": 20,
    "date": "2025-10-07",
    "created_at": "2025-10-07T10:30:00"
  }
}
```

---

#### 12. Get Pregnancy Tracking History
Get complete pregnancy tracking history for the authenticated patient.

**Endpoint:** `GET /api/pregnancy/tracking/history`  
**Authentication:** Required

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "tracking_id": "TRK123456",
      "week": 20,
      "weight": 65.5,
      "blood_pressure": "120/80",
      "symptoms": ["back pain", "fatigue"],
      "notes": "Feeling better this week",
      "mood": "happy",
      "energy_level": "medium",
      "baby_movements": true,
      "baby_kicks_count": 15,
      "date": "2025-10-07",
      "created_at": "2025-10-07T10:30:00"
    }
  ],
  "total_count": 10,
  "patient_id": "PAT123456789"
}
```

---

#### 13. Calculate Pregnancy Progress
Calculate pregnancy progress including trimester, days remaining, percentage complete, etc.

**Endpoint:** `GET /api/pregnancy/progress`  
**Authentication:** Required  
**Query Parameters:**
- `week` (optional, integer, default: 1): Current pregnancy week

**Response:**
```json
{
  "success": true,
  "data": {
    "current_week": 25,
    "trimester": 2,
    "total_weeks": 40,
    "weeks_remaining": 15,
    "days_elapsed": 175,
    "days_remaining": 105,
    "percentage_complete": 62.5,
    "expected_delivery_date": "2025-06-15",
    "milestones": {
      "next_trimester": "Week 28",
      "viability": "Reached at week 24",
      "full_term": "Week 37"
    }
  },
  "message": "Pregnancy progress calculated successfully"
}
```

---

### Pregnancy Week Management

#### 14. Update Pregnancy Week
Manually update pregnancy week for a specific patient. Auto-calculates based on last period date.

**Endpoint:** `POST /api/pregnancy/update-week/{patient_id}`  
**Authentication:** Required  
**Parameters:**
- `patient_id` (path parameter, string): Patient ID

**Requirements:**
- Patient must be marked as `is_pregnant: true`
- Patient must have `last_period_date` set

**Response:**
```json
{
  "success": true,
  "message": "Pregnancy week updated to 20",
  "pregnancy_info": {
    "current_week": 20,
    "expected_delivery": "2025-06-15",
    "days_until_delivery": 140,
    "last_updated": "2025-10-07T10:30:00"
  },
  "patient_id": "PAT123456789"
}
```

**Error Response (Patient not pregnant):**
```json
{
  "error": "Patient is not marked as pregnant"
}
```

**Error Response (Missing last period date):**
```json
{
  "error": "Patient is missing last period date"
}
```

---

### Service Status

#### 15. Check OpenAI Status
Check if OpenAI service is available for AI-powered features.

**Endpoint:** `GET /api/pregnancy/openai/status`  
**Authentication:** Required

**Response:**
```json
{
  "success": true,
  "openai_available": true,
  "features_enabled": [
    "baby_size",
    "symptoms",
    "screening",
    "wellness",
    "nutrition"
  ],
  "message": "OpenAI service is available"
}
```

---

## Error Handling

### Common Error Responses

#### 400 Bad Request
```json
{
  "success": false,
  "message": "Week must be between 1 and 40"
}
```

#### 401 Unauthorized
```json
{
  "error": "Token is missing or invalid"
}
```

#### 404 Not Found
```json
{
  "error": "Patient not found"
}
```

#### 500 Internal Server Error
```json
{
  "success": false,
  "message": "Error: Database connection failed"
}
```

---

## Integration Guide

### Flutter Integration Example

```dart
// 1. Get current pregnancy week
Future<Map<String, dynamic>> getCurrentPregnancyWeek(String patientId) async {
  final response = await http.get(
    Uri.parse('$baseUrl/get-current-pregnancy-week/$patientId'),
  );
  
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load pregnancy week');
  }
}

// 2. Save tracking data
Future<Map<String, dynamic>> saveTrackingData(Map<String, dynamic> data) async {
  final response = await http.post(
    Uri.parse('$baseUrl/api/pregnancy/tracking'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: json.encode(data),
  );
  
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to save tracking data');
  }
}

// 3. Get week information
Future<Map<String, dynamic>> getWeekInfo(int week) async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/pregnancy/week/$week'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );
  
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load week information');
  }
}

// 4. Get tracking history
Future<List<dynamic>> getTrackingHistory() async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/pregnancy/tracking/history'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );
  
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['data'] ?? [];
  } else {
    throw Exception('Failed to load tracking history');
  }
}
```

### React/JavaScript Integration Example

```javascript
// Pregnancy Tracking Service
class PregnancyTrackingService {
  constructor(baseUrl, token) {
    this.baseUrl = baseUrl;
    this.token = token;
  }

  // Get current pregnancy week
  async getCurrentWeek(patientId) {
    const response = await fetch(
      `${this.baseUrl}/get-current-pregnancy-week/${patientId}`
    );
    return await response.json();
  }

  // Get week information
  async getWeekInfo(week) {
    const response = await fetch(
      `${this.baseUrl}/api/pregnancy/week/${week}`,
      {
        headers: {
          'Authorization': `Bearer ${this.token}`
        }
      }
    );
    return await response.json();
  }

  // Save tracking data
  async saveTracking(data) {
    const response = await fetch(
      `${this.baseUrl}/api/pregnancy/tracking`,
      {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${this.token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(data)
      }
    );
    return await response.json();
  }

  // Get tracking history
  async getTrackingHistory() {
    const response = await fetch(
      `${this.baseUrl}/api/pregnancy/tracking/history`,
      {
        headers: {
          'Authorization': `Bearer ${this.token}`
        }
      }
    );
    return await response.json();
  }

  // Get AI-powered baby size
  async getBabySize(week) {
    const response = await fetch(
      `${this.baseUrl}/api/pregnancy/week/${week}/baby-size`,
      {
        headers: {
          'Authorization': `Bearer ${this.token}`
        }
      }
    );
    return await response.json();
  }

  // Get pregnancy progress
  async getProgress(week) {
    const response = await fetch(
      `${this.baseUrl}/api/pregnancy/progress?week=${week}`,
      {
        headers: {
          'Authorization': `Bearer ${this.token}`
        }
      }
    );
    return await response.json();
  }
}

// Usage
const service = new PregnancyTrackingService('http://localhost:8000', 'your_token');

// Get current week
const currentWeek = await service.getCurrentWeek('PAT123456789');
console.log(`Current week: ${currentWeek.current_pregnancy_week}`);

// Save tracking data
const trackingData = {
  week: 20,
  weight: 65.5,
  symptoms: ['back pain'],
  mood: 'happy',
  baby_kicks_count: 15
};
await service.saveTracking(trackingData);

// Get week information
const weekInfo = await service.getWeekInfo(20);
console.log(weekInfo);
```

---

## Testing with Postman

1. **Import the collection:** Import `Pregnancy_Tracking_Module.postman_collection.json`
2. **Set variables:**
   - `base_url`: `http://localhost:8000`
   - `access_token`: Your JWT token from login
   - `patient_id`: Your patient ID
3. **Run requests:** Test each endpoint in the collection
4. **Check responses:** Verify the response format and data

---

## Summary

The Pregnancy Tracking Module provides:

✅ **15 API endpoints** covering all pregnancy tracking needs  
✅ **4 categories:** Week Information, AI Insights, Tracking, Management  
✅ **AI-powered features** for personalized insights  
✅ **Automatic calculations** for pregnancy week and progress  
✅ **Complete history** tracking with detailed analytics  
✅ **Easy integration** with Flutter, React, and other frameworks  

For support or questions, please contact the development team.


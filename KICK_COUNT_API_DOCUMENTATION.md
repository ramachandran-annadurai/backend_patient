# 🦵 Kick Count API Documentation

## Overview
The Kick Count API provides endpoints for tracking fetal movement during pregnancy, specifically designed for Trimester 3 monitoring. This system allows patients to record kick sessions and retrieve their kick history.

## 📋 API Endpoints

### 1. Save Kick Session
**Endpoint:** `POST /save-kick-session`  
**Description:** Save a kick counting session for a patient  
**Authentication:** Not required (uses patient ID)

#### Request Structure
```json
{
  "userId": "PAT1759141374B65D62",
  "userRole": "patient",
  "kickCount": 15,
  "sessionDuration": 30,
  "sessionStartTime": "2024-01-15T10:00:00Z",
  "sessionEndTime": "2024-01-15T10:30:00Z",
  "averageKicksPerMinute": 0.5,
  "notes": "Baby was very active this morning",
  "timestamp": "2024-01-15T10:30:00Z"
}
```

#### Request Fields
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `userId` | string | ✅ | Patient ID (format: PAT...) |
| `userRole` | string | ✅ | User role (should be "patient") |
| `kickCount` | number | ✅ | Number of kicks counted |
| `sessionDuration` | number | ✅ | Session duration in minutes |
| `sessionStartTime` | string | ❌ | ISO timestamp when session started |
| `sessionEndTime` | string | ❌ | ISO timestamp when session ended |
| `averageKicksPerMinute` | number | ❌ | Calculated average kicks per minute |
| `notes` | string | ❌ | Additional notes about the session |
| `timestamp` | string | ❌ | ISO timestamp (defaults to current time) |

#### Success Response (200)
```json
{
  "success": true,
  "message": "Kick session saved successfully to patient profile",
  "patientId": "PAT1759141374B65D62",
  "patientEmail": "patient@example.com",
  "kickSessionsCount": 5
}
```

#### Error Responses
**400 - Missing Required Field:**
```json
{
  "success": false,
  "message": "Missing required field: kickCount"
}
```

**400 - Patient ID Required:**
```json
{
  "success": false,
  "message": "Patient ID is required for precise patient linking. Please ensure you are logged in.",
  "debug_info": {
    "received_userId": null,
    "received_data": {...}
  }
}
```

**404 - Patient Not Found:**
```json
{
  "success": false,
  "message": "Patient not found with ID: PAT1759141374B65D62"
}
```

**500 - Server Error:**
```json
{
  "success": false,
  "message": "Error: [error details]"
}
```

---

### 2. Get Kick History
**Endpoint:** `GET /get-kick-history/<patient_id>`  
**Description:** Retrieve kick counting history for a specific patient  
**Authentication:** Not required (uses patient ID in URL)

#### URL Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `patient_id` | string | ✅ | Patient ID (format: PAT...) |

#### Success Response (200)
```json
{
  "success": true,
  "patientId": "PAT1759141374B65D62",
  "kick_logs": [
    {
      "kickCount": 15,
      "sessionDuration": 30,
      "sessionStartTime": "2024-01-15T10:00:00Z",
      "sessionEndTime": "2024-01-15T10:30:00Z",
      "averageKicksPerMinute": 0.5,
      "notes": "Baby was very active this morning",
      "timestamp": "2024-01-15T10:30:00Z",
      "createdAt": "2024-01-15T10:30:00.000Z"
    },
    {
      "kickCount": 12,
      "sessionDuration": 25,
      "sessionStartTime": "2024-01-14T14:00:00Z",
      "sessionEndTime": "2024-01-14T14:25:00Z",
      "averageKicksPerMinute": 0.48,
      "notes": "Evening session",
      "timestamp": "2024-01-14T14:25:00Z",
      "createdAt": "2024-01-14T14:25:00.000Z"
    }
  ],
  "totalSessions": 2
}
```

#### Error Responses
**404 - Patient Not Found:**
```json
{
  "success": false,
  "message": "Patient not found with ID: PAT1759141374B65D62"
}
```

**500 - Server Error:**
```json
{
  "success": false,
  "message": "Error: [error details]"
}
```

---

### 3. Get Kick Counter Guide
**Endpoint:** `GET /api/pregnancy/trimester-3/kick-counter`  
**Description:** Get guidance and instructions for kick counting in Trimester 3  
**Authentication:** Required (JWT token)

#### Headers
```
Authorization: Bearer <jwt_token>
```

#### Success Response (200)
```json
{
  "success": true,
  "trimester": 3,
  "action": "kick-counter",
  "title": "Kick Counter",
  "description": "Track your baby's movements and patterns",
  "features": [
    "When to feel kicks",
    "Patterns", 
    "Counting",
    "Concerns"
  ],
  "guidance": "Detailed kick counting instructions and tips...",
  "endpoint": "/api/pregnancy/trimester-3/kick-counter"
}
```

#### Error Responses
**401 - Unauthorized:**
```json
{
  "success": false,
  "message": "Token is missing or invalid"
}
```

**500 - Server Error:**
```json
{
  "success": false,
  "error": "Error getting kick counter guide: [error details]"
}
```

---

## 📊 Data Storage

### Database Structure
Kick count data is stored in the `patients_collection` MongoDB collection within each patient document:

```json
{
  "_id": "ObjectId",
  "patient_id": "PAT1759141374B65D62",
  "username": "patient_username",
  "email": "patient@example.com",
  "kick_count_logs": [
    {
      "kickCount": 15,
      "sessionDuration": 30,
      "sessionStartTime": "2024-01-15T10:00:00Z",
      "sessionEndTime": "2024-01-15T10:30:00Z",
      "averageKicksPerMinute": 0.5,
      "notes": "Baby was very active this morning",
      "timestamp": "2024-01-15T10:30:00Z",
      "createdAt": "2024-01-15T10:30:00.000Z"
    }
  ],
  "last_updated": "2024-01-15T10:30:00.000Z"
}
```

## 🔧 Usage Examples

### Example 1: Save a Kick Session
```bash
curl -X POST http://localhost:5000/save-kick-session \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "PAT1759141374B65D62",
    "userRole": "patient",
    "kickCount": 15,
    "sessionDuration": 30,
    "sessionStartTime": "2024-01-15T10:00:00Z",
    "sessionEndTime": "2024-01-15T10:30:00Z",
    "averageKicksPerMinute": 0.5,
    "notes": "Baby was very active this morning"
  }'
```

### Example 2: Get Kick History
```bash
curl -X GET http://localhost:5000/get-kick-history/PAT1759141374B65D62
```

### Example 3: Get Kick Counter Guide
```bash
curl -X GET http://localhost:5000/api/pregnancy/trimester-3/kick-counter \
  -H "Authorization: Bearer <jwt_token>"
```

## 📝 Notes

1. **Patient ID Format:** All patient IDs follow the format `PAT` followed by alphanumeric characters
2. **Timestamps:** All timestamps are in ISO 8601 format
3. **Session Duration:** Measured in minutes
4. **Kick Count:** Should be a positive integer
5. **Data Persistence:** Kick sessions are permanently stored in the patient's profile
6. **Activity Logging:** All kick sessions are logged for audit purposes

## 🚨 Important Considerations

- Kick counting is most relevant during Trimester 3 (weeks 28-40)
- Patients should count kicks during their baby's most active times
- A normal kick count is typically 10+ movements in 2 hours
- Any concerns about decreased fetal movement should be reported to healthcare providers immediately




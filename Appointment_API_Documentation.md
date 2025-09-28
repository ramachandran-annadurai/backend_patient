# Complete Appointment API Documentation

## Overview
This document provides comprehensive documentation for the Appointment API with detailed success and failure responses for all endpoints.

## Base URL
```
http://localhost:8000
```

## Authentication
All endpoints require JWT authentication via Bearer token in the Authorization header.

## Endpoints

### 1. Authentication

#### POST /login
**Description:** Login to get JWT token

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
  "message": "Login successful"
}
```

**Failure Response (401):**
```json
{
  "error": "Invalid credentials"
}
```

---

### 2. Doctor Appointments

#### GET /doctor/appointments
**Description:** Get all appointments with optional filtering

**Query Parameters:**
- `patient_id` (optional): Filter by patient ID
- `date` (optional): Filter by date (YYYY-MM-DD)
- `status` (optional): Filter by status (default: "active")

**Success Response (200):**
```json
{
  "appointments": [
    {
      "appointment_id": "APT987654321",
      "appointment_date": "2025-09-28",
      "appointment_time": "2:00 PM",
      "appointment_type": "Follow-up",
      "appointment_status": "scheduled",
      "notes": "Follow-up appointment",
      "doctor_id": "DOC123",
      "created_at": "2025-01-27T10:30:00.000Z",
      "updated_at": "2025-01-27T10:30:00.000Z",
      "status": "active",
      "patient_id": "PAT123",
      "patient_name": "John Doe"
    }
  ],
  "total_count": 1,
  "message": "Appointments retrieved successfully"
}
```

**No Appointments Found (200):**
```json
{
  "appointments": [],
  "total_count": 0,
  "message": "Appointments retrieved successfully"
}
```

**Unauthorized (401):**
```json
{
  "error": "Token is missing or invalid"
}
```

#### POST /doctor/appointments
**Description:** Create a new appointment

**Request:**
```json
{
  "patient_id": "PAT123",
  "appointment_date": "2025-09-28",
  "appointment_time": "2:00 PM",
  "appointment_type": "Follow-up",
  "notes": "Follow-up appointment",
  "doctor_id": "DOC123"
}
```

**Success Response (201):**
```json
{
  "appointment_id": "APT987654321",
  "message": "Appointment created successfully"
}
```

**Missing Required Fields (400):**
```json
{
  "error": "appointment_time is required"
}
```

**Patient Not Found (404):**
```json
{
  "error": "Patient not found"
}
```

#### PUT /doctor/appointments/{appointment_id}
**Description:** Update an existing appointment

**Request:**
```json
{
  "appointment_date": "2025-09-29",
  "appointment_time": "3:00 PM",
  "appointment_type": "Consultation",
  "appointment_status": "confirmed",
  "notes": "Updated appointment details"
}
```

**Success Response (200):**
```json
{
  "message": "Appointment updated successfully"
}
```

**Appointment Not Found (404):**
```json
{
  "error": "Appointment not found"
}
```

#### DELETE /doctor/appointments/{appointment_id}
**Description:** Delete an appointment (hard delete)

**Success Response (200):**
```json
{
  "message": "Appointment deleted successfully"
}
```

**Appointment Not Found (404):**
```json
{
  "error": "Appointment not found"
}
```

---

### 3. Patient Appointments

#### GET /patient/appointments
**Description:** Get patient's appointments with optional filtering

**Query Parameters:**
- `date` (optional): Filter by date (YYYY-MM-DD)
- `status` (optional): Filter by status (default: "active")
- `appointment_type` (optional): Filter by appointment type

**Success Response (200):**
```json
{
  "appointments": [
    {
      "appointment_id": "APT987654321",
      "appointment_date": "2025-09-28",
      "appointment_time": "2:00 PM",
      "appointment_type": "Follow-up",
      "appointment_status": "scheduled",
      "notes": "Follow-up appointment",
      "patient_notes": "I have some concerns about my medication",
      "doctor_id": "DOC123",
      "created_at": "2025-01-27T10:30:00.000Z",
      "updated_at": "2025-01-27T10:30:00.000Z",
      "status": "active",
      "requested_by": "patient",
      "patient_id": "PAT123",
      "patient_name": "John Doe"
    }
  ],
  "total_count": 1,
  "patient_id": "PAT123",
  "message": "Appointments retrieved successfully"
}
```

**No Appointments Found (200):**
```json
{
  "appointments": [],
  "total_count": 0,
  "patient_id": "PAT123",
  "message": "Appointments retrieved successfully"
}
```

#### POST /patient/appointments
**Description:** Create an appointment request

**Request:**
```json
{
  "appointment_date": "2025-09-28",
  "appointment_time": "2:00 PM",
  "appointment_type": "Follow-up",
  "notes": "Follow-up appointment",
  "patient_notes": "I have some concerns about my medication",
  "doctor_id": "DOC123"
}
```

**Success Response (201):**
```json
{
  "appointment_id": "APT987654321",
  "message": "Appointment request created successfully",
  "status": "pending"
}
```

**Missing Required Fields (400):**
```json
{
  "error": "appointment_time is required"
}
```

#### GET /patient/appointments/{appointment_id}
**Description:** Get specific appointment details

**Success Response (200):**
```json
{
  "appointment": {
    "appointment_id": "APT987654321",
    "appointment_date": "2025-09-28",
    "appointment_time": "2:00 PM",
    "appointment_type": "Follow-up",
    "appointment_status": "scheduled",
    "notes": "Follow-up appointment",
    "patient_notes": "I have some concerns about my medication",
    "doctor_id": "DOC123",
    "created_at": "2025-01-27T10:30:00.000Z",
    "updated_at": "2025-01-27T10:30:00.000Z",
    "status": "active",
    "requested_by": "patient",
    "patient_id": "PAT123",
    "patient_name": "John Doe"
  },
  "message": "Appointment retrieved successfully"
}
```

**Appointment Not Found (404):**
```json
{
  "error": "Appointment not found"
}
```

#### PUT /patient/appointments/{appointment_id}
**Description:** Update patient's appointment

**Request:**
```json
{
  "appointment_date": "2025-09-29",
  "appointment_time": "3:00 PM",
  "appointment_type": "Consultation",
  "patient_notes": "Updated my concerns about medication"
}
```

**Success Response (200):**
```json
{
  "message": "Appointment updated successfully"
}
```

**Access Denied (404):**
```json
{
  "error": "Appointment not found or access denied"
}
```

#### DELETE /patient/appointments/{appointment_id}
**Description:** Cancel patient's appointment

**Success Response (200):**
```json
{
  "message": "Appointment cancelled successfully"
}
```

**Appointment Not Found (404):**
```json
{
  "error": "Appointment not found or access denied"
}
```

#### GET /patient/appointments/upcoming
**Description:** Get upcoming appointments

**Success Response (200):**
```json
{
  "upcoming_appointments": [
    {
      "appointment_id": "APT987654321",
      "appointment_date": "2025-09-28",
      "appointment_time": "2:00 PM",
      "appointment_type": "Follow-up",
      "appointment_status": "scheduled",
      "notes": "Follow-up appointment",
      "patient_notes": "I have some concerns about my medication",
      "doctor_id": "DOC123",
      "created_at": "2025-01-27T10:30:00.000Z",
      "updated_at": "2025-01-27T10:30:00.000Z",
      "status": "active",
      "requested_by": "patient",
      "patient_id": "PAT123",
      "patient_name": "John Doe"
    }
  ],
  "total_count": 1,
  "patient_id": "PAT123",
  "message": "Upcoming appointments retrieved successfully"
}
```

#### GET /patient/appointments/history
**Description:** Get appointment history

**Success Response (200):**
```json
{
  "appointment_history": [
    {
      "appointment_id": "APT123456789",
      "appointment_date": "2025-01-15",
      "appointment_time": "10:00 AM",
      "appointment_type": "Initial Consultation",
      "appointment_status": "completed",
      "notes": "Initial consultation completed",
      "patient_notes": "First visit",
      "doctor_id": "DOC123",
      "created_at": "2025-01-10T09:00:00.000Z",
      "updated_at": "2025-01-15T10:30:00.000Z",
      "status": "active",
      "requested_by": "doctor",
      "patient_id": "PAT123",
      "patient_name": "John Doe"
    }
  ],
  "total_count": 1,
  "patient_id": "PAT123",
  "message": "Appointment history retrieved successfully"
}
```

---

## Common Error Responses

### 400 Bad Request
```json
{
  "error": "Field is required"
}
```

### 401 Unauthorized
```json
{
  "error": "Token is missing or invalid"
}
```

### 404 Not Found
```json
{
  "error": "Resource not found"
}
```

### 500 Internal Server Error
```json
{
  "error": "Database not connected"
}
```

---

## Appointment Status Values

- `pending` - Appointment request pending approval
- `scheduled` - Appointment confirmed and scheduled
- `confirmed` - Appointment confirmed by doctor
- `completed` - Appointment completed
- `cancelled` - Appointment cancelled
- `no_show` - Patient did not show up

## Appointment Types

- `General` - General consultation
- `Follow-up` - Follow-up appointment
- `Consultation` - Consultation appointment
- `Emergency` - Emergency appointment
- `Check-up` - Regular check-up
- `Specialist` - Specialist consultation

## Postman Collection

Import the `Complete_Appointment_API.postman_collection.json` file into Postman to test all endpoints with pre-configured requests and responses.

## Testing

1. Import the Postman collection
2. Set the `base_url` variable to your server URL
3. Run the login request to get a JWT token
4. Use the token for authenticated requests
5. Test all endpoints with various scenarios

The collection includes both success and failure response examples for comprehensive testing.

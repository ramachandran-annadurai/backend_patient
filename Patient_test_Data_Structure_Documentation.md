# Patient_test Collection Data Structure Documentation

## Overview
The `Patient_test` collection in MongoDB stores comprehensive patient data for a pregnancy tracking application. This document outlines the complete data structure and storage patterns used in the system.

## Collection Name
- **Database**: `patients_db`
- **Collection**: `Patient_test`

## Document Structure

### Core Patient Information
```json
{
  "_id": "ObjectId('507f1f77bcf86cd799439011')",
  "patient_id": "PAT1759141374B65D62",
  "first_name": "John",
  "last_name": "Doe",
  "email": "john.doe@example.com",
  "mobile": "+1234567890",
  "username": "johndoe",
  "password_hash": "$2b$12$...",
  "date_of_birth": "1990-01-15",
  "gender": "male"
}
```

### Address Information
```json
{
  "address": {
    "street": "123 Main St",
    "city": "New York",
    "state": "NY",
    "zip_code": "10001",
    "country": "USA"
  }
}
```

### Emergency Contact
```json
{
  "emergency_contact": {
    "name": "Jane Doe",
    "relationship": "Spouse",
    "phone": "+1234567891",
    "email": "jane.doe@example.com"
  }
}
```

### Medical Information
```json
{
  "medical_info": {
    "blood_type": "O+",
    "allergies": ["Peanuts", "Penicillin"],
    "chronic_conditions": ["Diabetes Type 2"],
    "current_medications": [
      {
        "name": "Metformin",
        "dosage": "500mg",
        "frequency": "twice daily"
      }
    ],
    "pregnancy_week": 24,
    "due_date": "2024-06-15",
    "height_cm": 175,
    "weight_kg": 70,
    "bmi": 22.9
  }
}
```

### Insurance Information
```json
{
  "insurance_info": {
    "provider": "Blue Cross Blue Shield",
    "policy_number": "BC123456789",
    "group_number": "GRP001",
    "expiry_date": "2024-12-31"
  }
}
```

## Array-Based Data Storage

### 1. Appointments Array
Stores all patient appointments in an array within the patient document.

```json
{
  "appointments": [
    {
      "appointment_id": "APT001",
      "appointment_date": "2024-10-15",
      "appointment_time": "10:00",
      "appointment_type": "Prenatal Checkup",
      "appointment_status": "confirmed",
      "notes": "Regular prenatal checkup",
      "patient_notes": "Feeling good, no concerns",
      "doctor_id": "DOC001",
      "doctor_name": "Dr. Sarah Johnson",
      "created_at": "2024-09-15T09:00:00Z",
      "updated_at": "2024-09-15T09:00:00Z",
      "status": "active",
      "requested_by": "patient"
    }
  ]
}
```

**Appointment Status Values:**
- `pending` - Appointment requested but not confirmed
- `confirmed` - Appointment confirmed by doctor
- `completed` - Appointment completed
- `cancelled` - Appointment cancelled
- `no_show` - Patient didn't show up

### 2. Hydration Records Array
Stores hydration intake data in an array within the patient document.

```json
{
  "hydration_records": [
    {
      "hydration_id": "HYD001",
      "patient_id": "PAT1759141374B65D62",
      "hydration_type": "water",
      "amount_ml": 250.0,
      "amount_oz": 8.45,
      "notes": "Morning water",
      "temperature": "room_temperature",
      "additives": [],
      "timestamp": "2024-09-30T08:00:00Z",
      "created_at": "2024-09-30T08:00:00Z",
      "updated_at": "2024-09-30T08:00:00Z"
    }
  ]
}
```

**Hydration Types:**
- `water` - Plain water
- `herbal_tea` - Herbal teas
- `juice` - Fruit juices
- `smoothie` - Smoothies
- `sports_drink` - Sports drinks
- `other` - Other beverages

### 3. Hydration Goal Object
Stores hydration goals as a single object within the patient document.

```json
{
  "hydration_goal": {
    "daily_goal_ml": 2500,
    "daily_goal_oz": 84.5,
    "reminder_frequency": "every_2_hours",
    "reminder_times": ["08:00", "10:00", "12:00", "14:00", "16:00", "18:00", "20:00"],
    "is_active": true,
    "created_at": "2024-09-01T00:00:00Z",
    "updated_at": "2024-09-30T15:30:00Z"
  }
}
```

### 4. Hydration Reminders Array
Stores hydration reminders in an array within the patient document.

```json
{
  "hydration_reminders": [
    {
      "reminder_id": "REM001",
      "reminder_time": "08:00",
      "message": "Good morning! Don't forget to drink water to start your day hydrated.",
      "is_active": true,
      "created_at": "2024-09-01T00:00:00Z"
    }
  ]
}
```

### 5. Vital Signs Array
Stores vital signs measurements in an array within the patient document.

```json
{
  "vital_signs": [
    {
      "vital_id": "VIT001",
      "patient_id": "PAT1759141374B65D62",
      "blood_pressure_systolic": 120,
      "blood_pressure_diastolic": 80,
      "heart_rate": 72,
      "temperature": 98.6,
      "weight": 70.5,
      "notes": "Regular checkup",
      "timestamp": "2024-09-30T10:00:00Z",
      "created_at": "2024-09-30T10:00:00Z"
    }
  ]
}
```

### 6. Medication Logs Array
Stores medication intake records in an array within the patient document.

```json
{
  "medication_logs": [
    {
      "medication_id": "MED001",
      "patient_id": "PAT1759141374B65D62",
      "medication_name": "Prenatal Vitamins",
      "dosage": "1 tablet",
      "frequency": "daily",
      "taken_at": "2024-09-30T08:00:00Z",
      "notes": "With breakfast",
      "created_at": "2024-09-30T08:00:00Z"
    }
  ]
}
```

### 7. Symptoms Logs Array
Stores symptom tracking data in an array within the patient document.

```json
{
  "symptoms_logs": [
    {
      "symptom_id": "SYM001",
      "patient_id": "PAT1759141374B65D62",
      "symptom_type": "nausea",
      "severity": "mild",
      "description": "Morning sickness",
      "duration": "30 minutes",
      "timestamp": "2024-09-30T07:30:00Z",
      "created_at": "2024-09-30T07:30:00Z"
    }
  ]
}
```

### 8. Mental Health Logs Array
Stores mental health assessment data in an array within the patient document.

```json
{
  "mental_health_logs": [
    {
      "assessment_id": "MH001",
      "patient_id": "PAT1759141374B65D62",
      "mood_score": 7,
      "anxiety_level": 3,
      "stress_level": 4,
      "sleep_quality": 8,
      "energy_level": 6,
      "notes": "Feeling good overall",
      "timestamp": "2024-09-30T20:00:00Z",
      "created_at": "2024-09-30T20:00:00Z"
    }
  ]
}
```

### 9. Nutrition Logs Array
Stores food intake and nutrition data in an array within the patient document.

```json
{
  "nutrition_logs": [
    {
      "food_entry_id": "NUT001",
      "patient_id": "PAT1759141374B65D62",
      "food_name": "Grilled Chicken Salad",
      "calories": 350,
      "protein": 25,
      "carbs": 15,
      "fat": 20,
      "meal_type": "lunch",
      "timestamp": "2024-09-30T12:30:00Z",
      "created_at": "2024-09-30T12:30:00Z"
    }
  ]
}
```

### 10. Pregnancy Tracking Object
Stores pregnancy-specific information as a single object within the patient document.

```json
{
  "pregnancy_tracking": {
    "current_week": 24,
    "due_date": "2024-06-15",
    "conception_date": "2024-01-01",
    "last_menstrual_period": "2023-12-15",
    "baby_gender": "unknown",
    "pregnancy_notes": "Healthy pregnancy so far",
    "weight_gain": 8.5,
    "belly_measurement": 32.5
  }
}
```

### 11. Notifications Array
Stores system notifications in an array within the patient document.

```json
{
  "notifications": [
    {
      "notification_id": "NOT001",
      "type": "appointment_reminder",
      "title": "Appointment Tomorrow",
      "message": "You have a prenatal checkup tomorrow at 10:00 AM",
      "is_read": false,
      "created_at": "2024-09-29T18:00:00Z"
    }
  ]
}
```

### 12. Settings Object
Stores user preferences and settings as a single object within the patient document.

```json
{
  "settings": {
    "notifications_enabled": true,
    "email_notifications": true,
    "sms_notifications": true,
    "push_notifications": true,
    "language": "en",
    "timezone": "America/New_York",
    "theme": "light"
  }
}
```

### 13. Activity Log Array
Stores user activity and system logs in an array within the patient document.

```json
{
  "activity_log": [
    {
      "activity_id": "ACT001",
      "action": "login",
      "timestamp": "2024-09-30T14:45:00Z",
      "ip_address": "192.168.1.100",
      "user_agent": "Mozilla/5.0..."
    }
  ]
}
```

## Data Storage Patterns

### 1. Array-Based Storage
- **Appointments**: Stored as array of appointment objects
- **Hydration Records**: Stored as array of hydration intake objects
- **Vital Signs**: Stored as array of vital signs measurements
- **Medication Logs**: Stored as array of medication intake records
- **Symptoms Logs**: Stored as array of symptom tracking data
- **Mental Health Logs**: Stored as array of mental health assessments
- **Nutrition Logs**: Stored as array of food intake records
- **Notifications**: Stored as array of notification objects
- **Activity Log**: Stored as array of activity records

### 2. Object-Based Storage
- **Address**: Single object with address fields
- **Emergency Contact**: Single object with contact information
- **Medical Info**: Single object with medical information
- **Insurance Info**: Single object with insurance details
- **Hydration Goal**: Single object with hydration goals
- **Pregnancy Tracking**: Single object with pregnancy information
- **Settings**: Single object with user preferences

### 3. MongoDB Operations

#### Adding Data to Arrays
```javascript
// Add appointment to appointments array
db.Patient_test.updateOne(
  {"patient_id": "PAT1759141374B65D62"},
  {"$push": {"appointments": appointmentObject}}
)

// Add hydration record to hydration_records array
db.Patient_test.updateOne(
  {"patient_id": "PAT1759141374B65D62"},
  {"$push": {"hydration_records": hydrationRecord}}
)
```

#### Updating Objects
```javascript
// Update hydration goal
db.Patient_test.updateOne(
  {"patient_id": "PAT1759141374B65D62"},
  {"$set": {"hydration_goal": newGoalObject}}
)

// Update pregnancy tracking
db.Patient_test.updateOne(
  {"patient_id": "PAT1759141374B65D62"},
  {"$set": {"pregnancy_tracking": newPregnancyData}}
)
```

#### Querying Data
```javascript
// Get patient with appointments
db.Patient_test.findOne(
  {"patient_id": "PAT1759141374B65D62"},
  {"appointments": 1, "first_name": 1, "last_name": 1}
)

// Get hydration records for specific date range
db.Patient_test.findOne(
  {"patient_id": "PAT1759141374B65D62"},
  {"hydration_records": {
    "$elemMatch": {
      "timestamp": {
        "$gte": "2024-09-01T00:00:00Z",
        "$lte": "2024-09-30T23:59:59Z"
      }
    }
  }}
)
```

## Indexes

### Recommended Indexes
```javascript
// Primary index on patient_id
db.Patient_test.createIndex({"patient_id": 1}, {"unique": true})

// Index on email for login
db.Patient_test.createIndex({"email": 1}, {"unique": true})

// Index on mobile for login
db.Patient_test.createIndex({"mobile": 1}, {"unique": true})

// Compound index for appointments
db.Patient_test.createIndex({
  "patient_id": 1,
  "appointments.appointment_date": 1
})

// Compound index for hydration records
db.Patient_test.createIndex({
  "patient_id": 1,
  "hydration_records.timestamp": 1
})
```

## Data Validation

### Required Fields
- `patient_id` - Unique patient identifier
- `first_name` - Patient's first name
- `last_name` - Patient's last name
- `email` - Patient's email address
- `created_at` - Document creation timestamp
- `updated_at` - Document last update timestamp

### Data Types
- **Strings**: Names, emails, addresses, notes
- **Numbers**: Ages, weights, measurements, scores
- **Dates**: Birth dates, appointment dates, timestamps
- **Booleans**: Active status, verification flags
- **Arrays**: Lists of related data (appointments, logs)
- **Objects**: Complex nested data structures

## Best Practices

1. **Consistent Naming**: Use snake_case for field names
2. **Timestamps**: Always include created_at and updated_at
3. **Unique IDs**: Generate unique IDs for array elements
4. **Data Validation**: Validate data before storing
5. **Indexing**: Create appropriate indexes for query performance
6. **Document Size**: Monitor document size to avoid MongoDB limits
7. **Backup**: Regular backups of patient data
8. **Privacy**: Ensure sensitive data is properly secured

## Security Considerations

1. **Password Hashing**: Store hashed passwords, never plain text
2. **Data Encryption**: Encrypt sensitive medical data
3. **Access Control**: Implement proper authentication and authorization
4. **Audit Logging**: Log all data access and modifications
5. **Data Retention**: Implement data retention policies
6. **Compliance**: Ensure HIPAA compliance for medical data

This structure provides a comprehensive foundation for storing patient data in a pregnancy tracking application while maintaining flexibility and performance.


# Vital Hydration API - Endpoint Reference

## Base URL
```
http://localhost:8000/api/v1
```

## Authentication
All endpoints (except registration and login) require a JWT token in the Authorization header:
```
Authorization: Bearer <your-jwt-token>
```

---

## 🔐 Authentication Endpoints

### Register User
```http
POST /auth/register
```
**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "first_name": "Jane",
  "last_name": "Doe",
  "phone_number": "+1234567890",
  "date_of_birth": "1990-01-01T00:00:00",
  "pregnancy_week": 20,
  "due_date": "2024-06-01T00:00:00",
  "weight": 65.0,
  "height": 165.0,
  "location_lat": 40.7128,
  "location_lon": -74.0060,
  "timezone": "UTC"
}
```

### Login
```http
POST /auth/login
```
**Request Body (form data):**
```
username: user@example.com
password: password123
```

### Get Current User
```http
GET /auth/me
```

### Update User Profile
```http
PUT /auth/me
```

---

## 💧 Hydration Endpoints

### Log Water Intake
```http
POST /hydration/log
```
**Request Body:**
```json
{
  "amount_ml": 250,
  "drink_type": "water",
  "notes": "Morning glass"
}
```

### Get Today's Summary
```http
GET /hydration/today
```
**Response:**
```json
{
  "date": "2024-01-15T10:30:00",
  "total_intake_ml": 1500,
  "goal_ml": 3000,
  "percentage_complete": 50.0,
  "weather_adjustment": 1.1,
  "pregnancy_adjustment": 1.2,
  "risk_score": 0.3
}
```

### Get Hydration Logs
```http
GET /hydration/logs?days=7
```

### Get Current Goal
```http
GET /hydration/goal
```

### Get Hydration Trend
```http
GET /hydration/trend?days=7
```

### Get Hydration Anomalies
```http
GET /hydration/anomalies?days=7
```

### Get Recommendations
```http
GET /hydration/recommendations
```

### Delete Hydration Log
```http
DELETE /hydration/logs/{log_id}
```

---

## 🌤️ Weather Endpoints

### Get Current Weather
```http
GET /weather/current
```
**Response:**
```json
{
  "current_weather": {
    "temperature": 25.5,
    "humidity": 60.0,
    "weather_condition": "sunny",
    "feels_like": 27.0,
    "pressure": 1013,
    "wind_speed": 5.2
  },
  "hydration_adjustment": 1.15
}
```

### Update Location
```http
POST /weather/update-location?lat=40.7128&lon=-74.0060
```

### Get Weather Forecast
```http
GET /weather/forecast?days=5
```

### Get Weather History
```http
GET /weather/history?days=7
```

---

## 🚨 Alert Endpoints

### Get User Alerts
```http
GET /alerts/?days=7&unread_only=true
```

### Check Hydration Alerts
```http
POST /alerts/check
```

### Get Risk Score
```http
GET /alerts/risk-score
```
**Response:**
```json
{
  "risk_score": 0.3,
  "risk_level": "low",
  "recommendations": [
    "💧 You're doing great! Keep up the good hydration habits.",
    "🥤 Consider drinking water before meals to maintain hydration."
  ]
}
```

### Mark Alert as Read
```http
PUT /alerts/{alert_id}/read
```

### Mark All Alerts as Read
```http
PUT /alerts/mark-all-read
```

### Delete Alert
```http
DELETE /alerts/{alert_id}
```

---

## 📊 Report Endpoints

### Get Weekly Report
```http
GET /reports/weekly?week_start=2024-01-15T00:00:00
```

### Send Report to Clinician
```http
POST /reports/weekly/send
```
**Request Body:**
```json
{
  "clinician_email": "doctor@clinic.com"
}
```

### Get Monthly Summary
```http
GET /reports/monthly?month=12&year=2023
```

### Get Hydration Trends
```http
GET /reports/trends?days=30
```

### Export Data
```http
GET /reports/export?format=json&days=30
```

---

## 📚 Content Endpoints

### Get Motivational Messages
```http
GET /content/motivational
```

### Get Educational Tips
```http
GET /content/educational
```

### Get Daily Content
```http
GET /content/daily-content
```
**Response:**
```json
{
  "motivational": "💧 Every sip counts! You're taking great care of yourself and your baby.",
  "educational": "💡 Tip: Start your day with a glass of water to kickstart hydration.",
  "pregnancy_specific": "Second trimester: Your baby is growing rapidly. Extra hydration helps support this important development phase.",
  "pregnancy_week": 20,
  "date": "2024-01-15T10:30:00"
}
```

### Send Motivational Message
```http
POST /content/send-motivation
```

### Send Educational Content
```http
POST /content/send-education
```

### Get Educational Content
```http
GET /content/content?content_type=tip
```

### Get Content by ID
```http
GET /content/content/{content_id}
```

---

## 🔍 Health & Status

### Health Check
```http
GET /health
```

### API Root
```http
GET /
```

---

## 📱 Mobile App Integration Examples

### Complete Daily Flow
```javascript
// 1. Login
const loginResponse = await fetch('/api/v1/auth/login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
  body: 'username=user@example.com&password=password123'
});
const { access_token } = await loginResponse.json();

// 2. Get today's summary
const summaryResponse = await fetch('/api/v1/hydration/today', {
  headers: { 'Authorization': `Bearer ${access_token}` }
});
const summary = await summaryResponse.json();

// 3. Log water intake
const logResponse = await fetch('/api/v1/hydration/log', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${access_token}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    amount_ml: 250,
    drink_type: 'water',
    notes: 'Morning glass'
  })
});

// 4. Check risk score
const riskResponse = await fetch('/api/v1/alerts/risk-score', {
  headers: { 'Authorization': `Bearer ${access_token}` }
});
const risk = await riskResponse.json();

// 5. Get daily content
const contentResponse = await fetch('/api/v1/content/daily-content', {
  headers: { 'Authorization': `Bearer ${access_token}` }
});
const content = await contentResponse.json();
```

### Error Handling
All endpoints return standard HTTP status codes:
- `200`: Success
- `201`: Created
- `400`: Bad Request
- `401`: Unauthorized
- `404`: Not Found
- `422`: Validation Error
- `500`: Internal Server Error

Error responses include details:
```json
{
  "detail": "Error message description"
}
```


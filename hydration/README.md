# Vital Hydration API

Real-time hydration monitoring and alerts for pregnant users with AI-powered wellness tracking.

## 🎯 Features

- **Real-time Hydration Tracking**: Log daily water intake with detailed analytics
- **Weather Integration**: Dynamic hydration goals based on local weather conditions
- **AI-Powered Alerts**: Smart notifications for dehydration risk and low intake
- **Pregnancy-Specific**: Tailored recommendations for different pregnancy stages
- **Clinical Reports**: Weekly summaries for healthcare providers
- **Educational Content**: Motivational messages and hydration tips
- **Push Notifications & SMS**: Multi-channel alert system

## 🚀 Quick Start

### Prerequisites

- Python 3.8+
- PostgreSQL
- Redis (for background tasks)
- OpenWeather API key
- Twilio account (for SMS)
- Firebase project (for push notifications)

### Installation

1. **Clone the repository**
```bash
git clone <repository-url>
cd vital-hydration-api
```

2. **Install dependencies**
```bash
pip install -r requirements.txt
```

3. **Set up environment variables**
```bash
cp .env.example .env
# Edit .env with your configuration
```

4. **Set up the database**
```bash
# Create PostgreSQL database
createdb vital_hydration

# Run migrations (if using Alembic)
alembic upgrade head
```

5. **Run the application**
```bash
uvicorn main:app --reload
```

The API will be available at `http://localhost:8000`

## 📚 API Documentation

### Authentication

All endpoints (except registration and login) require authentication via JWT tokens.

```bash
# Register a new user
POST /api/v1/auth/register
{
  "email": "user@example.com",
  "password": "password123",
  "first_name": "Jane",
  "last_name": "Doe",
  "pregnancy_week": 20,
  "weight": 65.0,
  "height": 165.0
}

# Login
POST /api/v1/auth/login
{
  "username": "user@example.com",
  "password": "password123"
}
```

### Hydration Tracking

```bash
# Log water intake
POST /api/v1/hydration/log
{
  "amount_ml": 250,
  "drink_type": "water",
  "notes": "Morning glass"
}

# Get today's summary
GET /api/v1/hydration/today

# Get hydration logs
GET /api/v1/hydration/logs?days=7

# Get current goal
GET /api/v1/hydration/goal
```

### Weather Integration

```bash
# Get current weather
GET /api/v1/weather/current

# Update location
POST /api/v1/weather/update-location?lat=40.7128&lon=-74.0060

# Get weather forecast
GET /api/v1/weather/forecast?days=5
```

### Alerts & Notifications

```bash
# Check for alerts
POST /api/v1/alerts/check

# Get user alerts
GET /api/v1/alerts/?days=7&unread_only=true

# Get risk score
GET /api/v1/alerts/risk-score

# Mark alert as read
PUT /api/v1/alerts/{alert_id}/read
```

### Reports

```bash
# Get weekly report
GET /api/v1/reports/weekly

# Send report to clinician
POST /api/v1/reports/weekly/send
{
  "clinician_email": "doctor@clinic.com"
}

# Get monthly summary
GET /api/v1/reports/monthly?month=12&year=2023

# Export data
GET /api/v1/reports/export?format=json&days=30
```

### Educational Content

```bash
# Get motivational messages
GET /api/v1/content/motivational

# Get educational tips
GET /api/v1/content/educational

# Get daily content
GET /api/v1/content/daily-content

# Send motivational message
POST /api/v1/content/send-motivation
```

## 🏗️ Architecture

### Core Components

1. **Hydration Engine**: AI-powered calculation of dynamic hydration goals
2. **Weather Service**: Integration with OpenWeather API for environmental adjustments
3. **Alert Service**: Smart notification system with risk assessment
4. **Report Service**: Clinical reporting and analytics
5. **Notification Service**: Multi-channel communication (Push, SMS)

### Database Schema

- **Users**: User profiles with pregnancy information
- **HydrationLogs**: Daily water intake records
- **WeatherData**: Environmental conditions
- **SymptomLogs**: Health symptom tracking
- **Alerts**: Notification history
- **EducationalContent**: Tips and motivational content

## 🔧 Configuration

### Environment Variables

```env
# Database
DATABASE_URL=postgresql://user:password@localhost/vital_hydration

# Security
SECRET_KEY=your-secret-key-here
ACCESS_TOKEN_EXPIRE_MINUTES=30

# Weather API
OPENWEATHER_API_KEY=your-openweather-api-key

# Twilio SMS
TWILIO_ACCOUNT_SID=your-twilio-sid
TWILIO_AUTH_TOKEN=your-twilio-token
TWILIO_PHONE_NUMBER=+1234567890

# Firebase
FIREBASE_CREDENTIALS_PATH=firebase-credentials.json

# Redis
REDIS_URL=redis://localhost:6379
```

## 🧪 Testing

```bash
# Run tests
pytest

# Run with coverage
pytest --cov=app

# Run specific test file
pytest tests/test_hydration.py
```

## 📱 Mobile App Integration

### Authentication Flow
1. Register/login to get JWT token
2. Store token securely in app
3. Include token in Authorization header: `Bearer <token>`

### Key Endpoints for Mobile
- `POST /api/v1/hydration/log` - Log water intake
- `GET /api/v1/hydration/today` - Get daily summary
- `GET /api/v1/alerts/risk-score` - Check dehydration risk
- `GET /api/v1/content/daily-content` - Get motivational content

### Push Notifications
- Register FCM token with user profile
- Receive real-time alerts for low hydration
- Get motivational messages and tips

## 🚨 Alert System

### Alert Types
- **Low Hydration**: When intake is below 30% of daily goal
- **Dehydration Risk**: Based on AI risk score calculation
- **Symptom Alert**: When dehydration-related symptoms are reported
- **Critical Alert**: High-risk situations requiring immediate attention

### Notification Channels
- **Push Notifications**: Real-time alerts via Firebase
- **SMS**: Critical alerts via Twilio
- **In-app**: Alert history and management

## 📊 Analytics & Reporting

### Weekly Clinical Reports Include:
- Hydration compliance rate
- Dehydration risk events
- Symptom frequency analysis
- Weather impact assessment
- Clinical recommendations

### Trend Analysis:
- Daily intake patterns
- Consistency scoring
- Risk score trends
- Anomaly detection

## 🔒 Security

- JWT-based authentication
- Password hashing with bcrypt
- CORS configuration
- Input validation with Pydantic
- SQL injection protection with SQLAlchemy

## 🚀 Deployment

### Docker Deployment
```bash
# Build image
docker build -t vital-hydration-api .

# Run container
docker run -p 8000:8000 vital-hydration-api
```

### Production Considerations
- Use environment-specific configuration
- Set up proper logging
- Configure database connection pooling
- Set up monitoring and health checks
- Use HTTPS in production

## 📞 Support

For questions or issues:
- Create an issue in the repository
- Contact the development team
- Check the API documentation at `/docs`

## 📄 License

This project is licensed under the MIT License.


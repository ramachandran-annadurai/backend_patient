# Doctor Profile Integration with Patient Login System

This integration provides a complete doctor profile functionality that works seamlessly within your existing patient login system. The system supports both patient and doctor roles with proper authentication and authorization.

## 🚀 Features

- **Integrated Authentication**: Single login system for both patients and doctors
- **Doctor Profile Management**: Create, read, update doctor profiles
- **Doctor Search & Discovery**: Patients can search and browse doctors
- **Role-based Access Control**: Proper permissions for different user types
- **JWT Token Authentication**: Secure API access
- **MongoDB Integration**: Uses existing `doctor_v2` collection
- **Sample Data Creation**: Easy setup with sample doctor data

## 📁 Files Created

1. **`doctor_profile_integration.py`** - Core doctor profile management system
2. **`integrated_patient_doctor_system.py`** - Complete integrated system with Flask routes
3. **`test_integrated_system.py`** - Test script to verify functionality
4. **`DOCTOR_PROFILE_INTEGRATION_README.md`** - This documentation

## 🛠️ Setup Instructions

### 1. Install Dependencies

Make sure you have the required Python packages:

```bash
pip install flask pymongo bcrypt pyjwt python-dotenv requests
```

### 2. Environment Variables

Create or update your `.env` file:

```env
MONGO_URI=mongodb://localhost:27017/
DB_NAME=patients_db
JWT_SECRET_KEY=your-secret-key-here
```

### 3. Database Setup

The system uses your existing MongoDB collections:
- **Patients**: `Patient_test` collection
- **Doctors**: `doctor_v2` collection

### 4. Run the Integrated System

```bash
python integrated_patient_doctor_system.py
```

The server will start on `http://localhost:5000`

## 🔐 Authentication Flow

### Patient Login
```json
POST /login
{
    "login_identifier": "PAT123456",  // Patient ID or email
    "password": "patient_password",
    "role": "patient"
}
```

### Doctor Login
```json
POST /login
{
    "login_identifier": "doctor@hospital.com",  // Email only
    "password": "doctor_password",
    "role": "doctor"
}
```

### Response
```json
{
    "success": true,
    "message": "Login successful",
    "token": "jwt_token_here",
    "user_role": "patient",
    "user_id": "PAT123456",
    "username": "john_doe",
    "email": "john@example.com",
    "patient_id": "PAT123456"  // or doctor_id for doctors
}
```

## 📋 API Endpoints

### Authentication
- `POST /login` - Login for patients and doctors

### Doctor Profile Management
- `GET /api/doctor/profile` - Get current doctor's profile (doctor only)
- `GET /api/doctor/profile/<doctor_id>` - Get specific doctor profile (any authenticated user)
- `PUT /api/doctor/profile` - Update doctor profile (doctor only)

### Doctor Discovery
- `GET /api/doctors` - Get all doctors with pagination
- `GET /api/doctors/search?q=<term>` - Search doctors by name, specialty, or location
- `GET /api/doctor/specialties` - Get list of available specialties

### Utility
- `POST /api/doctor/create-sample` - Create sample doctor data
- `GET /health` - Health check

## 🔧 Usage Examples

### 1. Create Sample Doctors

```python
import requests

# Login first
login_data = {
    "login_identifier": "your_email@example.com",
    "password": "your_password",
    "role": "patient"
}

response = requests.post("http://localhost:5000/login", json=login_data)
token = response.json()["token"]

# Create sample doctors
headers = {"Authorization": f"Bearer {token}"}
response = requests.post("http://localhost:5000/api/doctor/create-sample", headers=headers)
print(response.json())
```

### 2. Search Doctors

```python
# Search for cardiologists
response = requests.get(
    "http://localhost:5000/api/doctors/search?q=cardiology",
    headers=headers
)
doctors = response.json()["doctors"]
```

### 3. Get Doctor Profile

```python
# Get specific doctor profile
response = requests.get(
    "http://localhost:5000/api/doctor/profile/DOC123456",
    headers=headers
)
doctor = response.json()["doctor"]
```

### 4. Get All Doctors with Pagination

```python
# Get first 10 doctors
response = requests.get(
    "http://localhost:5000/api/doctors?limit=10&offset=0",
    headers=headers
)
doctors = response.json()["doctors"]
```

## 🧪 Testing

### Run Component Tests (No Server Required)
```bash
python test_integrated_system.py --no-server
```

### Run Full Integration Tests
```bash
# Terminal 1: Start the server
python integrated_patient_doctor_system.py

# Terminal 2: Run tests
python test_integrated_system.py
```

## 🔒 Security Features

1. **JWT Token Authentication**: All API endpoints require valid JWT tokens
2. **Role-based Access Control**: Different permissions for patients and doctors
3. **Password Hashing**: Uses bcrypt for secure password storage
4. **Input Validation**: Proper validation of all inputs
5. **Error Handling**: Comprehensive error handling and logging

## 📊 Database Schema

### Doctor Document Structure
```json
{
    "doctor_id": "DOC123456",
    "name": "Dr. Sarah Johnson",
    "specialty": "Cardiology",
    "email": "sarah.johnson@hospital.com",
    "phone": "+1-555-0123",
    "mobile": "+1-555-0123",
    "location": "New York Medical Center",
    "experience": 8,
    "rating": 4.9,
    "bio": "Experienced cardiologist...",
    "education": "MD from Harvard Medical School",
    "certifications": ["Board Certified Cardiologist"],
    "languages": ["English", "Spanish"],
    "availability": "Monday-Friday 9AM-5PM",
    "profile_image": "https://example.com/doctor-sarah.jpg",
    "status": "active",
    "role": "doctor",
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z"
}
```

## 🔄 Integration with Existing System

To integrate this with your existing `app_simple.py`:

1. **Import the components**:
```python
from doctor_profile_integration import DoctorProfileManager, create_doctor_routes
```

2. **Initialize the manager**:
```python
doctor_manager = DoctorProfileManager(MONGO_URI, DB_NAME)
```

3. **Add the routes**:
```python
create_doctor_routes(app, doctor_manager)
```

4. **Update your login endpoint** to handle both roles:
```python
# In your existing login endpoint
role = data.get('role', 'patient')
if role == 'doctor':
    # Handle doctor login
    user = db.doctors_collection.find_one({"email": login_identifier})
else:
    # Handle patient login (existing code)
    user = db.patients_collection.find_one({"patient_id": login_identifier})
```

## 🐛 Troubleshooting

### Common Issues

1. **Database Connection Error**
   - Check your `MONGO_URI` in `.env` file
   - Ensure MongoDB is running
   - Verify database name is correct

2. **Authentication Errors**
   - Check JWT secret key is set
   - Verify token format in Authorization header
   - Ensure user exists in database

3. **Doctor Not Found**
   - Run sample data creation: `POST /api/doctor/create-sample`
   - Check doctor_id format
   - Verify doctor exists in `doctor_v2` collection

4. **Permission Denied**
   - Check user role in JWT token
   - Ensure proper decorators are used
   - Verify doctor-specific endpoints have `@doctor_required`

### Debug Mode

Enable debug logging by setting environment variable:
```bash
export FLASK_DEBUG=1
```

## 📈 Performance Considerations

1. **Database Indexes**: The system creates indexes on frequently queried fields
2. **Pagination**: All list endpoints support pagination
3. **Caching**: Consider implementing Redis for frequently accessed data
4. **Rate Limiting**: Add rate limiting for production use

## 🚀 Production Deployment

1. **Environment Variables**: Set all required environment variables
2. **Database**: Use production MongoDB instance
3. **Security**: Use strong JWT secret key
4. **HTTPS**: Enable HTTPS for all endpoints
5. **Monitoring**: Add logging and monitoring
6. **Backup**: Regular database backups

## 📞 Support

If you encounter any issues:

1. Check the test script output
2. Verify database connectivity
3. Check environment variables
4. Review error logs
5. Ensure all dependencies are installed

## 🎯 Next Steps

1. **Appointment Integration**: Add appointment booking functionality
2. **Real-time Notifications**: Implement WebSocket for real-time updates
3. **File Upload**: Add profile image upload functionality
4. **Advanced Search**: Implement advanced filtering options
5. **Analytics**: Add usage analytics and reporting

---

**Note**: This integration maintains compatibility with your existing patient login system while adding comprehensive doctor profile functionality. All existing patient features continue to work unchanged.






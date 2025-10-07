#!/usr/bin/env python3
"""
Integrated Patient-Doctor System
This file shows how to integrate doctor profile functionality with the existing patient login system.
"""

import pymongo
import bcrypt
import jwt
import os
from datetime import datetime, timedelta
from functools import wraps
from flask import Flask, request, jsonify
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# JWT Configuration
JWT_SECRET_KEY = os.getenv('JWT_SECRET_KEY', 'your-secret-key-here')
JWT_ALGORITHM = 'HS256'
JWT_EXPIRATION_HOURS = 24

class IntegratedAuthSystem:
    """Integrated authentication system for both patients and doctors"""
    
    def __init__(self, connection_string, db_name="patients_db"):
        """Initialize database connection"""
        self.client = None
        self.patients_collection = None
        self.doctors_collection = None
        
        try:
            self.client = pymongo.MongoClient(connection_string)
            db = self.client[db_name]
            
            # Use the correct collection names
            self.patients_collection = db["Patient_test"]
            self.doctors_collection = db["doctor_v2"]
            
            # Create indexes
            try:
                self.patients_collection.create_index("patient_id", unique=True, sparse=True)
                self.patients_collection.create_index("email", unique=True, sparse=True)
                self.patients_collection.create_index("mobile", unique=True, sparse=True)
                
                self.doctors_collection.create_index("doctor_id", unique=True, sparse=True)
                self.doctors_collection.create_index("email", unique=True, sparse=True)
                self.doctors_collection.create_index("mobile", unique=True, sparse=True)
            except:
                pass  # Indexes might already exist
            
            print(f"✅ Integrated Auth System connected to MongoDB")
            print(f"   - Patients collection: Patient_test")
            print(f"   - Doctors collection: doctor_v2")
            
        except Exception as e:
            print(f"❌ Database connection error: {e}")
            raise

    def login_user(self, login_identifier, password, role="patient"):
        """Login user (patient or doctor)"""
        try:
            if role == "doctor":
                # Try to find doctor by email
                user = self.doctors_collection.find_one({"email": login_identifier})
                if not user:
                    return False, None, "Doctor not found"
            else:
                # Try to find patient by Patient ID or email
                user = self.patients_collection.find_one({"patient_id": login_identifier})
                if not user:
                    user = self.patients_collection.find_one({"email": login_identifier})
                if not user:
                    return False, None, "Patient not found"
            
            # Verify password
            if not bcrypt.checkpw(password.encode('utf-8'), user["password_hash"]):
                return False, None, "Invalid password"
            
            # Check if account is active
            if user.get("status") != "active":
                return False, None, "Account not activated"
            
            # Add role to user data
            user["role"] = role
            
            return True, user, "Login successful"
            
        except Exception as e:
            return False, None, f"Login error: {str(e)}"

    def create_doctor_profile(self, doctor_data):
        """Create a new doctor profile"""
        try:
            # Generate doctor ID if not provided
            if 'doctor_id' not in doctor_data:
                doctor_data['doctor_id'] = f"DOC{datetime.now().strftime('%Y%m%d%H%M%S')}"
            
            # Add timestamps and status
            doctor_data['created_at'] = datetime.now()
            doctor_data['updated_at'] = datetime.now()
            doctor_data['status'] = 'active'
            doctor_data['role'] = 'doctor'
            
            # Hash password if provided
            if 'password' in doctor_data:
                doctor_data['password_hash'] = bcrypt.hashpw(
                    doctor_data['password'].encode('utf-8'), 
                    bcrypt.gensalt()
                )
                del doctor_data['password']  # Remove plain text password
            
            # Insert into doctor_v2 collection
            result = self.doctors_collection.insert_one(doctor_data)
            
            if result.inserted_id:
                print(f"✅ Doctor profile created: {doctor_data['doctor_id']}")
                return {
                    'success': True,
                    'doctor_id': doctor_data['doctor_id'],
                    'message': 'Doctor profile created successfully'
                }
            else:
                return {
                    'success': False,
                    'error': 'Failed to create doctor profile'
                }
                
        except pymongo.errors.DuplicateKeyError as e:
            if "doctor_id" in str(e):
                return {
                    'success': False,
                    'error': f"Doctor ID '{doctor_data.get('doctor_id')}' already exists"
                }
            elif "email" in str(e):
                return {
                    'success': False,
                    'error': f"Email '{doctor_data.get('email')}' already exists"
                }
            else:
                return {
                    'success': False,
                    'error': f"Duplicate key error: {str(e)}"
                }
        except Exception as e:
            return {
                'success': False,
                'error': f"Error creating doctor profile: {str(e)}"
            }

    def get_doctor_profile(self, doctor_id):
        """Get doctor profile by doctor_id"""
        try:
            doctor = self.doctors_collection.find_one({"doctor_id": doctor_id})
            
            if doctor:
                # Remove sensitive data
                doctor.pop('_id', None)
                doctor.pop('password_hash', None)
                
                return {
                    'success': True,
                    'doctor': doctor
                }
            else:
                return {
                    'success': False,
                    'error': 'Doctor not found'
                }
                
        except Exception as e:
            return {
                'success': False,
                'error': f"Error retrieving doctor profile: {str(e)}"
            }

    def get_all_doctors(self, limit=50, offset=0, specialty=None):
        """Get all doctors with optional filtering"""
        try:
            query = {"status": "active"}
            if specialty:
                query["specialty"] = {"$regex": specialty, "$options": "i"}
            
            # Get total count
            total_count = self.doctors_collection.count_documents(query)
            
            # Get doctors with pagination
            doctors = list(self.doctors_collection.find(query)
                          .skip(offset)
                          .limit(limit))
            
            # Remove sensitive data
            for doctor in doctors:
                doctor.pop('_id', None)
                doctor.pop('password_hash', None)
            
            return {
                'success': True,
                'doctors': doctors,
                'total_count': total_count,
                'limit': limit,
                'offset': offset
            }
            
        except Exception as e:
            return {
                'success': False,
                'error': f"Error retrieving doctors: {str(e)}"
            }

    def search_doctors(self, search_term, limit=20):
        """Search doctors by name, specialty, or location"""
        try:
            query = {
                "status": "active",
                "$or": [
                    {"name": {"$regex": search_term, "$options": "i"}},
                    {"specialty": {"$regex": search_term, "$options": "i"}},
                    {"location": {"$regex": search_term, "$options": "i"}}
                ]
            }
            
            doctors = list(self.doctors_collection.find(query).limit(limit))
            
            # Remove sensitive data
            for doctor in doctors:
                doctor.pop('_id', None)
                doctor.pop('password_hash', None)
            
            return {
                'success': True,
                'doctors': doctors,
                'search_term': search_term,
                'count': len(doctors)
            }
            
        except Exception as e:
            return {
                'success': False,
                'error': f"Error searching doctors: {str(e)}"
            }

    def create_sample_doctors(self):
        """Create sample doctor data for testing"""
        sample_doctors = [
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
                "bio": "Experienced cardiologist specializing in interventional procedures",
                "education": "MD from Harvard Medical School",
                "certifications": ["Board Certified Cardiologist", "Fellow of American College of Cardiology"],
                "languages": ["English", "Spanish"],
                "availability": "Monday-Friday 9AM-5PM",
                "profile_image": "https://example.com/doctor-sarah.jpg",
                "password": "doctor123"  # Will be hashed
            },
            {
                "doctor_id": "DOC789012",
                "name": "Dr. Michael Chen",
                "specialty": "Neurology",
                "email": "michael.chen@hospital.com",
                "phone": "+1-555-0456",
                "mobile": "+1-555-0456",
                "location": "Los Angeles Medical Center",
                "experience": 12,
                "rating": 4.7,
                "bio": "Board-certified neurologist with expertise in movement disorders",
                "education": "MD from Stanford Medical School",
                "certifications": ["Board Certified Neurologist", "Fellow of American Academy of Neurology"],
                "languages": ["English", "Mandarin"],
                "availability": "Tuesday-Thursday 8AM-6PM",
                "profile_image": "https://example.com/doctor-michael.jpg",
                "password": "doctor123"  # Will be hashed
            },
            {
                "doctor_id": "DOC345678",
                "name": "Dr. Emily Rodriguez",
                "specialty": "Pediatrics",
                "email": "emily.rodriguez@hospital.com",
                "phone": "+1-555-0789",
                "mobile": "+1-555-0789",
                "location": "Chicago Children's Hospital",
                "experience": 6,
                "rating": 4.8,
                "bio": "Pediatrician specializing in child development and preventive care",
                "education": "MD from Johns Hopkins Medical School",
                "certifications": ["Board Certified Pediatrician", "Fellow of American Academy of Pediatrics"],
                "languages": ["English", "Spanish", "French"],
                "availability": "Monday-Wednesday-Friday 8AM-4PM",
                "profile_image": "https://example.com/doctor-emily.jpg",
                "password": "doctor123"  # Will be hashed
            }
        ]
        
        created_count = 0
        for doctor in sample_doctors:
            result = self.create_doctor_profile(doctor)
            if result['success']:
                created_count += 1
        
        return {
            'success': True,
            'message': f'Created {created_count} sample doctors',
            'created_count': created_count
        }

    def close_connection(self):
        """Close database connection"""
        if self.client:
            self.client.close()
            print("Database connection closed.")


# JWT Token Functions
def generate_jwt_token(user_data):
    """Generate JWT token for user"""
    payload = {
        "user_id": str(user_data.get("_id")) if user_data.get("_id") else str(user_data.get("patient_id", "")),
        "patient_id": user_data.get("patient_id"),
        "doctor_id": user_data.get("doctor_id"),
        "email": user_data.get("email"),
        "username": user_data.get("username"),
        "role": user_data.get("role", "patient"),
        "exp": datetime.utcnow() + timedelta(hours=JWT_EXPIRATION_HOURS),
        "iat": datetime.utcnow()
    }
    return jwt.encode(payload, JWT_SECRET_KEY, algorithm=JWT_ALGORITHM)

def verify_jwt_token(token):
    """Verify JWT token and return user data"""
    try:
        payload = jwt.decode(token, JWT_SECRET_KEY, algorithms=[JWT_ALGORITHM])
        return payload
    except jwt.ExpiredSignatureError:
        return None
    except jwt.InvalidTokenError:
        return None

def token_required(f):
    """Decorator to require JWT token for protected routes"""
    @wraps(f)
    def decorated(*args, **kwargs):
        token = None
        
        # Get token from header
        if 'Authorization' in request.headers:
            auth_header = request.headers['Authorization']
            try:
                token = auth_header.split(" ")[1]  # Bearer <token>
            except IndexError:
                return jsonify({"error": "Invalid token format"}), 401
        
        if not token:
            return jsonify({"error": "Token is missing"}), 401
        
        # Verify token
        payload = verify_jwt_token(token)
        if not payload:
            return jsonify({"error": "Invalid or expired token"}), 401
        
        # Add user data to request
        request.user_data = payload
        return f(*args, **kwargs)
    
    return decorated

def doctor_required(f):
    """Decorator to require doctor role for doctor-specific routes"""
    @wraps(f)
    def decorated(*args, **kwargs):
        if not hasattr(request, 'user_data'):
            return jsonify({"error": "Authentication required"}), 401
        
        user_role = request.user_data.get('role', 'patient')
        if user_role != 'doctor':
            return jsonify({"error": "Doctor access required"}), 403
        
        return f(*args, **kwargs)
    
    return decorated


# Flask Application with Integrated Routes
def create_integrated_app():
    """Create Flask app with integrated patient-doctor functionality"""
    app = Flask(__name__)
    
    # Initialize integrated auth system
    MONGO_URI = os.getenv("MONGO_URI", "mongodb://localhost:27017/")
    DB_NAME = os.getenv("DB_NAME", "patients_db")
    
    auth_system = IntegratedAuthSystem(MONGO_URI, DB_NAME)
    
    # Login endpoint for both patients and doctors
    @app.route('/login', methods=['POST'])
    def login():
        """Login endpoint for both patients and doctors"""
        try:
            data = request.get_json()
            login_identifier = data.get('login_identifier', '').strip()
            password = data.get('password', '')
            role = data.get('role', 'patient')  # Default to patient
            
            if not login_identifier or not password:
                return jsonify({"error": "Login identifier and password are required"}), 400
            
            # Attempt login
            success, user, message = auth_system.login_user(login_identifier, password, role)
            
            if success:
                # Generate JWT token
                token = generate_jwt_token(user)
                
                # Prepare response based on role
                response_data = {
                    "success": True,
                    "message": message,
                    "token": token,
                    "user_role": role,
                    "user_id": user.get('patient_id') or user.get('doctor_id'),
                    "username": user.get('username'),
                    "email": user.get('email')
                }
                
                if role == "patient":
                    response_data["patient_id"] = user.get('patient_id')
                else:
                    response_data["doctor_id"] = user.get('doctor_id')
                
                return jsonify(response_data), 200
            else:
                return jsonify({"error": message}), 401
                
        except Exception as e:
            return jsonify({"error": f"Login error: {str(e)}"}), 500

    # Doctor Profile Routes
    @app.route('/api/doctor/profile', methods=['GET'])
    @token_required
    def get_doctor_profile():
        """Get current doctor's profile (for doctor users)"""
        try:
            doctor_id = request.user_data.get('doctor_id')
            if not doctor_id:
                return jsonify({
                    'success': False,
                    'error': 'Doctor ID not found in token'
                }), 400
            
            result = auth_system.get_doctor_profile(doctor_id)
            return jsonify(result), 200 if result['success'] else 404
            
        except Exception as e:
            return jsonify({
                'success': False,
                'error': f"Error retrieving doctor profile: {str(e)}"
            }), 500

    @app.route('/api/doctor/profile/<doctor_id>', methods=['GET'])
    @token_required
    def get_doctor_profile_by_id(doctor_id):
        """Get specific doctor profile by ID (for patients to view doctor info)"""
        try:
            result = auth_system.get_doctor_profile(doctor_id)
            return jsonify(result), 200 if result['success'] else 404
            
        except Exception as e:
            return jsonify({
                'success': False,
                'error': f"Error retrieving doctor profile: {str(e)}"
            }), 500

    @app.route('/api/doctors', methods=['GET'])
    @token_required
    def get_all_doctors():
        """Get all doctors (for patients to browse doctors)"""
        try:
            limit = request.args.get('limit', 50, type=int)
            offset = request.args.get('offset', 0, type=int)
            specialty = request.args.get('specialty')
            
            result = auth_system.get_all_doctors(limit, offset, specialty)
            return jsonify(result), 200 if result['success'] else 400
            
        except Exception as e:
            return jsonify({
                'success': False,
                'error': f"Error retrieving doctors: {str(e)}"
            }), 500

    @app.route('/api/doctors/search', methods=['GET'])
    @token_required
    def search_doctors():
        """Search doctors by name, specialty, or location"""
        try:
            search_term = request.args.get('q', '')
            if not search_term:
                return jsonify({
                    'success': False,
                    'error': 'Search term is required'
                }), 400
            
            limit = request.args.get('limit', 20, type=int)
            result = auth_system.search_doctors(search_term, limit)
            return jsonify(result), 200 if result['success'] else 400
            
        except Exception as e:
            return jsonify({
                'success': False,
                'error': f"Error searching doctors: {str(e)}"
            }), 500

    @app.route('/api/doctor/specialties', methods=['GET'])
    @token_required
    def get_doctor_specialties():
        """Get list of available doctor specialties"""
        try:
            # Get unique specialties from doctors collection
            specialties = auth_system.doctors_collection.distinct("specialty")
            specialties = [s for s in specialties if s]  # Remove empty values
            
            return jsonify({
                'success': True,
                'specialties': sorted(specialties)
            }), 200
            
        except Exception as e:
            return jsonify({
                'success': False,
                'error': f"Error retrieving specialties: {str(e)}"
            }), 500

    @app.route('/api/doctor/create-sample', methods=['POST'])
    @token_required
    def create_sample_doctors():
        """Create sample doctor data for testing"""
        try:
            result = auth_system.create_sample_doctors()
            return jsonify(result), 200 if result['success'] else 400
            
        except Exception as e:
            return jsonify({
                'success': False,
                'error': f"Error creating sample doctors: {str(e)}"
            }), 500

    # Health check endpoint
    @app.route('/health', methods=['GET'])
    def health_check():
        """Health check endpoint"""
        return jsonify({
            "status": "healthy",
            "message": "Integrated Patient-Doctor System is running",
            "timestamp": datetime.now().isoformat()
        }), 200

    return app, auth_system


# Example usage and testing
if __name__ == "__main__":
    # Create integrated app
    app, auth_system = create_integrated_app()
    
    # Test the system
    print("🚀 Integrated Patient-Doctor System Test")
    print("=" * 60)
    
    # Test creating sample doctors
    print("\n📝 Creating sample doctors...")
    result = auth_system.create_sample_doctors()
    print(f"Result: {result}")
    
    # Test getting all doctors
    print("\n👥 Getting all doctors...")
    result = auth_system.get_all_doctors()
    print(f"Found {result.get('total_count', 0)} doctors")
    
    # Test searching doctors
    print("\n🔍 Searching doctors...")
    result = auth_system.search_doctors("cardiology")
    print(f"Found {result.get('count', 0)} cardiologists")
    
    print("\n✅ Integrated Patient-Doctor System setup complete!")
    print("\nAvailable endpoints:")
    print("  POST /login - Login (patients and doctors)")
    print("  GET /api/doctor/profile - Get current doctor's profile")
    print("  GET /api/doctor/profile/<doctor_id> - Get specific doctor profile")
    print("  GET /api/doctors - Get all doctors")
    print("  GET /api/doctors/search?q=<term> - Search doctors")
    print("  GET /api/doctor/specialties - Get doctor specialties")
    print("  POST /api/doctor/create-sample - Create sample doctors")
    print("  GET /health - Health check")
    
    # Run the app
    app.run(debug=True, host='0.0.0.0', port=5000)






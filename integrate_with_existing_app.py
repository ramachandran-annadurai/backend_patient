#!/usr/bin/env python3
"""
Integration script to add doctor profile functionality to existing app_simple.py
This script shows exactly what code to add to your existing application.
"""

# Add these imports to the top of your app_simple.py
INTEGRATION_IMPORTS = '''
# Add these imports to the top of your app_simple.py
from doctor_profile_integration import DoctorProfileManager, create_doctor_routes
'''

# Add this initialization code after your existing database initialization
INITIALIZATION_CODE = '''
# Add this after your existing database initialization in app_simple.py
# Initialize doctor profile manager
doctor_manager = DoctorProfileManager(MONGO_URI, DB_NAME)
'''

# Add this route registration after your existing routes
ROUTE_REGISTRATION = '''
# Add this after your existing route definitions in app_simple.py
# Register doctor profile routes
create_doctor_routes(app, doctor_manager)
'''

# Updated login endpoint code
UPDATED_LOGIN_ENDPOINT = '''
# Replace your existing login endpoint with this updated version
@app.route('/login', methods=['POST'])
def login():
    """Login patient or doctor with Patient ID/Email and password"""
    try:
        # Check database connection and attempt reconnection if needed
        if not db.is_connected():
            print("⚠️ Database not connected during login, attempting reconnection...")
            if not db.reconnect():
                return jsonify({"error": "Database connection error - unable to reconnect"}), 503
        
        if db.patients_collection is None:
            return jsonify({"error": "Database not connected"}), 500
        
        data = request.get_json()
        login_identifier = data.get('login_identifier', '').strip()
        password = data.get('password', '')
        role = data.get('role', 'patient')  # Default to patient
        
        if not login_identifier or not password:
            return jsonify({"error": "Login identifier and password are required"}), 400
        
        user = None
        user_role = role
        
        if role == "doctor":
            # Try to find doctor by email
            user = db.doctors_collection.find_one({"email": login_identifier})
            if not user:
                return jsonify({"error": "Doctor not found"}), 401
        else:
            # Find user by Patient ID or Email (existing logic)
            user = db.patients_collection.find_one({"patient_id": login_identifier})
            if not user:
                user = db.patients_collection.find_one({"email": login_identifier})
        
        if not user:
            return jsonify({"error": "Invalid credentials"}), 401
        
        # Check if account is active
        if user.get("status") != "active":
            return jsonify({"error": "Account not activated. Please verify your email."}), 401
        
        # Verify password
        if not verify_password(password, user["password_hash"]):
            return jsonify({"error": "Invalid credentials"}), 401
        
        # Check profile completion for patients
        profile_complete = True
        if role == "patient":
            profile_complete = is_profile_complete(user)
        
        # Debug logging to identify null values
        print(f"🔍 Login Debug - User Data:")
        print(f"  patient_id: {user.get('patient_id')}")
        print(f"  doctor_id: {user.get('doctor_id')}")
        print(f"  username: {user.get('username')}")
        print(f"  email: {user.get('email')}")
        print(f"  _id: {user.get('_id')}")
        print(f"  status: {user.get('status')}")
        print(f"  role: {user_role}")
        print(f"  profile_complete: {profile_complete}")
        
        # Generate JWT token
        token = generate_jwt_token(user)

        # Prepare response data
        response_data = {
            "success": True,
            "message": "Login successful",
            "token": token,
            "user_role": user_role,
            "user_id": user.get('patient_id') or user.get('doctor_id'),
            "username": user.get('username'),
            "email": user.get('email'),
            "profile_complete": profile_complete
        }
        
        # Add role-specific fields
        if user_role == "patient":
            response_data["patient_id"] = user.get('patient_id')
        else:
            response_data["doctor_id"] = user.get('doctor_id')
        
        return jsonify(response_data), 200

    except Exception as e:
        print(f"❌ Login error: {str(e)}")
        return jsonify({"error": f"Login error: {str(e)}"}), 500
'''

# Updated JWT token generation
UPDATED_JWT_GENERATION = '''
# Replace your existing generate_jwt_token function with this updated version
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
'''

# Doctor-specific decorator
DOCTOR_DECORATOR = '''
# Add this decorator to your app_simple.py
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
'''

def print_integration_instructions():
    """Print step-by-step integration instructions"""
    print("🔧 INTEGRATION INSTRUCTIONS FOR app_simple.py")
    print("=" * 60)
    
    print("\n1️⃣ ADD IMPORTS")
    print("Add these imports to the top of your app_simple.py:")
    print(INTEGRATION_IMPORTS)
    
    print("\n2️⃣ ADD INITIALIZATION")
    print("Add this code after your existing database initialization:")
    print(INITIALIZATION_CODE)
    
    print("\n3️⃣ UPDATE JWT TOKEN GENERATION")
    print("Replace your existing generate_jwt_token function with:")
    print(UPDATED_JWT_GENERATION)
    
    print("\n4️⃣ ADD DOCTOR DECORATOR")
    print("Add this decorator to your app_simple.py:")
    print(DOCTOR_DECORATOR)
    
    print("\n5️⃣ UPDATE LOGIN ENDPOINT")
    print("Replace your existing login endpoint with:")
    print(UPDATED_LOGIN_ENDPOINT)
    
    print("\n6️⃣ REGISTER ROUTES")
    print("Add this after your existing route definitions:")
    print(ROUTE_REGISTRATION)
    
    print("\n7️⃣ TEST THE INTEGRATION")
    print("Run the test script to verify everything works:")
    print("python test_integrated_system.py --no-server")
    
    print("\n✅ INTEGRATION COMPLETE!")
    print("Your app_simple.py now supports both patient and doctor functionality.")

def create_patch_file():
    """Create a patch file with all the changes"""
    patch_content = f"""
# PATCH FILE FOR app_simple.py
# Apply these changes to integrate doctor profile functionality

# 1. ADD IMPORTS (at the top of the file)
{INTEGRATION_IMPORTS}

# 2. ADD INITIALIZATION (after database initialization)
{INITIALIZATION_CODE}

# 3. ADD DOCTOR DECORATOR (add this function)
{DOCTOR_DECORATOR}

# 4. UPDATE JWT TOKEN GENERATION (replace existing function)
{UPDATED_JWT_GENERATION}

# 5. UPDATE LOGIN ENDPOINT (replace existing function)
{UPDATED_LOGIN_ENDPOINT}

# 6. REGISTER ROUTES (add this after existing routes)
{ROUTE_REGISTRATION}
"""
    
    with open("app_simple_patch.txt", "w", encoding="utf-8") as f:
        f.write(patch_content)
    
    print("📝 Patch file created: app_simple_patch.txt")
    print("You can use this file as a reference for making changes to your app_simple.py")

if __name__ == "__main__":
    print_integration_instructions()
    print("\n" + "="*60)
    create_patch_file()
    
    print("\n🚀 QUICK START:")
    print("1. Copy the code snippets above to your app_simple.py")
    print("2. Run: python test_integrated_system.py --no-server")
    print("3. Start your server: python app_simple.py")
    print("4. Test the endpoints using the test script")
    
    print("\n📚 For detailed instructions, see: DOCTOR_PROFILE_INTEGRATION_README.md")

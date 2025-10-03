#!/usr/bin/env python3
"""
Test script for the Integrated Patient-Doctor System
This script demonstrates how to use the integrated system.
"""

import requests
import json
import time

# Configuration
BASE_URL = "http://localhost:5000"
# BASE_URL = "https://your-deployed-url.com"  # For deployed version

def test_integrated_system():
    """Test the integrated patient-doctor system"""
    
    print("🧪 Testing Integrated Patient-Doctor System")
    print("=" * 60)
    
    # Test 1: Health Check
    print("\n1️⃣ Testing Health Check...")
    try:
        response = requests.get(f"{BASE_URL}/health", timeout=10)
        print(f"Status: {response.status_code}")
        if response.status_code == 200:
            print("✅ Health check passed")
            print(f"Response: {response.json()}")
        else:
            print("❌ Health check failed")
            return
    except Exception as e:
        print(f"❌ Health check error: {str(e)}")
        return
    
    # Test 2: Create Sample Doctors
    print("\n2️⃣ Creating Sample Doctors...")
    try:
        # First, we need to login to get a token
        login_data = {
            "login_identifier": "test@example.com",  # Use any existing user
            "password": "test123",
            "role": "patient"
        }
        
        # Try to login first
        login_response = requests.post(f"{BASE_URL}/login", json=login_data, timeout=10)
        if login_response.status_code == 200:
            token = login_response.json().get('token')
            headers = {"Authorization": f"Bearer {token}"}
            
            # Create sample doctors
            response = requests.post(f"{BASE_URL}/api/doctor/create-sample", 
                                   headers=headers, timeout=10)
            print(f"Status: {response.status_code}")
            if response.status_code == 200:
                print("✅ Sample doctors created")
                print(f"Response: {response.json()}")
            else:
                print("❌ Failed to create sample doctors")
                print(f"Response: {response.text}")
        else:
            print("❌ Login failed, skipping sample doctor creation")
            print(f"Login response: {login_response.text}")
            
    except Exception as e:
        print(f"❌ Sample doctor creation error: {str(e)}")
    
    # Test 3: Get All Doctors
    print("\n3️⃣ Testing Get All Doctors...")
    try:
        # Use the token from previous login or create a new one
        if 'token' not in locals():
            login_data = {
                "login_identifier": "test@example.com",
                "password": "test123",
                "role": "patient"
            }
            login_response = requests.post(f"{BASE_URL}/login", json=login_data, timeout=10)
            if login_response.status_code == 200:
                token = login_response.json().get('token')
            else:
                print("❌ Login failed, cannot test doctor endpoints")
                return
        
        headers = {"Authorization": f"Bearer {token}"}
        response = requests.get(f"{BASE_URL}/api/doctors", headers=headers, timeout=10)
        print(f"Status: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print("✅ Get all doctors successful")
            print(f"Total doctors: {data.get('total_count', 0)}")
            if data.get('doctors'):
                print("Sample doctor:")
                doctor = data['doctors'][0]
                print(f"  - ID: {doctor.get('doctor_id')}")
                print(f"  - Name: {doctor.get('name')}")
                print(f"  - Specialty: {doctor.get('specialty')}")
        else:
            print("❌ Get all doctors failed")
            print(f"Response: {response.text}")
            
    except Exception as e:
        print(f"❌ Get all doctors error: {str(e)}")
    
    # Test 4: Search Doctors
    print("\n4️⃣ Testing Search Doctors...")
    try:
        if 'token' not in locals():
            print("❌ No token available, skipping search test")
            return
            
        headers = {"Authorization": f"Bearer {token}"}
        response = requests.get(f"{BASE_URL}/api/doctors/search?q=cardiology", 
                              headers=headers, timeout=10)
        print(f"Status: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print("✅ Search doctors successful")
            print(f"Search term: {data.get('search_term')}")
            print(f"Found: {data.get('count', 0)} doctors")
            if data.get('doctors'):
                print("Sample result:")
                doctor = data['doctors'][0]
                print(f"  - Name: {doctor.get('name')}")
                print(f"  - Specialty: {doctor.get('specialty')}")
        else:
            print("❌ Search doctors failed")
            print(f"Response: {response.text}")
            
    except Exception as e:
        print(f"❌ Search doctors error: {str(e)}")
    
    # Test 5: Get Doctor Specialties
    print("\n5️⃣ Testing Get Doctor Specialties...")
    try:
        if 'token' not in locals():
            print("❌ No token available, skipping specialties test")
            return
            
        headers = {"Authorization": f"Bearer {token}"}
        response = requests.get(f"{BASE_URL}/api/doctor/specialties", 
                              headers=headers, timeout=10)
        print(f"Status: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print("✅ Get specialties successful")
            print(f"Available specialties: {data.get('specialties', [])}")
        else:
            print("❌ Get specialties failed")
            print(f"Response: {response.text}")
            
    except Exception as e:
        print(f"❌ Get specialties error: {str(e)}")
    
    # Test 6: Get Specific Doctor Profile
    print("\n6️⃣ Testing Get Specific Doctor Profile...")
    try:
        if 'token' not in locals():
            print("❌ No token available, skipping profile test")
            return
            
        headers = {"Authorization": f"Bearer {token}"}
        # Try to get a specific doctor profile
        doctor_id = "DOC123456"  # From sample data
        response = requests.get(f"{BASE_URL}/api/doctor/profile/{doctor_id}", 
                              headers=headers, timeout=10)
        print(f"Status: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print("✅ Get doctor profile successful")
            if data.get('doctor'):
                doctor = data['doctor']
                print(f"Doctor: {doctor.get('name')}")
                print(f"Specialty: {doctor.get('specialty')}")
                print(f"Location: {doctor.get('location')}")
                print(f"Experience: {doctor.get('experience')} years")
        else:
            print("❌ Get doctor profile failed")
            print(f"Response: {response.text}")
            
    except Exception as e:
        print(f"❌ Get doctor profile error: {str(e)}")
    
    print("\n🎉 Testing completed!")
    print("\nTo use this system in your application:")
    print("1. Start the integrated system: python integrated_patient_doctor_system.py")
    print("2. Use the login endpoint to authenticate users")
    print("3. Use the doctor endpoints with the JWT token")
    print("4. The system supports both patient and doctor roles")


def test_without_server():
    """Test the system components without running the server"""
    print("🧪 Testing System Components (Without Server)")
    print("=" * 60)
    
    try:
        from integrated_patient_doctor_system import IntegratedAuthSystem
        import os
        
        # Initialize the system
        MONGO_URI = os.getenv("MONGO_URI", "mongodb://localhost:27017/")
        DB_NAME = os.getenv("DB_NAME", "patients_db")
        
        print("🔗 Connecting to database...")
        auth_system = IntegratedAuthSystem(MONGO_URI, DB_NAME)
        
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
        
        # Test getting specific doctor
        print("\n👨‍⚕️ Getting specific doctor profile...")
        result = auth_system.get_doctor_profile("DOC123456")
        if result['success']:
            doctor = result['doctor']
            print(f"Doctor: {doctor.get('name')}")
            print(f"Specialty: {doctor.get('specialty')}")
        else:
            print(f"Error: {result['error']}")
        
        print("\n✅ Component testing completed successfully!")
        
    except Exception as e:
        print(f"❌ Component testing error: {str(e)}")
        print("Make sure MongoDB is running and accessible")


if __name__ == "__main__":
    import sys
    
    if len(sys.argv) > 1 and sys.argv[1] == "--no-server":
        test_without_server()
    else:
        print("Starting server test...")
        print("Make sure the integrated system is running on localhost:5000")
        print("Or run: python integrated_patient_doctor_system.py")
        print()
        
        # Wait a moment for user to start server
        input("Press Enter when the server is running...")
        
        test_integrated_system()


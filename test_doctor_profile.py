#!/usr/bin/env python3
"""
Test doctor profile endpoints from doctor_v2 collection
"""

import requests
import json

# Configuration
BASE_URL = "https://pregnancy-ai.onrender.com"
# BASE_URL = "http://localhost:5000"  # Uncomment for local testing

def test_doctor_profile():
    """Test doctor profile endpoints"""
    
    print("👨‍⚕️ Testing Doctor Profile Endpoints from doctor_v2 Collection")
    print("=" * 70)
    
    # Test user credentials (use your actual credentials)
    test_user = {
        "username": "your_username",  # Replace with your actual username
        "password": "your_password"   # Replace with your actual password
    }
    
    # Step 1: Login to get token
    print("\n🔐 Step 1: Logging in...")
    try:
        response = requests.post(f"{BASE_URL}/login", json=test_user, timeout=10)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            login_response = response.json()
            token = login_response.get('token')
            user_id = login_response.get('patient_id')
            print(f"✅ Login successful")
            print(f"User ID: {user_id}")
        else:
            print(f"❌ Login failed: {response.text}")
            return
    except Exception as e:
        print(f"❌ Login error: {str(e)}")
        return
    
    # Headers for authenticated requests
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }
    
    # Step 2: Get current doctor profile
    print(f"\n👨‍⚕️ Step 2: Getting current doctor profile...")
    try:
        response = requests.get(f"{BASE_URL}/doctor/profile", 
                              headers=headers, 
                              timeout=10)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            profile = response.json()
            print("✅ Doctor profile retrieved successfully")
            print(f"Message: {profile.get('message', 'No message')}")
            
            doctor_data = profile.get('doctor_profile', {})
            if doctor_data:
                print(f"\n📋 Doctor Profile Details:")
                print(f"  Name: {doctor_data.get('name', 'N/A')}")
                print(f"  Specialty: {doctor_data.get('specialty', 'N/A')}")
                print(f"  Email: {doctor_data.get('email', 'N/A')}")
                print(f"  Phone: {doctor_data.get('phone', 'N/A')}")
                print(f"  Location: {doctor_data.get('location', 'N/A')}")
                print(f"  Experience: {doctor_data.get('experience', 'N/A')} years")
                print(f"  Rating: {doctor_data.get('rating', 'N/A')}")
                print(f"  Bio: {doctor_data.get('bio', 'N/A')}")
            else:
                print("📝 No doctor profile data found")
        else:
            print(f"❌ Failed to get doctor profile: {response.text}")
    except Exception as e:
        print(f"❌ Error getting doctor profile: {str(e)}")
    
    # Step 3: Get specific doctor profile by ID
    print(f"\n🔍 Step 3: Getting specific doctor profile by ID...")
    try:
        # Replace with actual doctor ID from your database
        doctor_id = "DOC123456"  # Replace with actual doctor ID
        
        response = requests.get(f"{BASE_URL}/doctor/profile/{doctor_id}", 
                              headers=headers, 
                              timeout=10)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            profile = response.json()
            print("✅ Specific doctor profile retrieved successfully")
            print(f"Message: {profile.get('message', 'No message')}")
            
            doctor_data = profile.get('doctor_profile', {})
            if doctor_data:
                print(f"Doctor Name: {doctor_data.get('name', 'N/A')}")
                print(f"Specialty: {doctor_data.get('specialty', 'N/A')}")
            else:
                print("📝 No doctor profile data found")
        else:
            print(f"❌ Failed to get specific doctor profile: {response.text}")
    except Exception as e:
        print(f"❌ Error getting specific doctor profile: {str(e)}")
    
    # Step 4: Get all doctors
    print(f"\n👥 Step 4: Getting all doctors...")
    try:
        response = requests.get(f"{BASE_URL}/doctors", 
                              headers=headers, 
                              timeout=10)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            doctors = response.json()
            print("✅ All doctors retrieved successfully")
            print(f"Message: {doctors.get('message', 'No message')}")
            print(f"Total doctors: {doctors.get('total_count', 0)}")
            
            doctors_list = doctors.get('doctors', [])
            if doctors_list:
                print(f"\n📋 Doctors List:")
                for i, doctor in enumerate(doctors_list[:5], 1):  # Show first 5
                    print(f"  {i}. {doctor.get('name', 'N/A')} - {doctor.get('specialty', 'N/A')}")
            else:
                print("📝 No doctors found")
        else:
            print(f"❌ Failed to get all doctors: {response.text}")
    except Exception as e:
        print(f"❌ Error getting all doctors: {str(e)}")
    
    # Step 5: Get doctors with filters
    print(f"\n🔍 Step 5: Getting doctors with specialty filter...")
    try:
        response = requests.get(f"{BASE_URL}/doctors?specialty=cardiology&limit=10", 
                              headers=headers, 
                              timeout=10)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            doctors = response.json()
            print("✅ Filtered doctors retrieved successfully")
            print(f"Cardiologists found: {doctors.get('total_count', 0)}")
        else:
            print(f"❌ Failed to get filtered doctors: {response.text}")
    except Exception as e:
        print(f"❌ Error getting filtered doctors: {str(e)}")
    
    print("\n🎉 Testing Complete!")
    print("\n📋 Available Endpoints:")
    print("✅ GET /doctor/profile - Get current doctor's profile")
    print("✅ GET /doctor/profile/<doctor_id> - Get specific doctor's profile")
    print("✅ GET /doctors - Get all doctors with optional filters")
    print("✅ GET /doctors?specialty=cardiology - Filter by specialty")
    print("✅ GET /doctors?location=New York - Filter by location")
    print("✅ GET /doctors?limit=10&offset=0 - Pagination support")

if __name__ == "__main__":
    test_doctor_profile()

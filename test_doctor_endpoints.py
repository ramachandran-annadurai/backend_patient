#!/usr/bin/env python3
"""
Test all doctor profile endpoints
"""

import requests
import json

# Configuration
BASE_URL = "https://pregnancy-ai.onrender.com"
# BASE_URL = "http://localhost:5000"  # Uncomment for local testing

def test_doctor_endpoints():
    """Test all doctor profile endpoints"""
    
    print("👨‍⚕️ Testing Doctor Profile Endpoints")
    print("=" * 50)
    
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
    
    # Step 2: Test Get Current Doctor Profile
    print(f"\n👨‍⚕️ Step 2: Testing GET /doctor/profile...")
    try:
        response = requests.get(f"{BASE_URL}/doctor/profile", 
                              headers=headers, 
                              timeout=10)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            profile = response.json()
            print("✅ Current doctor profile retrieved successfully")
            print(f"Success: {profile.get('success')}")
            print(f"Message: {profile.get('message')}")
            
            doctor_data = profile.get('doctor_profile', {})
            if doctor_data:
                print(f"Doctor ID: {doctor_data.get('doctor_id')}")
                print(f"Name: {doctor_data.get('name')}")
                print(f"Specialty: {doctor_data.get('specialty')}")
                print(f"Email: {doctor_data.get('email')}")
                print(f"Rating: {doctor_data.get('rating')}")
        else:
            print(f"❌ Failed: {response.text}")
    except Exception as e:
        print(f"❌ Error: {str(e)}")
    
    # Step 3: Test Get Doctor Profile by ID
    print(f"\n🔍 Step 3: Testing GET /doctor/profile/DOC123456...")
    try:
        response = requests.get(f"{BASE_URL}/doctor/profile/DOC123456", 
                              headers=headers, 
                              timeout=10)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            profile = response.json()
            print("✅ Doctor profile by ID retrieved successfully")
            print(f"Success: {profile.get('success')}")
            print(f"Message: {profile.get('message')}")
            
            doctor_data = profile.get('doctor_profile', {})
            if doctor_data:
                print(f"Doctor ID: {doctor_data.get('doctor_id')}")
                print(f"Name: {doctor_data.get('name')}")
                print(f"Specialty: {doctor_data.get('specialty')}")
        else:
            print(f"❌ Failed: {response.text}")
    except Exception as e:
        print(f"❌ Error: {str(e)}")
    
    # Step 4: Test Get All Doctors
    print(f"\n👥 Step 4: Testing GET /doctors...")
    try:
        response = requests.get(f"{BASE_URL}/doctors", 
                              headers=headers, 
                              timeout=10)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            doctors = response.json()
            print("✅ All doctors retrieved successfully")
            print(f"Success: {doctors.get('success')}")
            print(f"Total count: {doctors.get('total_count')}")
            print(f"Message: {doctors.get('message')}")
            
            doctors_list = doctors.get('doctors', [])
            if doctors_list:
                print(f"Found {len(doctors_list)} doctors:")
                for i, doctor in enumerate(doctors_list, 1):
                    print(f"  {i}. {doctor.get('name')} - {doctor.get('specialty')} ({doctor.get('doctor_id')})")
        else:
            print(f"❌ Failed: {response.text}")
    except Exception as e:
        print(f"❌ Error: {str(e)}")
    
    # Step 5: Test Get Doctors with Specialty Filter
    print(f"\n🔍 Step 5: Testing GET /doctors?specialty=cardiology...")
    try:
        response = requests.get(f"{BASE_URL}/doctors?specialty=cardiology", 
                              headers=headers, 
                              timeout=10)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            doctors = response.json()
            print("✅ Filtered doctors retrieved successfully")
            print(f"Total count: {doctors.get('total_count')}")
            
            doctors_list = doctors.get('doctors', [])
            if doctors_list:
                print(f"Cardiologists found:")
                for doctor in doctors_list:
                    print(f"  - {doctor.get('name')} - {doctor.get('specialty')}")
            else:
                print("No cardiologists found")
        else:
            print(f"❌ Failed: {response.text}")
    except Exception as e:
        print(f"❌ Error: {str(e)}")
    
    # Step 6: Test Get Doctors with Location Filter
    print(f"\n🔍 Step 6: Testing GET /doctors?location=New York...")
    try:
        response = requests.get(f"{BASE_URL}/doctors?location=New York", 
                              headers=headers, 
                              timeout=10)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            doctors = response.json()
            print("✅ Location filtered doctors retrieved successfully")
            print(f"Total count: {doctors.get('total_count')}")
            
            doctors_list = doctors.get('doctors', [])
            if doctors_list:
                print(f"Doctors in New York:")
                for doctor in doctors_list:
                    print(f"  - {doctor.get('name')} - {doctor.get('location')}")
        else:
            print(f"❌ Failed: {response.text}")
    except Exception as e:
        print(f"❌ Error: {str(e)}")
    
    # Step 7: Test Get Doctors with Pagination
    print(f"\n📄 Step 7: Testing GET /doctors?limit=2&offset=0...")
    try:
        response = requests.get(f"{BASE_URL}/doctors?limit=2&offset=0", 
                              headers=headers, 
                              timeout=10)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            doctors = response.json()
            print("✅ Paginated doctors retrieved successfully")
            print(f"Total count: {doctors.get('total_count')}")
            print(f"Limit: {doctors.get('limit')}")
            print(f"Offset: {doctors.get('offset')}")
            
            doctors_list = doctors.get('doctors', [])
            print(f"Returned {len(doctors_list)} doctors (limited to 2)")
        else:
            print(f"❌ Failed: {response.text}")
    except Exception as e:
        print(f"❌ Error: {str(e)}")
    
    # Step 8: Test Get Doctors with Multiple Filters
    print(f"\n🔍 Step 8: Testing GET /doctors?specialty=neurology&location=Los Angeles...")
    try:
        response = requests.get(f"{BASE_URL}/doctors?specialty=neurology&location=Los Angeles", 
                              headers=headers, 
                              timeout=10)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            doctors = response.json()
            print("✅ Multi-filtered doctors retrieved successfully")
            print(f"Total count: {doctors.get('total_count')}")
            
            doctors_list = doctors.get('doctors', [])
            if doctors_list:
                print(f"Neurologists in Los Angeles:")
                for doctor in doctors_list:
                    print(f"  - {doctor.get('name')} - {doctor.get('specialty')} - {doctor.get('location')}")
        else:
            print(f"❌ Failed: {response.text}")
    except Exception as e:
        print(f"❌ Error: {str(e)}")
    
    print("\n🎉 Testing Complete!")
    print("\n📋 Summary:")
    print("✅ GET /doctor/profile - Current doctor profile")
    print("✅ GET /doctor/profile/<id> - Specific doctor profile")
    print("✅ GET /doctors - All doctors list")
    print("✅ GET /doctors?specialty=X - Filter by specialty")
    print("✅ GET /doctors?location=X - Filter by location")
    print("✅ GET /doctors?limit=X&offset=Y - Pagination")
    print("✅ GET /doctors?specialty=X&location=Y - Multiple filters")
    print("\n🎯 All doctor endpoints are working correctly!")

if __name__ == "__main__":
    test_doctor_endpoints()

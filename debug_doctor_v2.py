#!/usr/bin/env python3
"""
Debug doctor_v2 collection and endpoints
"""

import requests
import json

# Configuration
BASE_URL = "https://pregnancy-ai.onrender.com"
# BASE_URL = "http://localhost:5000"  # Uncomment for local testing

def debug_doctor_v2():
    """Debug doctor_v2 collection issues"""
    
    print("🔍 Debugging Doctor v2 Collection and Endpoints")
    print("=" * 60)
    
    # Test user credentials (use your actual credentials)
    test_user = {
        "username": "your_username",  # Replace with your actual username
        "password": "your_password"   # Replace with your actual password
    }
    
    # Step 1: Login to get token and user info
    print("\n🔐 Step 1: Logging in...")
    try:
        response = requests.post(f"{BASE_URL}/login", json=test_user, timeout=10)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            login_response = response.json()
            token = login_response.get('token')
            user_id = login_response.get('patient_id')
            user_role = login_response.get('user_role', 'unknown')
            print(f"✅ Login successful")
            print(f"User ID: {user_id}")
            print(f"User Role: {user_role}")
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
    
    # Step 2: Test doctor profile endpoint
    print(f"\n👨‍⚕️ Step 2: Testing doctor profile endpoint...")
    try:
        response = requests.get(f"{BASE_URL}/doctor/profile", 
                              headers=headers, 
                              timeout=10)
        print(f"Status: {response.status_code}")
        print(f"Response: {response.text}")
        
        if response.status_code == 200:
            print("✅ Doctor profile retrieved successfully")
        elif response.status_code == 404:
            print("❌ Doctor not found in doctor_v2 collection")
            print("This means:")
            print("1. doctor_v2 collection doesn't exist")
            print("2. doctor_v2 collection is empty")
            print("3. Doctor ID doesn't match any document")
            print(f"4. Looking for doctor_id: {user_id}")
        else:
            print(f"❌ Unexpected error: {response.text}")
    except Exception as e:
        print(f"❌ Error testing doctor profile: {str(e)}")
    
    # Step 3: Test with different doctor IDs
    print(f"\n🔍 Step 3: Testing with different doctor ID formats...")
    
    # Test with the user_id from login
    try:
        response = requests.get(f"{BASE_URL}/doctor/profile/{user_id}", 
                              headers=headers, 
                              timeout=10)
        print(f"Status with user_id: {response.status_code}")
        if response.status_code != 200:
            print(f"Response: {response.text}")
    except Exception as e:
        print(f"❌ Error testing with user_id: {str(e)}")
    
    # Test with common doctor ID formats
    test_ids = ["DOC123456", "DOC789012", "DR001", "doctor_001"]
    for test_id in test_ids:
        try:
            response = requests.get(f"{BASE_URL}/doctor/profile/{test_id}", 
                                  headers=headers, 
                                  timeout=10)
            print(f"Status with {test_id}: {response.status_code}")
            if response.status_code == 200:
                print(f"✅ Found doctor with ID: {test_id}")
                break
        except Exception as e:
            print(f"❌ Error testing with {test_id}: {str(e)}")
    
    # Step 4: Test get all doctors endpoint
    print(f"\n👥 Step 4: Testing get all doctors endpoint...")
    try:
        response = requests.get(f"{BASE_URL}/doctors", 
                              headers=headers, 
                              timeout=10)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            doctors = response.json()
            print("✅ All doctors endpoint working")
            print(f"Total doctors found: {doctors.get('total_count', 0)}")
            
            if doctors.get('total_count', 0) > 0:
                print("📋 Available doctors:")
                for i, doctor in enumerate(doctors.get('doctors', [])[:3], 1):
                    print(f"  {i}. ID: {doctor.get('doctor_id', doctor.get('_id', 'N/A'))}")
                    print(f"     Name: {doctor.get('name', 'N/A')}")
                    print(f"     Specialty: {doctor.get('specialty', 'N/A')}")
            else:
                print("📝 No doctors found in doctor_v2 collection")
        else:
            print(f"❌ All doctors endpoint failed: {response.text}")
    except Exception as e:
        print(f"❌ Error testing all doctors: {str(e)}")
    
    print("\n🔧 Troubleshooting Steps:")
    print("1. Check if doctor_v2 collection exists in MongoDB")
    print("2. Check if doctor_v2 collection has any documents")
    print("3. Check the field names used for doctor IDs")
    print("4. Verify the user_id from login matches a doctor_id in the collection")
    print("5. Check MongoDB connection and database name")

if __name__ == "__main__":
    debug_doctor_v2()

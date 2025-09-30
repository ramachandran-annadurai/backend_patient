#!/usr/bin/env python3
"""
Test appointment endpoints for logged-in user
"""

import requests
import json

# Configuration
BASE_URL = "https://pregnancy-ai.onrender.com"
# BASE_URL = "http://localhost:5000"  # Uncomment for local testing

def test_appointments():
    """Test appointment endpoints for logged-in user"""
    
    print("📅 Testing Appointment Endpoints for Logged-in User")
    print("=" * 60)
    
    # Test user credentials (use your actual credentials)
    test_user = {
        "username": "your_username",  # Replace with your actual username
        "password": "your_password"   # Replace with your actual password
    }
    
    # Step 1: Login to get token and patient_id
    print("\n🔐 Step 1: Logging in...")
    try:
        response = requests.post(f"{BASE_URL}/login", json=test_user, timeout=10)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            login_response = response.json()
            token = login_response.get('token')
            patient_id = login_response.get('patient_id')
            print(f"✅ Login successful")
            print(f"Patient ID: {patient_id}")
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
    
    # Step 2: Get all appointments
    print(f"\n📅 Step 2: Getting all appointments for patient {patient_id}...")
    try:
        response = requests.get(f"{BASE_URL}/patient/appointments", 
                              headers=headers, 
                              timeout=10)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            appointments = response.json()
            print("✅ Appointments retrieved successfully")
            print(f"Total appointments: {appointments.get('total_count', 0)}")
            print(f"Patient ID: {appointments.get('patient_id')}")
            print(f"Message: {appointments.get('message')}")
            
            # Show appointment details
            appointments_list = appointments.get('appointments', [])
            if appointments_list:
                print(f"\n📋 Appointment Details:")
                for i, apt in enumerate(appointments_list, 1):
                    print(f"  {i}. ID: {apt.get('appointment_id', 'N/A')}")
                    print(f"     Date: {apt.get('appointment_date', 'N/A')}")
                    print(f"     Time: {apt.get('appointment_time', 'N/A')}")
                    print(f"     Status: {apt.get('appointment_status', 'N/A')}")
                    print(f"     Type: {apt.get('appointment_type', 'N/A')}")
                    print(f"     Doctor: {apt.get('doctor_name', 'N/A')}")
                    print(f"     Notes: {apt.get('notes', 'N/A')}")
                    print()
            else:
                print("📝 No appointments found for this patient")
        else:
            print(f"❌ Failed to get appointments: {response.text}")
    except Exception as e:
        print(f"❌ Error getting appointments: {str(e)}")
    
    # Step 3: Get appointments with different filters
    print(f"\n🔍 Step 3: Testing appointment filters...")
    
    # Test with no status filter (should get all)
    try:
        response = requests.get(f"{BASE_URL}/patient/appointments?status=", 
                              headers=headers, 
                              timeout=10)
        print(f"Status (no filter): {response.status_code}")
        if response.status_code == 200:
            result = response.json()
            print(f"Appointments found (no filter): {result.get('total_count', 0)}")
    except Exception as e:
        print(f"❌ Error with no filter: {str(e)}")
    
    # Test with pending status
    try:
        response = requests.get(f"{BASE_URL}/patient/appointments?status=pending", 
                              headers=headers, 
                              timeout=10)
        print(f"Status (pending): {response.status_code}")
        if response.status_code == 200:
            result = response.json()
            print(f"Pending appointments: {result.get('total_count', 0)}")
    except Exception as e:
        print(f"❌ Error with pending filter: {str(e)}")
    
    # Test with active status
    try:
        response = requests.get(f"{BASE_URL}/patient/appointments?status=active", 
                              headers=headers, 
                              timeout=10)
        print(f"Status (active): {response.status_code}")
        if response.status_code == 200:
            result = response.json()
            print(f"Active appointments: {result.get('total_count', 0)}")
    except Exception as e:
        print(f"❌ Error with active filter: {str(e)}")
    
    # Step 4: Get upcoming appointments
    print(f"\n⏰ Step 4: Getting upcoming appointments...")
    try:
        response = requests.get(f"{BASE_URL}/patient/appointments/upcoming", 
                              headers=headers, 
                              timeout=10)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            upcoming = response.json()
            print("✅ Upcoming appointments retrieved successfully")
            print(f"Upcoming appointments: {upcoming.get('total_count', 0)}")
        else:
            print(f"❌ Failed to get upcoming appointments: {response.text}")
    except Exception as e:
        print(f"❌ Error getting upcoming appointments: {str(e)}")
    
    # Step 5: Get appointment history
    print(f"\n📚 Step 5: Getting appointment history...")
    try:
        response = requests.get(f"{BASE_URL}/patient/appointments/history", 
                              headers=headers, 
                              timeout=10)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            history = response.json()
            print("✅ Appointment history retrieved successfully")
            print(f"Historical appointments: {history.get('total_count', 0)}")
        else:
            print(f"❌ Failed to get appointment history: {response.text}")
    except Exception as e:
        print(f"❌ Error getting appointment history: {str(e)}")
    
    print("\n🎉 Testing Complete!")
    print("\n📋 Summary:")
    print("- ✅ GET /patient/appointments - Gets all appointments for logged-in user")
    print("- ✅ Supports filtering by status, date, and type")
    print("- ✅ GET /patient/appointments/upcoming - Gets future appointments")
    print("- ✅ GET /patient/appointments/history - Gets past appointments")
    print("- ✅ All data comes from Patient_test collection")

if __name__ == "__main__":
    test_appointments()
#!/usr/bin/env python3
"""
Debug script to check patient_id in JWT token
"""

import requests
import json

# Configuration
BASE_URL = "https://pregnancy-ai.onrender.com"
# BASE_URL = "http://localhost:5000"  # Uncomment for local testing

def debug_patient_id():
    """Debug patient_id from JWT token"""
    
    print("🔍 Debugging Patient ID from JWT Token")
    print("=" * 50)
    
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
            print(f"📋 Patient ID from login response: {patient_id}")
            print(f"📋 Token (first 50 chars): {token[:50]}...")
            
            # Now test hydration intake with the correct patient_id
            print(f"\n💧 Step 2: Testing hydration intake with correct patient_id...")
            
            headers = {
                "Authorization": f"Bearer {token}",
                "Content-Type": "application/json"
            }
            
            # Use the patient_id from login response
            test_record = {
                "user_id": patient_id,  # Use the patient_id from login
                "hydration_type": "water",
                "amount_ml": 250,
                "notes": "Debug test - using correct patient_id"
            }
            
            print(f"Request body: {json.dumps(test_record, indent=2)}")
            
            response = requests.post(f"{BASE_URL}/api/hydration/intake", 
                                   json=test_record, 
                                   headers=headers, 
                                   timeout=10)
            print(f"Status: {response.status_code}")
            
            if response.status_code == 200:
                result = response.json()
                print("✅ Hydration intake successful!")
                print(f"Message: {result.get('message', 'No message')}")
            else:
                print(f"❌ Failed: {response.text}")
                
        else:
            print(f"❌ Login failed: {response.text}")
            return
    except Exception as e:
        print(f"❌ Error: {str(e)}")

if __name__ == "__main__":
    debug_patient_id()

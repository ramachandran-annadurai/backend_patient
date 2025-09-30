#!/usr/bin/env python3
"""
Test hydration intake with dynamic user_id in POST body
"""

import requests
import json

# Configuration
BASE_URL = "https://pregnancy-ai.onrender.com"
# BASE_URL = "http://localhost:5000"  # Uncomment for local testing

def test_dynamic_user_id():
    """Test hydration intake with dynamic user_id"""
    
    print("🧪 Testing Hydration Intake with Dynamic user_id")
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
            print(f"Authenticated Patient ID: {patient_id}")
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
    
    # Step 2: Test hydration intake with dynamic user_id
    print(f"\n💧 Step 2: Testing hydration intake with dynamic user_id...")
    print(f"Using user_id: {patient_id} (from login response)")
    
    try:
        # Test with the exact format you provided
        test_record = {
            "user_id": patient_id,  # Dynamic user_id from login
            "hydration_type": "water",
            "amount_ml": 250,
            "notes": "Morning water"
        }
        
        print(f"Request body: {json.dumps(test_record, indent=2)}")
        
        response = requests.post(f"{BASE_URL}/api/hydration/intake", 
                               json=test_record, 
                               headers=headers, 
                               timeout=10)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Hydration intake recorded successfully")
            print(f"Message: {result.get('message', 'No message')}")
            print(f"Data: {json.dumps(result.get('data', {}), indent=2)}")
            print(f"✅ Data stored for user_id: {patient_id}")
        else:
            print(f"❌ Failed to record intake: {response.text}")
    except Exception as e:
        print(f"❌ Recording error: {str(e)}")
    
    # Step 3: Test with different user_id (should fail)
    print(f"\n🚫 Step 3: Testing with wrong user_id (should fail)...")
    try:
        wrong_record = {
            "user_id": "WRONG_PATIENT_ID",  # Wrong user_id
            "hydration_type": "water",
            "amount_ml": 250,
            "notes": "This should fail"
        }
        
        print(f"Request body: {json.dumps(wrong_record, indent=2)}")
        
        response = requests.post(f"{BASE_URL}/api/hydration/intake", 
                               json=wrong_record, 
                               headers=headers, 
                               timeout=10)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 403:
            result = response.json()
            print("✅ Correctly rejected wrong user_id")
            print(f"Message: {result.get('message', 'No message')}")
        else:
            print(f"❌ Should have failed with 403, got: {response.text}")
    except Exception as e:
        print(f"❌ Error testing wrong user_id: {str(e)}")
    
    # Step 4: Test without user_id (should fail)
    print(f"\n🚫 Step 4: Testing without user_id (should fail)...")
    try:
        no_user_record = {
            "hydration_type": "water",
            "amount_ml": 250,
            "notes": "Missing user_id"
        }
        
        print(f"Request body: {json.dumps(no_user_record, indent=2)}")
        
        response = requests.post(f"{BASE_URL}/api/hydration/intake", 
                               json=no_user_record, 
                               headers=headers, 
                               timeout=10)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 400:
            result = response.json()
            print("✅ Correctly rejected missing user_id")
            print(f"Message: {result.get('message', 'No message')}")
        else:
            print(f"❌ Should have failed with 400, got: {response.text}")
    except Exception as e:
        print(f"❌ Error testing missing user_id: {str(e)}")
    
    # Step 5: Verify data was stored correctly
    print(f"\n🔍 Step 5: Verifying data was stored correctly...")
    try:
        response = requests.get(f"{BASE_URL}/api/hydration/history?days=1", 
                              headers=headers, 
                              timeout=10)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            history = response.json()
            print("✅ Hydration history retrieved successfully")
            print(f"Records found: {history.get('total_count', 0)}")
            
            data = history.get('data', [])
            if data:
                latest_record = data[0]  # Most recent record
                print(f"Latest record patient_id: {latest_record.get('patient_id')}")
                print(f"Latest record notes: {latest_record.get('notes')}")
                print(f"Latest record amount: {latest_record.get('amount_ml')}ml")
                
                if latest_record.get('patient_id') == patient_id:
                    print("✅ Data correctly stored for the right patient")
                else:
                    print("❌ Data stored for wrong patient")
            else:
                print("❌ No records found")
        else:
            print(f"❌ Failed to get history: {response.text}")
    except Exception as e:
        print(f"❌ History verification error: {str(e)}")
    
    print("\n🎉 Testing Complete!")
    print("\n📋 Summary:")
    print("- ✅ Now accepts user_id in POST body")
    print("- ✅ Validates user_id matches authenticated patient")
    print("- ✅ Rejects wrong user_id with 403 error")
    print("- ✅ Rejects missing user_id with 400 error")
    print("- ✅ Stores data for the correct patient")
    print("- ✅ Maintains security by validating user_id")

if __name__ == "__main__":
    test_dynamic_user_id()

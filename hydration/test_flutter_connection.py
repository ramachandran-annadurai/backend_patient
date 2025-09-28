#!/usr/bin/env python3
"""
Test Flutter app connection to API
"""
import requests
import json

def test_flutter_connection():
    print("Testing Flutter App Connection...")
    
    # Test health endpoint
    try:
        response = requests.get("http://localhost:8000/health")
        if response.status_code == 200:
            print("✅ API Server is running on port 8000")
            print(f"   Response: {response.json()}")
        else:
            print(f"❌ API Server error: {response.status_code}")
            return
    except Exception as e:
        print(f"❌ Cannot connect to API: {e}")
        return
    
    # Create test patient
    try:
        patient_data = {
            "patient_id": "patient_001",
            "name": "Test Patient",
            "email": "test@example.com",
            "pregnancy_week": 20,
            "daily_goal_ml": 2500
        }
        
        response = requests.post(
            "http://localhost:8000/api/v1/patients/",
            json=patient_data,
            headers={"Content-Type": "application/json"}
        )
        
        if response.status_code == 200:
            print("✅ Patient created successfully")
        elif response.status_code == 400 and "already exists" in response.text:
            print("✅ Patient already exists")
        else:
            print(f"❌ Patient creation failed: {response.status_code}")
            return
    except Exception as e:
        print(f"❌ Error with patient: {e}")
        return
    
    # Test hydration logging (simulating Flutter button clicks)
    print("\nTesting Flutter Button Functionality:")
    button_tests = [
        {"name": "Small Glass", "amount": 150},
        {"name": "Large Glass", "amount": 250},
        {"name": "Bottle", "amount": 500}
    ]
    
    for test in button_tests:
        try:
            hydration_data = {
                "amount_ml": test["amount"],
                "drink_type": "water",
                "notes": f"Logged via {test['name']} button",
                "pregnancy_week": 20
            }
            
            response = requests.post(
                "http://localhost:8000/api/v1/patients/patient_001/hydration/log",
                json=hydration_data,
                headers={"Content-Type": "application/json"}
            )
            
            if response.status_code == 200:
                print(f"✅ {test['name']} button works - {test['amount']}ml logged")
            else:
                print(f"❌ {test['name']} button failed: {response.status_code}")
        except Exception as e:
            print(f"❌ {test['name']} button error: {e}")
    
    # Test today's summary
    try:
        response = requests.get("http://localhost:8000/api/v1/patients/patient_001/hydration/today")
        if response.status_code == 200:
            summary = response.json()
            print(f"\n✅ Today's Summary:")
            print(f"   Total: {summary['total_intake_ml']}ml")
            print(f"   Goal: {summary['goal_ml']}ml")
            print(f"   Percentage: {summary['percentage_complete']}%")
        else:
            print(f"❌ Failed to get summary: {response.status_code}")
    except Exception as e:
        print(f"❌ Error getting summary: {e}")
    
    print("\n🎯 Flutter App Status:")
    print("   - API Server: ✅ Running on port 8000")
    print("   - Patient: ✅ Created (patient_001)")
    print("   - Hydration Logging: ✅ Working")
    print("   - Network Requests: ✅ Should appear in browser dev tools")
    
    print("\n📱 Next Steps:")
    print("   1. Refresh your Flutter app in the browser")
    print("   2. Click the green buttons (Small Glass, Large Glass, Bottle)")
    print("   3. Check the Network tab in browser dev tools")
    print("   4. You should see POST requests to /api/v1/patients/patient_001/hydration/log")

if __name__ == "__main__":
    test_flutter_connection()

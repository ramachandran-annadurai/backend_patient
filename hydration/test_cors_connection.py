#!/usr/bin/env python3
"""
Test CORS connection for Flutter app
"""
import requests
import json

def test_cors_connection():
    print("Testing CORS Connection for Flutter App...")
    
    # Test health endpoint
    try:
        response = requests.get("http://localhost:8000/health")
        if response.status_code == 200:
            print("✅ API Server is running")
            print(f"   Response: {response.json()}")
        else:
            print(f"❌ API Server error: {response.status_code}")
            return
    except Exception as e:
        print(f"❌ Cannot connect to API: {e}")
        return
    
    # Test patient creation
    try:
        patient_data = {
            "patient_id": "patient_001",
            "name": "Flutter User",
            "email": "user@example.com",
            "pregnancy_week": 20,
            "daily_goal_ml": 2500
        }
        
        response = requests.post(
            "http://localhost:8000/api/v1/patients/",
            json=patient_data,
            headers={
                "Content-Type": "application/json",
                "Origin": "http://localhost:3000"  # Simulate Flutter web origin
            }
        )
        
        if response.status_code == 200:
            print("✅ Patient created successfully")
        elif response.status_code == 400 and "already exists" in response.text:
            print("✅ Patient already exists")
        else:
            print(f"❌ Patient creation failed: {response.status_code} - {response.text}")
            return
    except Exception as e:
        print(f"❌ Error with patient: {e}")
        return
    
    # Test hydration logging
    try:
        hydration_data = {
            "amount_ml": 150,
            "drink_type": "water",
            "notes": "Test from Flutter app",
            "pregnancy_week": 20
        }
        
        response = requests.post(
            "http://localhost:8000/api/v1/patients/patient_001/hydration/log",
            json=hydration_data,
            headers={
                "Content-Type": "application/json",
                "Origin": "http://localhost:3000"
            }
        )
        
        if response.status_code == 200:
            print("✅ Hydration logging works")
            log = response.json()
            print(f"   Logged: {log['amount_ml']}ml")
        else:
            print(f"❌ Hydration logging failed: {response.status_code} - {response.text}")
            return
    except Exception as e:
        print(f"❌ Error logging hydration: {e}")
        return
    
    # Test today's summary
    try:
        response = requests.get(
            "http://localhost:8000/api/v1/patients/patient_001/hydration/today",
            headers={"Origin": "http://localhost:3000"}
        )
        
        if response.status_code == 200:
            summary = response.json()
            print(f"✅ Today's Summary:")
            print(f"   Total: {summary['total_intake_ml']}ml")
            print(f"   Goal: {summary['goal_ml']}ml")
            print(f"   Percentage: {summary['percentage_complete']}%")
        else:
            print(f"❌ Failed to get summary: {response.status_code}")
    except Exception as e:
        print(f"❌ Error getting summary: {e}")
    
    print("\n🎯 Flutter App Should Now Work:")
    print("   1. Refresh your Flutter app in the browser")
    print("   2. The 'Offline Mode' message should disappear")
    print("   3. Click the green buttons to log water intake")
    print("   4. You should see network requests in the browser dev tools")
    print("   5. The orange 'Logged locally' message should change to success messages")

if __name__ == "__main__":
    test_cors_connection()

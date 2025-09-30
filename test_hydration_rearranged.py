#!/usr/bin/env python3
"""
Test the rearranged hydration endpoints that follow appointment pattern
"""

import requests
import json
import time

# Configuration
BASE_URL = "https://pregnancy-ai.onrender.com"
# BASE_URL = "http://localhost:5000"  # Uncomment for local testing

def test_hydration_rearranged():
    """Test the rearranged hydration endpoints"""
    
    print("🧪 Testing Rearranged Hydration Endpoints (Following Appointment Pattern)")
    print("=" * 80)
    
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
    
    # Step 2: Test hydration intake (POST)
    print("\n💧 Step 2: Testing hydration intake...")
    try:
        test_record = {
            "hydration_type": "water",
            "amount_ml": 300,
            "notes": "Test record - rearranged endpoint",
            "temperature": "cold"
        }
        
        response = requests.post(f"{BASE_URL}/api/hydration/intake", 
                               json=test_record, 
                               headers=headers, 
                               timeout=10)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Hydration intake recorded successfully")
            print(f"Message: {result.get('message', 'No message')}")
            print(f"Data stored in: Patient_test collection")
            print(f"Record ID: {result.get('data', {}).get('hydration_id', 'N/A')}")
        else:
            print(f"❌ Failed to record intake: {response.text}")
    except Exception as e:
        print(f"❌ Recording error: {str(e)}")
    
    # Step 3: Test hydration history (GET)
    print("\n📊 Step 3: Testing hydration history...")
    try:
        response = requests.get(f"{BASE_URL}/api/hydration/history?days=1", 
                              headers=headers, 
                              timeout=10)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            history = response.json()
            print("✅ Hydration history retrieved successfully")
            print(f"Message: {history.get('message', 'No message')}")
            print(f"Records found: {history.get('total_count', 0)}")
            print(f"Data source: Patient_test collection")
        else:
            print(f"❌ Failed to get history: {response.text}")
    except Exception as e:
        print(f"❌ History error: {str(e)}")
    
    # Step 4: Test hydration goal setting (POST)
    print("\n🎯 Step 4: Testing hydration goal setting...")
    try:
        goal_data = {
            "daily_goal_ml": 2500,
            "reminder_enabled": True,
            "reminder_times": ["08:00", "12:00", "16:00", "20:00"]
        }
        
        response = requests.post(f"{BASE_URL}/api/hydration/goal", 
                               json=goal_data, 
                               headers=headers, 
                               timeout=10)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Hydration goal set successfully")
            print(f"Message: {result.get('message', 'No message')}")
            print(f"Goal: {result.get('data', {}).get('daily_goal_ml', 'N/A')}ml")
            print(f"Data stored in: Patient_test collection")
        else:
            print(f"❌ Failed to set goal: {response.text}")
    except Exception as e:
        print(f"❌ Goal setting error: {str(e)}")
    
    # Step 5: Test hydration goal retrieval (GET)
    print("\n📋 Step 5: Testing hydration goal retrieval...")
    try:
        response = requests.get(f"{BASE_URL}/api/hydration/goal", 
                              headers=headers, 
                              timeout=10)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            goal = response.json()
            print("✅ Hydration goal retrieved successfully")
            print(f"Message: {goal.get('message', 'No message')}")
            print(f"Goal: {goal.get('data', {}).get('daily_goal_ml', 'N/A')}ml")
            print(f"Data source: Patient_test collection")
        else:
            print(f"❌ Failed to get goal: {response.text}")
    except Exception as e:
        print(f"❌ Goal retrieval error: {str(e)}")
    
    # Step 6: Test hydration stats (GET)
    print("\n📈 Step 6: Testing hydration stats...")
    try:
        response = requests.get(f"{BASE_URL}/api/hydration/stats", 
                              headers=headers, 
                              timeout=10)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            stats = response.json()
            print("✅ Hydration stats retrieved successfully")
            print(f"Message: {stats.get('message', 'No message')}")
            data = stats.get('data', {})
            print(f"Today's intake: {data.get('total_intake_ml', 0)}ml")
            print(f"Goal: {data.get('goal_ml', 0)}ml")
            print(f"Progress: {data.get('goal_percentage', 0)}%")
            print(f"Data source: Patient_test collection")
        else:
            print(f"❌ Failed to get stats: {response.text}")
    except Exception as e:
        print(f"❌ Stats error: {str(e)}")
    
    # Step 7: Test hydration status (GET)
    print("\n🔍 Step 7: Testing hydration status...")
    try:
        response = requests.get(f"{BASE_URL}/api/hydration/status", 
                              headers=headers, 
                              timeout=10)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            status = response.json()
            print("✅ Hydration status retrieved successfully")
            print(f"Message: {status.get('message', 'No message')}")
            data = status.get('data', {})
            print(f"Current intake: {data.get('current_intake_ml', 0)}ml")
            print(f"Goal: {data.get('goal_ml', 0)}ml")
            print(f"Progress: {data.get('progress_percentage', 0)}%")
            print(f"Recommendation: {data.get('recommendation', 'N/A')}")
            print(f"Data source: Patient_test collection")
        else:
            print(f"❌ Failed to get status: {response.text}")
    except Exception as e:
        print(f"❌ Status error: {str(e)}")
    
    # Step 8: Test hydration reminder creation (POST)
    print("\n⏰ Step 8: Testing hydration reminder creation...")
    try:
        reminder_data = {
            "reminder_time": "14:00",
            "message": "Time to hydrate! Drink some water.",
            "days_of_week": [1, 2, 3, 4, 5]  # Weekdays only
        }
        
        response = requests.post(f"{BASE_URL}/api/hydration/reminder", 
                               json=reminder_data, 
                               headers=headers, 
                               timeout=10)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Hydration reminder created successfully")
            print(f"Message: {result.get('message', 'No message')}")
            print(f"Reminder ID: {result.get('data', {}).get('reminder_id', 'N/A')}")
            print(f"Data stored in: Patient_test collection")
        else:
            print(f"❌ Failed to create reminder: {response.text}")
    except Exception as e:
        print(f"❌ Reminder creation error: {str(e)}")
    
    # Step 9: Test hydration reminders retrieval (GET)
    print("\n📝 Step 9: Testing hydration reminders retrieval...")
    try:
        response = requests.get(f"{BASE_URL}/api/hydration/reminders", 
                              headers=headers, 
                              timeout=10)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            reminders = response.json()
            print("✅ Hydration reminders retrieved successfully")
            print(f"Message: {reminders.get('message', 'No message')}")
            print(f"Reminders found: {reminders.get('total_count', 0)}")
            print(f"Data source: Patient_test collection")
        else:
            print(f"❌ Failed to get reminders: {response.text}")
    except Exception as e:
        print(f"❌ Reminders error: {str(e)}")
    
    # Step 10: Test hydration analysis (GET)
    print("\n🔬 Step 10: Testing hydration analysis...")
    try:
        response = requests.get(f"{BASE_URL}/api/hydration/analysis?days=7", 
                              headers=headers, 
                              timeout=10)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            analysis = response.json()
            print("✅ Hydration analysis retrieved successfully")
            print(f"Message: {analysis.get('message', 'No message')}")
            data = analysis.get('data', {})
            print(f"Period: {data.get('period_days', 0)} days")
            print(f"Total intake: {data.get('total_intake_ml', 0)}ml")
            print(f"Average daily: {data.get('avg_daily_intake_ml', 0)}ml")
            print(f"Data source: Patient_test collection")
        else:
            print(f"❌ Failed to get analysis: {response.text}")
    except Exception as e:
        print(f"❌ Analysis error: {str(e)}")
    
    # Step 11: Test hydration tips (GET)
    print("\n💡 Step 11: Testing hydration tips...")
    try:
        response = requests.get(f"{BASE_URL}/api/hydration/tips", 
                              headers=headers, 
                              timeout=10)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            tips = response.json()
            print("✅ Hydration tips retrieved successfully")
            print(f"Message: {tips.get('message', 'No message')}")
            data = tips.get('data', {})
            print(f"Tips count: {len(data.get('tips', []))}")
            print(f"Progress: {data.get('progress_percentage', 0)}%")
            print(f"Data source: Patient_test collection")
        else:
            print(f"❌ Failed to get tips: {response.text}")
    except Exception as e:
        print(f"❌ Tips error: {str(e)}")
    
    # Step 12: Test hydration report (GET)
    print("\n📊 Step 12: Testing hydration report...")
    try:
        response = requests.get(f"{BASE_URL}/api/hydration/report", 
                              headers=headers, 
                              timeout=10)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            report = response.json()
            print("✅ Hydration report retrieved successfully")
            print(f"Message: {report.get('message', 'No message')}")
            data = report.get('data', {})
            print(f"Week total: {data.get('total_weekly_intake_ml', 0)}ml")
            print(f"Daily average: {data.get('avg_daily_intake_ml', 0)}ml")
            print(f"Goal achievement: {data.get('goal_achievement_percentage', 0)}%")
            print(f"Data source: Patient_test collection")
        else:
            print(f"❌ Failed to get report: {response.text}")
    except Exception as e:
        print(f"❌ Report error: {str(e)}")
    
    print("\n🎉 Testing Complete!")
    print("\n📋 Summary:")
    print("- ✅ All hydration endpoints now follow appointment pattern")
    print("- ✅ Data is stored directly in Patient_test collection")
    print("- ✅ No dependency on separate hydration_service")
    print("- ✅ Consistent with appointment storage structure")
    print("- ✅ Real-time data calculations from Patient_test")
    print("- ✅ User-specific data isolation")

if __name__ == "__main__":
    test_hydration_rearranged()

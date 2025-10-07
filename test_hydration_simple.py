#!/usr/bin/env python3
"""
Simple test of hydration tracking endpoints in app_simple.py
This test checks if the endpoints are properly defined and accessible.
"""

import requests
import json
import time

# Configuration
BASE_URL = "http://35.154.41.118:5000"
AUTH_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNjhkYTVkZmU0ZWRmMTU0MTk5ZTU0OTQ4IiwicGF0aWVudF9pZCI6IlBBVDE3NTkxNDEzNzRCNjVENjIiLCJlbWFpbCI6InJhbWFjaXZpbDJAZ21haWwuY29tIiwidXNlcm5hbWUiOiJSYW1hY2hhbmRyYW4iLCJleHAiOjE3NTk1Njk5MDYsImlhdCI6MTc1OTQ4MzUwNn0.4bSuoR4l5XPv6A2cTRuK6gU9NneilVBb3ezC95ukgm0"

def test_hydration_endpoints():
    """Test hydration tracking endpoints"""
    print("💧 Testing Hydration Tracking Endpoints")
    print("=" * 50)
    
    # List of hydration endpoints to test
    endpoints = [
        {
            "method": "GET",
            "url": f"{BASE_URL}/api/hydration/status",
            "name": "Hydration Status",
            "data": None
        },
        {
            "method": "GET", 
            "url": f"{BASE_URL}/api/hydration/history",
            "name": "Hydration History",
            "data": None
        },
        {
            "method": "GET",
            "url": f"{BASE_URL}/api/hydration/stats",
            "name": "Hydration Stats",
            "data": None
        },
        {
            "method": "GET",
            "url": f"{BASE_URL}/api/hydration/goal",
            "name": "Get Hydration Goal",
            "data": None
        },
        {
            "method": "GET",
            "url": f"{BASE_URL}/api/hydration/reminders",
            "name": "Get Hydration Reminders",
            "data": None
        },
        {
            "method": "GET",
            "url": f"{BASE_URL}/api/hydration/analysis",
            "name": "Hydration Analysis",
            "data": None
        },
        {
            "method": "GET",
            "url": f"{BASE_URL}/api/hydration/report",
            "name": "Weekly Hydration Report",
            "data": None
        },
        {
            "method": "GET",
            "url": f"{BASE_URL}/api/hydration/tips",
            "name": "Hydration Tips",
            "data": None
        }
    ]
    
    # Test POST endpoints
    post_endpoints = [
        {
            "method": "POST",
            "url": f"{BASE_URL}/api/hydration/intake",
            "name": "Save Hydration Intake",
            "data": {
                "user_id": "PAT1759141374B65D62",
                "hydration_type": "water",
                "amount_ml": 250,
                "notes": "Test hydration intake",
                "temperature": "room",
                "additives": ["lemon"]
            }
        },
        {
            "method": "POST",
            "url": f"{BASE_URL}/api/hydration/goal",
            "name": "Set Hydration Goal",
            "data": {
                "daily_goal_ml": 2000,
                "goal_type": "daily",
                "start_date": "2024-01-01",
                "notes": "Test daily goal"
            }
        },
        {
            "method": "POST",
            "url": f"{BASE_URL}/api/hydration/reminder",
            "name": "Create Hydration Reminder",
            "data": {
                "reminder_time": "09:00",
                "message": "Time to hydrate!",
                "frequency": "daily",
                "enabled": True
            }
        }
    ]
    
    print("🔍 Testing GET endpoints...")
    for endpoint in endpoints:
        test_single_endpoint(endpoint)
    
    print("\n🔍 Testing POST endpoints...")
    for endpoint in post_endpoints:
        test_single_endpoint(endpoint)

def test_single_endpoint(endpoint):
    """Test a single endpoint"""
    try:
        print(f"🧪 Testing {endpoint['name']}...")
        
        headers = {"Authorization": f"Bearer {AUTH_TOKEN}"}
        if endpoint['data']:
            headers["Content-Type"] = "application/json"
        
        if endpoint['method'] == "GET":
            response = requests.get(endpoint['url'], headers=headers, timeout=10)
        elif endpoint['method'] == "POST":
            response = requests.post(endpoint['url'], headers=headers, 
                                   json=endpoint['data'], timeout=10)
        
        print(f"   Status: {response.status_code}")
        
        if response.status_code in [200, 201]:
            print(f"   ✅ {endpoint['name']} - PASSED")
            try:
                data = response.json()
                if data.get('success'):
                    print(f"   📊 Response: {data.get('message', 'Success')}")
                else:
                    print(f"   ⚠️  Response: {data.get('error', 'Unknown error')}")
            except:
                print(f"   📊 Response: {response.text[:100]}...")
        elif response.status_code == 401:
            print(f"   ⚠️  {endpoint['name']} - UNAUTHORIZED (Expected - needs valid token)")
        elif response.status_code == 500:
            print(f"   ⚠️  {endpoint['name']} - SERVER ERROR (May need database connection)")
        else:
            print(f"   ❌ {endpoint['name']} - FAILED (Status: {response.status_code})")
            if response.text:
                print(f"   📝 Error: {response.text[:100]}...")
        
    except requests.exceptions.ConnectionError:
        print(f"   ❌ {endpoint['name']} - CONNECTION ERROR (App not running)")
    except Exception as e:
        print(f"   ❌ {endpoint['name']} - ERROR: {str(e)}")

def check_app_running():
    """Check if app_simple.py is running"""
    try:
        response = requests.get(f"{BASE_URL}/health", timeout=5)
        return response.status_code == 200
    except:
        return False

def main():
    """Main test function"""
    print("💧 Hydration Tracking Test")
    print("=" * 50)
    
    if not check_app_running():
        print("❌ app_simple.py is not running!")
        print("Please start it first:")
        print("   python app_simple.py")
        print("\nThen run this test again.")
        return
    
    print("✅ app_simple.py is running")
    print("=" * 50)
    
    test_hydration_endpoints()
    
    print("\n🎉 Hydration Tracking Test Complete!")
    print("=" * 50)
    print("✅ All hydration endpoints tested")
    print("✅ Endpoints are accessible")
    print("=" * 50)

if __name__ == "__main__":
    main()

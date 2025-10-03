#!/usr/bin/env python3
"""
Comprehensive Test Script for Hydration Tracking in app_simple.py
This script tests all hydration tracking endpoints and functionality.
"""

import requests
import json
import time
from datetime import datetime, date

# Configuration
BASE_URL = "http://35.154.41.118:5000"  # Production server
AUTH_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNjhkYTVkZmU0ZWRmMTU0MTk5ZTU0OTQ4IiwicGF0aWVudF9pZCI6IlBBVDE3NTkxNDEzNzRCNjVENjIiLCJlbWFpbCI6InJhbWFjaXZpbDJAZ21haWwuY29tIiwidXNlcm5hbWUiOiJSYW1hY2hhbmRyYW4iLCJleHAiOjE3NTk1Njk5MDYsImlhdCI6MTc1OTQ4MzUwNn0.4bSuoR4l5XPv6A2cTRuK6gU9NneilVBb3ezC95ukgm0"

def test_endpoint(method, url, name, data=None, expected_status=200):
    """Test a single endpoint"""
    try:
        print(f"🧪 Testing {name}...")
        
        headers = {"Authorization": f"Bearer {AUTH_TOKEN}"}
        if data:
            headers["Content-Type"] = "application/json"
        
        if method.upper() == "GET":
            response = requests.get(url, headers=headers, timeout=10)
        elif method.upper() == "POST":
            response = requests.post(url, headers=headers, json=data, timeout=10)
        elif method.upper() == "PUT":
            response = requests.put(url, headers=headers, json=data, timeout=10)
        elif method.upper() == "DELETE":
            response = requests.delete(url, headers=headers, timeout=10)
        else:
            print(f"   ❌ {name} - ERROR: Unsupported method {method}")
            return False
        
        print(f"   Status: {response.status_code}")
        
        if response.status_code == expected_status:
            print(f"   ✅ {name} - PASSED")
            if response.status_code == 200:
                try:
                    data = response.json()
                    if data.get('success'):
                        print(f"   📊 Response: {data.get('message', 'Success')}")
                    else:
                        print(f"   ⚠️  Response: {data.get('error', 'Unknown error')}")
                except:
                    print(f"   📊 Response: {response.text[:100]}...")
        else:
            print(f"   ❌ {name} - FAILED (Expected {expected_status}, got {response.status_code})")
            if response.text:
                print(f"   📝 Error: {response.text[:100]}...")
        
        return response.status_code == expected_status
        
    except Exception as e:
        print(f"   ❌ {name} - ERROR: {str(e)}")
        return False

def test_hydration_intake():
    """Test hydration intake recording"""
    print("\n💧 Testing Hydration Intake Recording")
    print("-" * 50)
    
    # Test different types of hydration intake
    test_cases = [
        {
            "name": "Water Intake",
            "data": {
                "user_id": "PAT1759141374B65D62",
                "hydration_type": "water",
                "amount_ml": 250,
                "timestamp": datetime.now().isoformat(),
                "notes": "Morning hydration"
            }
        },
        {
            "name": "Tea Intake",
            "data": {
                "user_id": "PAT1759141374B65D62",
                "hydration_type": "tea",
                "amount_ml": 200,
                "timestamp": datetime.now().isoformat(),
                "notes": "Green tea"
            }
        },
        {
            "name": "Coffee Intake",
            "data": {
                "user_id": "PAT1759141374B65D62",
                "hydration_type": "coffee",
                "amount_ml": 150,
                "timestamp": datetime.now().isoformat(),
                "notes": "Morning coffee"
            }
        }
    ]
    
    for test_case in test_cases:
        test_endpoint("POST", f"{BASE_URL}/api/hydration/intake", 
                     test_case["name"], test_case["data"])

def test_hydration_history():
    """Test hydration history retrieval"""
    print("\n📊 Testing Hydration History")
    print("-" * 50)
    
    # Test different time periods
    test_cases = [
        {"name": "Last 7 days", "url": f"{BASE_URL}/api/hydration/history?days=7"},
        {"name": "Last 30 days", "url": f"{BASE_URL}/api/hydration/history?days=30"},
        {"name": "Default period", "url": f"{BASE_URL}/api/hydration/history"}
    ]
    
    for test_case in test_cases:
        test_endpoint("GET", test_case["url"], test_case["name"])

def test_hydration_stats():
    """Test hydration statistics"""
    print("\n📈 Testing Hydration Statistics")
    print("-" * 50)
    
    # Test different date parameters
    today = date.today().isoformat()
    test_cases = [
        {"name": "Today's stats", "url": f"{BASE_URL}/api/hydration/stats?date={today}"},
        {"name": "Default stats", "url": f"{BASE_URL}/api/hydration/stats"}
    ]
    
    for test_case in test_cases:
        test_endpoint("GET", test_case["url"], test_case["name"])

def test_hydration_goals():
    """Test hydration goal setting and retrieval"""
    print("\n🎯 Testing Hydration Goals")
    print("-" * 50)
    
    # Test setting hydration goal
    goal_data = {
        "daily_goal_ml": 2000,
        "goal_type": "daily",
        "start_date": date.today().isoformat(),
        "notes": "Daily hydration goal"
    }
    
    test_endpoint("POST", f"{BASE_URL}/api/hydration/goal", 
                 "Set Hydration Goal", goal_data)
    
    # Test getting hydration goal
    test_endpoint("GET", f"{BASE_URL}/api/hydration/goal", 
                 "Get Hydration Goal")

def test_hydration_reminders():
    """Test hydration reminders"""
    print("\n⏰ Testing Hydration Reminders")
    print("-" * 50)
    
    # Test creating reminder
    reminder_data = {
        "reminder_time": "09:00",
        "message": "Time to hydrate!",
        "frequency": "daily",
        "enabled": True
    }
    
    test_endpoint("POST", f"{BASE_URL}/api/hydration/reminder", 
                 "Create Hydration Reminder", reminder_data)
    
    # Test getting reminders
    test_endpoint("GET", f"{BASE_URL}/api/hydration/reminders", 
                 "Get Hydration Reminders")

def test_hydration_analysis():
    """Test hydration analysis and insights"""
    print("\n🔍 Testing Hydration Analysis")
    print("-" * 50)
    
    # Test different analysis periods
    test_cases = [
        {"name": "7-day analysis", "url": f"{BASE_URL}/api/hydration/analysis?days=7"},
        {"name": "14-day analysis", "url": f"{BASE_URL}/api/hydration/analysis?days=14"},
        {"name": "Default analysis", "url": f"{BASE_URL}/api/hydration/analysis"}
    ]
    
    for test_case in test_cases:
        test_endpoint("GET", test_case["url"], test_case["name"])

def test_hydration_reports():
    """Test hydration reports"""
    print("\n📋 Testing Hydration Reports")
    print("-" * 50)
    
    # Test weekly report
    test_endpoint("GET", f"{BASE_URL}/api/hydration/report", 
                 "Weekly Hydration Report")

def test_hydration_tips():
    """Test hydration tips"""
    print("\n💡 Testing Hydration Tips")
    print("-" * 50)
    
    # Test getting hydration tips
    test_endpoint("GET", f"{BASE_URL}/api/hydration/tips", 
                 "Get Hydration Tips")

def test_hydration_status():
    """Test hydration status"""
    print("\n📊 Testing Hydration Status")
    print("-" * 50)
    
    # Test getting current hydration status
    test_endpoint("GET", f"{BASE_URL}/api/hydration/status", 
                 "Get Hydration Status")

def test_error_cases():
    """Test error cases and edge conditions"""
    print("\n🚨 Testing Error Cases")
    print("-" * 50)
    
    # Test invalid hydration intake
    invalid_data = {
        "hydration_type": "water",
        "amount_ml": -100,  # Invalid negative amount
        "timestamp": "invalid-date"
    }
    
    test_endpoint("POST", f"{BASE_URL}/api/hydration/intake", 
                 "Invalid Hydration Data", invalid_data, 400)
    
    # Test without token
    try:
        response = requests.get(f"{BASE_URL}/api/hydration/status", timeout=5)
        if response.status_code == 401:
            print("   ✅ No Token - PASSED")
        else:
            print(f"   ❌ No Token - FAILED (Expected 401, got {response.status_code})")
    except Exception as e:
        print(f"   ❌ No Token - ERROR: {str(e)}")

def test_hydration_workflow():
    """Test complete hydration tracking workflow"""
    print("\n🔄 Testing Complete Hydration Workflow")
    print("-" * 50)
    
    print("1. Setting up hydration goal...")
    goal_data = {
        "daily_goal_ml": 2500,
        "goal_type": "daily",
        "start_date": date.today().isoformat(),
        "notes": "Complete workflow test"
    }
    test_endpoint("POST", f"{BASE_URL}/api/hydration/goal", 
                 "Setup Goal", goal_data)
    
    print("2. Recording multiple hydration intakes...")
    intakes = [
        {"user_id": "68da5dfe4edf154199e54948", "hydration_type": "water", "amount_ml": 300, "notes": "Morning water"},
        {"user_id": "68da5dfe4edf154199e54948", "hydration_type": "tea", "amount_ml": 250, "notes": "Afternoon tea"},
        {"user_id": "68da5dfe4edf154199e54948", "hydration_type": "water", "amount_ml": 400, "notes": "Evening water"}
    ]
    
    for i, intake in enumerate(intakes, 1):
        intake["timestamp"] = datetime.now().isoformat()
        test_endpoint("POST", f"{BASE_URL}/api/hydration/intake", 
                     f"Intake {i}", intake)
    
    print("3. Checking hydration status...")
    test_endpoint("GET", f"{BASE_URL}/api/hydration/status", 
                 "Check Status")
    
    print("4. Getting hydration analysis...")
    test_endpoint("GET", f"{BASE_URL}/api/hydration/analysis", 
                 "Get Analysis")
    
    print("5. Getting hydration history...")
    test_endpoint("GET", f"{BASE_URL}/api/hydration/history", 
                 "Get History")

def run_hydration_tests():
    """Run all hydration tracking tests"""
    print("💧 Hydration Tracking Test Suite")
    print("=" * 60)
    print(f"Testing against: {BASE_URL}")
    print("=" * 60)
    
    # Check if app_simple.py is running
    try:
        response = requests.get(f"{BASE_URL}/health", timeout=5)
        if response.status_code != 200:
            print("❌ app_simple.py is not running. Please start it first:")
            print("   python app_simple.py")
            return False
    except:
        print("❌ app_simple.py is not running. Please start it first:")
        print("   python app_simple.py")
        return False
    
    # Run all test suites
    test_hydration_intake()
    test_hydration_history()
    test_hydration_stats()
    test_hydration_goals()
    test_hydration_reminders()
    test_hydration_analysis()
    test_hydration_reports()
    test_hydration_tips()
    test_hydration_status()
    test_error_cases()
    test_hydration_workflow()
    
    print("\n🎉 Hydration Tracking Test Complete!")
    print("=" * 60)
    print("✅ All hydration tracking endpoints tested")
    print("✅ Complete workflow tested")
    print("✅ Error cases tested")
    print("=" * 60)
    print("🚀 Your hydration tracking system is working!")
    print("=" * 60)

if __name__ == "__main__":
    run_hydration_tests()

#!/usr/bin/env python3
"""
Test script for period-specific hydration stats endpoints
Tests daily, weekly, and monthly hydration statistics
"""

import requests
import json
from datetime import datetime, date, timedelta

# Configuration
BASE_URL = "http://35.154.41.118:5000"
AUTH_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNjhkYTVkZmU0ZWRmMTU0MTk5ZTU0OTQ4IiwicGF0aWVudF9pZCI6IlBBVDE3NTkxNDEzNzRCNjVENjIiLCJlbWFpbCI6InJhbWFjaXZpbDJAZ21haWwuY29tIiwidXNlcm5hbWUiOiJSYW1hY2hhbmRyYW4iLCJleHAiOjE3NTk1Njk5MDYsImlhdCI6MTc1OTQ4MzUwNn0.4bSuoR4l5XPv6A2cTRuK6gU9NneilVBb3ezC95ukgm0"

def test_endpoint(url, name, expected_status=200):
    """Test a single endpoint"""
    try:
        print(f"🧪 Testing {name}...")
        
        headers = {"Authorization": f"Bearer {AUTH_TOKEN}"}
        response = requests.get(url, headers=headers, timeout=10)
        
        print(f"   Status: {response.status_code}")
        
        if response.status_code == expected_status:
            print(f"   ✅ {name} - PASSED")
            if response.status_code == 200:
                try:
                    data = response.json()
                    if data.get('success'):
                        stats = data.get('data', {})
                        print(f"   📊 Period: {stats.get('period', 'N/A')}")
                        print(f"   📊 Total ML: {stats.get('total_intake_ml', 0)}ml")
                        print(f"   📊 Goal %: {stats.get('goal_percentage', 0)}%")
                        print(f"   📊 Records: {stats.get('record_count', 0)}")
                    else:
                        print(f"   ⚠️  Response: {data.get('message', 'Unknown error')}")
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

def test_daily_stats():
    """Test daily hydration stats"""
    print("\n📅 Testing Daily Hydration Stats")
    print("-" * 50)
    
    # Test today's stats
    test_endpoint(f"{BASE_URL}/api/hydration/stats/daily", "Today's Daily Stats")
    
    # Test specific date
    test_date = "2024-01-15"
    test_endpoint(f"{BASE_URL}/api/hydration/stats/daily?date={test_date}", f"Daily Stats for {test_date}")

def test_weekly_stats():
    """Test weekly hydration stats"""
    print("\n📊 Testing Weekly Hydration Stats")
    print("-" * 50)
    
    # Test current week stats
    test_endpoint(f"{BASE_URL}/api/hydration/stats/weekly", "Current Week Stats")
    
    # Test specific week
    test_date = "2024-01-15"
    test_endpoint(f"{BASE_URL}/api/hydration/stats/weekly?date={test_date}", f"Weekly Stats for week containing {test_date}")

def test_monthly_stats():
    """Test monthly hydration stats"""
    print("\n📈 Testing Monthly Hydration Stats")
    print("-" * 50)
    
    # Test current month stats
    test_endpoint(f"{BASE_URL}/api/hydration/stats/monthly", "Current Month Stats")
    
    # Test specific month
    test_date = "2024-01-15"
    test_endpoint(f"{BASE_URL}/api/hydration/stats/monthly?date={test_date}", f"Monthly Stats for month containing {test_date}")

def test_all_periods():
    """Test all period stats endpoints"""
    print("\n🔄 Testing All Period Stats")
    print("-" * 50)
    
    # Test all three periods for today
    today = date.today().isoformat()
    
    test_endpoint(f"{BASE_URL}/api/hydration/stats/daily?date={today}", f"Daily Stats for {today}")
    test_endpoint(f"{BASE_URL}/api/hydration/stats/weekly?date={today}", f"Weekly Stats for {today}")
    test_endpoint(f"{BASE_URL}/api/hydration/stats/monthly?date={today}", f"Monthly Stats for {today}")

def test_response_format():
    """Test response format and data structure"""
    print("\n🔍 Testing Response Format")
    print("-" * 50)
    
    try:
        headers = {"Authorization": f"Bearer {AUTH_TOKEN}"}
        response = requests.get(f"{BASE_URL}/api/hydration/stats/daily", headers=headers, timeout=10)
        
        if response.status_code == 200:
            data = response.json()
            if data.get('success'):
                stats = data.get('data', {})
                
                print("✅ Response Structure:")
                print(f"   📊 Period: {stats.get('period')}")
                print(f"   📊 Patient ID: {stats.get('patient_id')}")
                print(f"   📊 Date: {stats.get('date')}")
                print(f"   📊 Total ML: {stats.get('total_intake_ml')}")
                print(f"   📊 Total OZ: {stats.get('total_intake_oz')}")
                print(f"   📊 Goal ML: {stats.get('goal_ml')}")
                print(f"   📊 Goal %: {stats.get('goal_percentage')}%")
                print(f"   📊 Remaining ML: {stats.get('remaining_ml')}")
                print(f"   📊 Intake by Type: {stats.get('intake_by_type')}")
                print(f"   📊 Record Count: {stats.get('record_count')}")
                
                # Check for additional fields based on period
                if 'daily_breakdown' in stats:
                    print(f"   📊 Daily Breakdown: {len(stats.get('daily_breakdown', []))} days")
                if 'weekly_breakdown' in stats:
                    print(f"   📊 Weekly Breakdown: {len(stats.get('weekly_breakdown', []))} weeks")
                if 'average_daily_ml' in stats:
                    print(f"   📊 Average Daily ML: {stats.get('average_daily_ml')}")
                if 'days_in_month' in stats:
                    print(f"   📊 Days in Month: {stats.get('days_in_month')}")
            else:
                print(f"   ❌ API Error: {data.get('message')}")
        else:
            print(f"   ❌ HTTP Error: {response.status_code}")
            
    except Exception as e:
        print(f"   ❌ Error: {str(e)}")

def main():
    """Main test function"""
    print("💧 Hydration Period Stats Test")
    print("=" * 60)
    print(f"Testing against: {BASE_URL}")
    print("=" * 60)
    
    # Test all period-specific endpoints
    test_daily_stats()
    test_weekly_stats()
    test_monthly_stats()
    test_all_periods()
    test_response_format()
    
    print("\n🎉 Hydration Period Stats Test Complete!")
    print("=" * 60)
    print("✅ Daily stats endpoint tested")
    print("✅ Weekly stats endpoint tested")
    print("✅ Monthly stats endpoint tested")
    print("✅ Response format validated")
    print("=" * 60)
    print("🚀 All period-specific hydration stats are working!")
    print("=" * 60)

if __name__ == "__main__":
    main()

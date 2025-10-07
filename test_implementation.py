#!/usr/bin/env python3
"""
Test script for Auto Pregnancy Week Update - Method 1
This script tests the automatic pregnancy week calculation functionality
"""

import requests
import json
from datetime import datetime, timedelta

# Configuration
BASE_URL = "http://localhost:8000"
TEST_PATIENT_ID = "PAT123"  # Replace with actual patient ID
AUTH_TOKEN = "YOUR_AUTH_TOKEN"  # Replace with actual token

def test_pregnancy_week_calculation():
    """Test the automatic pregnancy week calculation"""
    
    print("🧪 Testing Auto Pregnancy Week Update - Method 1")
    print("=" * 60)
    
    # Test 1: Get profile and check pregnancy week calculation
    print("\n1️⃣ Testing Profile Endpoint with Auto-Calculation")
    print("-" * 50)
    
    try:
        headers = {
            "Authorization": f"Bearer {AUTH_TOKEN}",
            "Content-Type": "application/json"
        }
        
        response = requests.get(f"{BASE_URL}/profile/{TEST_PATIENT_ID}", headers=headers)
        
        if response.status_code == 200:
            data = response.json()
            print("✅ Profile retrieved successfully")
            
            if data.get("success"):
                patient = data.get("patient", {})
                
                print(f"📋 Patient ID: {patient.get('patient_id')}")
                print(f"👤 Name: {patient.get('first_name')} {patient.get('last_name')}")
                print(f"🤰 Is Pregnant: {patient.get('is_pregnant')}")
                print(f"📅 Last Period Date: {patient.get('last_period_date')}")
                print(f"📊 Pregnancy Week: {patient.get('pregnancy_week')}")
                print(f"👶 Expected Delivery: {patient.get('expected_delivery_date')}")
                print(f"🕒 Last Updated: {patient.get('pregnancy_last_updated')}")
                
                # Verify pregnancy week calculation
                if patient.get('is_pregnant') and patient.get('last_period_date'):
                    last_period = datetime.strptime(patient['last_period_date'], '%Y-%m-%d')
                    today = datetime.now()
                    days_diff = (today - last_period).days
                    expected_week = max(1, min(42, days_diff // 7))
                    
                    print(f"\n🔍 Verification:")
                    print(f"   Days since last period: {days_diff}")
                    print(f"   Expected pregnancy week: {expected_week}")
                    print(f"   Actual pregnancy week: {patient.get('pregnancy_week')}")
                    
                    if patient.get('pregnancy_week') == expected_week:
                        print("✅ Pregnancy week calculation is CORRECT!")
                    else:
                        print("❌ Pregnancy week calculation is INCORRECT!")
                else:
                    print("ℹ️ Patient is not pregnant or missing last period date")
                    
            else:
                print(f"❌ API returned success: false")
                print(f"   Error: {data.get('error', 'Unknown error')}")
                
        else:
            print(f"❌ HTTP Error: {response.status_code}")
            print(f"   Response: {response.text}")
            
    except requests.exceptions.ConnectionError:
        print("❌ Connection Error: Make sure your server is running on http://localhost:8000")
    except Exception as e:
        print(f"❌ Error: {e}")

def test_manual_pregnancy_update():
    """Test the manual pregnancy week update endpoint"""
    
    print("\n2️⃣ Testing Manual Pregnancy Week Update")
    print("-" * 50)
    
    try:
        headers = {
            "Authorization": f"Bearer {AUTH_TOKEN}",
            "Content-Type": "application/json"
        }
        
        response = requests.post(f"{BASE_URL}/api/pregnancy/update-week/{TEST_PATIENT_ID}", headers=headers)
        
        if response.status_code == 200:
            data = response.json()
            print("✅ Manual update successful")
            print(f"   Message: {data.get('message')}")
            
            if data.get('pregnancy_info'):
                info = data['pregnancy_info']
                print(f"   Current Week: {info.get('current_week')}")
                print(f"   Expected Delivery: {info.get('expected_delivery')}")
                print(f"   Days Pregnant: {info.get('days_pregnant')}")
                
        else:
            print(f"❌ HTTP Error: {response.status_code}")
            print(f"   Response: {response.text}")
            
    except Exception as e:
        print(f"❌ Error: {e}")

def test_multiple_calls():
    """Test multiple calls to verify consistency"""
    
    print("\n3️⃣ Testing Multiple Calls (Consistency Check)")
    print("-" * 50)
    
    try:
        headers = {
            "Authorization": f"Bearer {AUTH_TOKEN}",
            "Content-Type": "application/json"
        }
        
        pregnancy_weeks = []
        
        for i in range(3):
            response = requests.get(f"{BASE_URL}/profile/{TEST_PATIENT_ID}", headers=headers)
            
            if response.status_code == 200:
                data = response.json()
                if data.get("success"):
                    patient = data.get("patient", {})
                    week = patient.get('pregnancy_week')
                    pregnancy_weeks.append(week)
                    print(f"   Call {i+1}: Pregnancy Week {week}")
                else:
                    print(f"   Call {i+1}: Failed - {data.get('error')}")
            else:
                print(f"   Call {i+1}: HTTP Error {response.status_code}")
        
        # Check consistency
        if len(set(pregnancy_weeks)) == 1:
            print(f"✅ All calls returned consistent pregnancy week: {pregnancy_weeks[0]}")
        else:
            print(f"❌ Inconsistent pregnancy weeks: {pregnancy_weeks}")
            
    except Exception as e:
        print(f"❌ Error: {e}")

def main():
    """Run all tests"""
    
    print("🚀 Starting Auto Pregnancy Week Update Tests")
    print("=" * 60)
    
    # Check if server is running
    try:
        response = requests.get(f"{BASE_URL}/health", timeout=5)
        if response.status_code == 200:
            print("✅ Server is running")
        else:
            print("⚠️ Server responded but may have issues")
    except:
        print("❌ Server is not running. Please start your server first:")
        print("   python app_simple.py")
        return
    
    # Run tests
    test_pregnancy_week_calculation()
    test_manual_pregnancy_update()
    test_multiple_calls()
    
    print("\n" + "=" * 60)
    print("🏁 Testing Complete!")
    print("\n📋 Next Steps:")
    print("1. Verify the pregnancy week calculations are correct")
    print("2. Check your MongoDB to see updated patient documents")
    print("3. Test with different patients and dates")
    print("4. Monitor the console logs for auto-calculation messages")

if __name__ == "__main__":
    main()



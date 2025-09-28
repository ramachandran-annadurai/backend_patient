#!/usr/bin/env python3
"""
Test Flutter button functionality to change the red box status
"""
import requests
import json

def test_button_functionality():
    print("Testing Flutter Button Functionality to Change Red Box Status...")
    
    # Test current status
    try:
        response = requests.get("http://localhost:8000/api/v1/patients/patient_001/hydration/today")
        if response.status_code == 200:
            summary = response.json()
            print(f"Current Status:")
            print(f"   Total: {summary['total_intake_ml']}ml")
            print(f"   Goal: {summary['goal_ml']}ml")
            print(f"   Percentage: {summary['percentage_complete']}%")
            
            if summary['percentage_complete'] < 50:
                print("   Status: LOW HYDRATION (Red box) - This is correct!")
            elif summary['percentage_complete'] < 80:
                print("   Status: MODERATE HYDRATION (Orange box)")
            else:
                print("   Status: GOOD HYDRATION (Blue/Green box)")
        else:
            print(f"❌ Failed to get current status: {response.status_code}")
            return
    except Exception as e:
        print(f"❌ Error getting status: {e}")
        return
    
    # Test logging more water to change the status
    print("\nTesting button clicks to change status:")
    
    # Simulate clicking "Large Glass" button (250ml)
    try:
        hydration_data = {
            "amount_ml": 250,
            "drink_type": "water",
            "notes": "Large Glass button clicked",
            "pregnancy_week": 20
        }
        
        response = requests.post(
            "http://localhost:8000/api/v1/patients/patient_001/hydration/log",
            json=hydration_data,
            headers={"Content-Type": "application/json"}
        )
        
        if response.status_code == 200:
            print("✅ Large Glass button (250ml) - Logged successfully")
        else:
            print(f"❌ Large Glass button failed: {response.status_code}")
    except Exception as e:
        print(f"❌ Large Glass button error: {e}")
    
    # Simulate clicking "Bottle" button (500ml)
    try:
        hydration_data = {
            "amount_ml": 500,
            "drink_type": "water",
            "notes": "Bottle button clicked",
            "pregnancy_week": 20
        }
        
        response = requests.post(
            "http://localhost:8000/api/v1/patients/patient_001/hydration/log",
            json=hydration_data,
            headers={"Content-Type": "application/json"}
        )
        
        if response.status_code == 200:
            print("✅ Bottle button (500ml) - Logged successfully")
        else:
            print(f"❌ Bottle button failed: {response.status_code}")
    except Exception as e:
        print(f"❌ Bottle button error: {e}")
    
    # Check new status
    try:
        response = requests.get("http://localhost:8000/api/v1/patients/patient_001/hydration/today")
        if response.status_code == 200:
            summary = response.json()
            print(f"\nNew Status After Button Clicks:")
            print(f"   Total: {summary['total_intake_ml']}ml")
            print(f"   Goal: {summary['goal_ml']}ml")
            print(f"   Percentage: {summary['percentage_complete']}%")
            
            if summary['percentage_complete'] < 50:
                print("   Status: LOW HYDRATION (Red box)")
            elif summary['percentage_complete'] < 80:
                print("   Status: MODERATE HYDRATION (Orange box)")
            else:
                print("   Status: GOOD HYDRATION (Blue/Green box)")
        else:
            print(f"❌ Failed to get new status: {response.status_code}")
    except Exception as e:
        print(f"❌ Error getting new status: {e}")
    
    print("\n🎯 Flutter App Instructions:")
    print("   1. Refresh your Flutter app in the browser")
    print("   2. Click the green buttons (Small Glass, Large Glass, Bottle)")
    print("   3. Watch the red 'Low Hydration' box change color as you log more water:")
    print("      - Red: < 50% (Low Hydration)")
    print("      - Orange: 50-80% (Moderate Hydration)")
    print("      - Blue: 80-100% (Good Hydration)")
    print("      - Green: 100%+ (Excellent Hydration)")
    print("   4. The progress bar will also update in real-time")

if __name__ == "__main__":
    test_button_functionality()

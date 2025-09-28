#!/usr/bin/env python3
"""
Test how water logged values are stored in backend patient
"""
import requests
import json
from datetime import datetime

def test_water_storage():
    print("🔍 Testing Water Storage in Backend Patient...")
    print("=" * 50)
    
    base_url = "http://localhost:8000/api/v1"
    patient_id = "patient_001"
    
    # 1. Check current patient data
    print("1. 📋 Current Patient Data:")
    try:
        response = requests.get(f"{base_url}/patients/{patient_id}")
        if response.status_code == 200:
            patient = response.json()
            print(f"   Patient ID: {patient['patient_id']}")
            print(f"   Name: {patient['name']}")
            print(f"   Daily Goal: {patient['daily_goal_ml']}ml")
            print(f"   Pregnancy Week: {patient['pregnancy_week']}")
            print(f"   Created: {patient['created_at']}")
        else:
            print(f"   ❌ Patient not found: {response.status_code}")
    except Exception as e:
        print(f"   ❌ Error: {e}")
    
    # 2. Check today's hydration summary
    print("\n2. 💧 Today's Hydration Summary:")
    try:
        response = requests.get(f"{base_url}/patients/{patient_id}/hydration/today")
        if response.status_code == 200:
            summary = response.json()
            print(f"   Total Intake: {summary['total_intake_ml']}ml")
            print(f"   Daily Goal: {summary['goal_ml']}ml")
            print(f"   Percentage: {summary['percentage_complete']}%")
            print(f"   Risk Score: {summary['risk_score']}")
            print(f"   Date: {summary['date']}")
        else:
            print(f"   ❌ Failed to get summary: {response.status_code}")
    except Exception as e:
        print(f"   ❌ Error: {e}")
    
    # 3. Check hydration history (all logged water)
    print("\n3. 📊 Hydration History (All Logged Water):")
    try:
        response = requests.get(f"{base_url}/patients/{patient_id}/hydration/history")
        if response.status_code == 200:
            history = response.json()
            print(f"   Total Logs: {len(history)}")
            print("   Recent Water Intake:")
            for i, log in enumerate(history[:5]):  # Show last 5 logs
                print(f"     {i+1}. {log['amount_ml']}ml - {log['drink_type']} - {log['timestamp']}")
                if log['notes']:
                    print(f"        Notes: {log['notes']}")
        else:
            print(f"   ❌ Failed to get history: {response.status_code}")
    except Exception as e:
        print(f"   ❌ Error: {e}")
    
    # 4. Log new water to demonstrate storage
    print("\n4. 🚰 Logging New Water Intake:")
    try:
        new_log = {
            "amount_ml": 300,
            "drink_type": "water",
            "notes": "Test water logging",
            "pregnancy_week": 20
        }
        
        response = requests.post(
            f"{base_url}/patients/{patient_id}/hydration/log",
            json=new_log,
            headers={"Content-Type": "application/json"}
        )
        
        if response.status_code == 200:
            logged = response.json()
            print(f"   ✅ Successfully logged: {logged['amount_ml']}ml")
            print(f"   Log ID: {logged['id']}")
            print(f"   Timestamp: {logged['timestamp']}")
        else:
            print(f"   ❌ Failed to log: {response.status_code}")
    except Exception as e:
        print(f"   ❌ Error: {e}")
    
    # 5. Verify the new log was stored
    print("\n5. ✅ Verifying New Log Was Stored:")
    try:
        response = requests.get(f"{base_url}/patients/{patient_id}/hydration/today")
        if response.status_code == 200:
            summary = response.json()
            print(f"   Updated Total: {summary['total_intake_ml']}ml")
            print(f"   Updated Percentage: {summary['percentage_complete']}%")
        else:
            print(f"   ❌ Failed to verify: {response.status_code}")
    except Exception as e:
        print(f"   ❌ Error: {e}")
    
    print("\n" + "=" * 50)
    print("🎯 How Water Storage Works:")
    print("   1. Flutter app sends POST request to /hydration/log")
    print("   2. Backend stores data in hydration_logs_db array")
    print("   3. Each log has: amount_ml, drink_type, timestamp, patient_id")
    print("   4. Today's summary calculates total from all today's logs")
    print("   5. History endpoint returns all logs for the patient")
    print("   6. Data persists in memory while server is running")

if __name__ == "__main__":
    test_water_storage()

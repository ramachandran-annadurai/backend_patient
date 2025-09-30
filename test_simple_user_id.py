#!/usr/bin/env python3
"""
Simple test for dynamic user_id in hydration intake
"""

import requests
import json

# Test the exact request you provided
def test_user_id_fix():
    print("🧪 Testing Dynamic user_id Fix")
    print("=" * 40)
    
    # Your exact request format
    test_data = {
        "user_id": "PAT1759141374B65D62",  # This should now be used
        "hydration_type": "water",
        "amount_ml": 250,
        "notes": "Morning water"
    }
    
    print("Request data:")
    print(json.dumps(test_data, indent=2))
    
    # Note: You'll need to replace with your actual token
    headers = {
        "Authorization": "Bearer YOUR_TOKEN_HERE",
        "Content-Type": "application/json"
    }
    
    print("\n📝 Instructions:")
    print("1. Get your JWT token from login")
    print("2. Replace 'YOUR_TOKEN_HERE' in the headers")
    print("3. Run this test")
    print("4. Check the server logs to see if it uses the user_id from the body")
    
    print("\nExpected behavior:")
    print("✅ Should use user_id 'PAT1759141374B65D62' from request body")
    print("✅ Should validate it matches the authenticated patient")
    print("✅ Should store data for that specific patient_id")
    print("✅ Should show in logs: 'from user_id: PAT1759141374B65D62'")

if __name__ == "__main__":
    test_user_id_fix()

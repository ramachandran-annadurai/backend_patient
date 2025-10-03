#!/usr/bin/env python3
"""
Simple test for doctor endpoints without authentication
"""

import requests
import json

# Configuration
BASE_URL = "https://pregnancy-ai.onrender.com"
# BASE_URL = "http://localhost:5000"  # Uncomment for local testing

def test_doctor_simple():
    """Simple test for doctor endpoints"""
    
    print("👨‍⚕️ Simple Doctor Endpoints Test")
    print("=" * 40)
    
    # Test endpoints that should work
    endpoints = [
        {
            "name": "Get Current Doctor Profile",
            "url": f"{BASE_URL}/doctor/profile",
            "method": "GET",
            "headers": {"Authorization": "Bearer test_token"}
        },
        {
            "name": "Get Doctor Profile by ID",
            "url": f"{BASE_URL}/doctor/profile/DOC123456",
            "method": "GET", 
            "headers": {"Authorization": "Bearer test_token"}
        },
        {
            "name": "Get All Doctors",
            "url": f"{BASE_URL}/doctors",
            "method": "GET",
            "headers": {"Authorization": "Bearer test_token"}
        },
        {
            "name": "Get Doctors with Specialty Filter",
            "url": f"{BASE_URL}/doctors?specialty=cardiology",
            "method": "GET",
            "headers": {"Authorization": "Bearer test_token"}
        },
        {
            "name": "Get Doctors with Location Filter", 
            "url": f"{BASE_URL}/doctors?location=New York",
            "method": "GET",
            "headers": {"Authorization": "Bearer test_token"}
        },
        {
            "name": "Get Doctors with Pagination",
            "url": f"{BASE_URL}/doctors?limit=2&offset=0",
            "method": "GET",
            "headers": {"Authorization": "Bearer test_token"}
        }
    ]
    
    print("Testing doctor endpoints...")
    print("Note: These tests will show 401 Unauthorized (expected without valid token)")
    print("But the endpoints should exist and be accessible\n")
    
    for i, endpoint in enumerate(endpoints, 1):
        print(f"{i}. {endpoint['name']}")
        print(f"   URL: {endpoint['url']}")
        
        try:
            response = requests.get(endpoint['url'], 
                                  headers=endpoint['headers'], 
                                  timeout=10)
            print(f"   Status: {response.status_code}")
            
            if response.status_code == 401:
                print("   ✅ Endpoint exists (401 Unauthorized - expected)")
            elif response.status_code == 200:
                print("   ✅ Endpoint working (200 OK)")
            elif response.status_code == 404:
                print("   ❌ Endpoint not found (404)")
            else:
                print(f"   ⚠️  Unexpected status: {response.status_code}")
                
        except Exception as e:
            print(f"   ❌ Error: {str(e)}")
        
        print()
    
    print("🎯 Test Summary:")
    print("- If you see 401 Unauthorized: Endpoints exist and are working")
    print("- If you see 404 Not Found: Endpoints are not properly configured")
    print("- If you see 200 OK: Endpoints are working with authentication")
    print("\nTo test with real authentication, use the full test script with valid credentials.")

if __name__ == "__main__":
    test_doctor_simple()

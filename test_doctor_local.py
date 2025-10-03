#!/usr/bin/env python3
"""
Test doctor endpoints locally
"""

import requests
import json

# Configuration
BASE_URL = "http://localhost:8000"

def test_doctor_local():
    """Test doctor endpoints locally"""
    
    print("👨‍⚕️ Testing Doctor Endpoints Locally")
    print("=" * 40)
    
    # Test endpoints
    endpoints = [
        {
            "name": "Get Current Doctor Profile",
            "url": f"{BASE_URL}/doctor/profile",
            "method": "GET"
        },
        {
            "name": "Get Doctor Profile by ID", 
            "url": f"{BASE_URL}/doctor/profile/DOC123456",
            "method": "GET"
        },
        {
            "name": "Get All Doctors",
            "url": f"{BASE_URL}/doctors",
            "method": "GET"
        }
    ]
    
    for i, endpoint in enumerate(endpoints, 1):
        print(f"{i}. {endpoint['name']}")
        print(f"   URL: {endpoint['url']}")
        
        try:
            response = requests.get(endpoint['url'], 
                                  headers={"Authorization": "Bearer test_token"}, 
                                  timeout=5)
            print(f"   Status: {response.status_code}")
            
            if response.status_code == 401:
                print("   ✅ Endpoint exists (401 Unauthorized - expected)")
            elif response.status_code == 200:
                print("   ✅ Endpoint working (200 OK)")
                try:
                    data = response.json()
                    print(f"   Response: {json.dumps(data, indent=2)[:200]}...")
                except:
                    print("   Response: (non-JSON)")
            elif response.status_code == 404:
                print("   ❌ Endpoint not found (404)")
            else:
                print(f"   ⚠️  Status: {response.status_code}")
                
        except requests.exceptions.ConnectionError:
            print("   ❌ Connection failed - Server not running locally")
        except Exception as e:
            print(f"   ❌ Error: {str(e)}")
        
        print()
    
    print("🎯 Local Test Summary:")
    print("- Start the server locally with: python app_simple.py")
    print("- Then run this test to verify endpoints work locally")
    print("- If local test works, the issue is with deployment")

if __name__ == "__main__":
    test_doctor_local()

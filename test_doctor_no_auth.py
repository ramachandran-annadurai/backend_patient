#!/usr/bin/env python3
"""
Test doctor endpoints without authentication
"""

import requests
import json

def test_doctor_no_auth():
    """Test doctor endpoints without authentication"""
    
    print("👨‍⚕️ Testing Doctor Endpoints (No Auth)")
    print("=" * 50)
    
    base_url = "http://localhost:8000"
    
    # Test endpoints without authentication
    endpoints = [
        "/doctor/profile",
        "/doctor/profile/DOC123456", 
        "/doctors"
    ]
    
    for endpoint in endpoints:
        print(f"\nTesting {endpoint}...")
        try:
            response = requests.get(f"{base_url}{endpoint}", timeout=5)
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
                print(f"   Response: {response.text[:200]}...")
                
        except requests.exceptions.ConnectionError:
            print("   ❌ Connection failed - Server not running")
        except Exception as e:
            print(f"   ❌ Error: {str(e)}")
    
    print("\n🎯 Test Complete!")

if __name__ == "__main__":
    test_doctor_no_auth()








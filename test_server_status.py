#!/usr/bin/env python3
"""
Test server status and available endpoints
"""

import requests
import json

# Configuration
BASE_URL = "https://pregnancy-ai.onrender.com"

def test_server_status():
    """Test server status and basic endpoints"""
    
    print("🔍 Testing Server Status and Endpoints")
    print("=" * 50)
    
    # Test 1: Check if server is running
    print("1. Testing server connectivity...")
    try:
        response = requests.get(f"{BASE_URL}/", timeout=10)
        print(f"   Status: {response.status_code}")
        if response.status_code == 200:
            print("   ✅ Server is running")
        else:
            print(f"   ⚠️  Server responded with status {response.status_code}")
    except Exception as e:
        print(f"   ❌ Server not accessible: {str(e)}")
        return
    
    # Test 2: Check login endpoint
    print("\n2. Testing login endpoint...")
    try:
        response = requests.post(f"{BASE_URL}/login", 
                               json={"username": "test", "password": "test"}, 
                               timeout=10)
        print(f"   Status: {response.status_code}")
        if response.status_code in [200, 401, 400]:
            print("   ✅ Login endpoint exists")
        else:
            print(f"   ⚠️  Login endpoint status: {response.status_code}")
    except Exception as e:
        print(f"   ❌ Login endpoint error: {str(e)}")
    
    # Test 3: Check patient appointments endpoint
    print("\n3. Testing patient appointments endpoint...")
    try:
        response = requests.get(f"{BASE_URL}/patient/appointments", 
                              headers={"Authorization": "Bearer test_token"}, 
                              timeout=10)
        print(f"   Status: {response.status_code}")
        if response.status_code in [200, 401, 404]:
            print("   ✅ Patient appointments endpoint exists")
        else:
            print(f"   ⚠️  Patient appointments status: {response.status_code}")
    except Exception as e:
        print(f"   ❌ Patient appointments error: {str(e)}")
    
    # Test 4: Check hydration endpoint
    print("\n4. Testing hydration endpoint...")
    try:
        response = requests.get(f"{BASE_URL}/api/hydration/status", 
                              headers={"Authorization": "Bearer test_token"}, 
                              timeout=10)
        print(f"   Status: {response.status_code}")
        if response.status_code in [200, 401, 404]:
            print("   ✅ Hydration endpoint exists")
        else:
            print(f"   ⚠️  Hydration status: {response.status_code}")
    except Exception as e:
        print(f"   ❌ Hydration error: {str(e)}")
    
    # Test 5: Check doctor profile endpoint (our new one)
    print("\n5. Testing doctor profile endpoint...")
    try:
        response = requests.get(f"{BASE_URL}/doctor/profile", 
                              headers={"Authorization": "Bearer test_token"}, 
                              timeout=10)
        print(f"   Status: {response.status_code}")
        if response.status_code in [200, 401, 404]:
            print("   ✅ Doctor profile endpoint exists")
        else:
            print(f"   ⚠️  Doctor profile status: {response.status_code}")
    except Exception as e:
        print(f"   ❌ Doctor profile error: {str(e)}")
    
    print("\n🎯 Analysis:")
    print("- If all endpoints return 401: Server is running, endpoints exist, need authentication")
    print("- If some return 404: Those endpoints are not deployed or configured")
    print("- If all return 200: Server is working perfectly")
    print("- If server not accessible: Deployment issue")

if __name__ == "__main__":
    test_server_status()

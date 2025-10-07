#!/usr/bin/env python3
"""
Direct test of doctor endpoints
"""

import requests
import json

def test_doctor_direct():
    """Test doctor endpoints directly"""
    
    print("👨‍⚕️ Testing Doctor Endpoints Directly")
    print("=" * 50)
    
    base_url = "http://localhost:8000"
    
    # Test 1: Basic server connectivity
    print("\n1. Testing server connectivity...")
    try:
        response = requests.get(f"{base_url}/", timeout=5)
        print(f"   ✅ Server responding: Status {response.status_code}")
    except Exception as e:
        print(f"   ❌ Server not responding: {str(e)}")
        return
    
    # Test 2: Doctor profile endpoint
    print("\n2. Testing doctor profile endpoint...")
    try:
        response = requests.get(f"{base_url}/doctor/profile", 
                              headers={"Authorization": "Bearer test_token"}, 
                              timeout=5)
        print(f"   Status: {response.status_code}")
        print(f"   Response: {response.text[:200]}...")
        
        if response.status_code == 200:
            print("   ✅ Doctor profile endpoint working!")
        elif response.status_code == 401:
            print("   ✅ Doctor profile endpoint exists (401 Unauthorized - expected)")
        elif response.status_code == 404:
            print("   ❌ Doctor profile endpoint not found (404)")
        else:
            print(f"   ⚠️  Unexpected status: {response.status_code}")
            
    except Exception as e:
        print(f"   ❌ Error testing doctor profile: {str(e)}")
    
    # Test 3: Doctor profile by ID endpoint
    print("\n3. Testing doctor profile by ID endpoint...")
    try:
        response = requests.get(f"{base_url}/doctor/profile/DOC123456", 
                              headers={"Authorization": "Bearer test_token"}, 
                              timeout=5)
        print(f"   Status: {response.status_code}")
        print(f"   Response: {response.text[:200]}...")
        
        if response.status_code == 200:
            print("   ✅ Doctor profile by ID endpoint working!")
        elif response.status_code == 401:
            print("   ✅ Doctor profile by ID endpoint exists (401 Unauthorized - expected)")
        elif response.status_code == 404:
            print("   ❌ Doctor profile by ID endpoint not found (404)")
        else:
            print(f"   ⚠️  Unexpected status: {response.status_code}")
            
    except Exception as e:
        print(f"   ❌ Error testing doctor profile by ID: {str(e)}")
    
    # Test 4: All doctors endpoint
    print("\n4. Testing all doctors endpoint...")
    try:
        response = requests.get(f"{base_url}/doctors", 
                              headers={"Authorization": "Bearer test_token"}, 
                              timeout=5)
        print(f"   Status: {response.status_code}")
        print(f"   Response: {response.text[:200]}...")
        
        if response.status_code == 200:
            print("   ✅ All doctors endpoint working!")
        elif response.status_code == 401:
            print("   ✅ All doctors endpoint exists (401 Unauthorized - expected)")
        elif response.status_code == 404:
            print("   ❌ All doctors endpoint not found (404)")
        else:
            print(f"   ⚠️  Unexpected status: {response.status_code}")
            
    except Exception as e:
        print(f"   ❌ Error testing all doctors: {str(e)}")
    
    print("\n🎯 Test Complete!")
    print("\n📋 Summary:")
    print("- If you see 401 Unauthorized: Endpoints exist and are working")
    print("- If you see 404 Not Found: Endpoints are not properly configured")
    print("- If you see 200 OK: Endpoints are working with authentication")

if __name__ == "__main__":
    test_doctor_direct()








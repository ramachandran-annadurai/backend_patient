#!/usr/bin/env python3
"""
Simple server test
"""

import requests
import time

def test_server():
    """Test if server is running"""
    
    print("🔍 Testing Server Status...")
    
    # Test different ports
    ports = [8000, 5000, 3000]
    
    for port in ports:
        try:
            print(f"\nTesting port {port}...")
            response = requests.get(f"http://localhost:{port}/", timeout=3)
            print(f"✅ Port {port}: Status {response.status_code}")
            
            # Test doctor endpoint
            try:
                doctor_response = requests.get(f"http://localhost:{port}/doctor/profile", 
                                             headers={"Authorization": "Bearer test"}, 
                                             timeout=3)
                print(f"   Doctor endpoint: Status {doctor_response.status_code}")
            except Exception as e:
                print(f"   Doctor endpoint: Error - {str(e)}")
                
        except requests.exceptions.ConnectionError:
            print(f"❌ Port {port}: Connection failed")
        except Exception as e:
            print(f"❌ Port {port}: Error - {str(e)}")
    
    print("\n🎯 Server Test Complete!")

if __name__ == "__main__":
    test_server()








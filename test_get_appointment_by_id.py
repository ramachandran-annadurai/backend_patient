"""
Test GET /patient/appointments/<appointment_id> endpoint
"""

import requests
import json

# Configuration
BASE_URL = "http://localhost:8000"
# Replace with your actual JWT token
ACCESS_TOKEN = "your_jwt_token_here"

# Replace with actual appointment ID
APPOINTMENT_ID = "507f1f77bcf86cd799439011"

def test_get_appointment_by_id():
    """Test getting a specific appointment by ID"""
    
    url = f"{BASE_URL}/patient/appointments/{APPOINTMENT_ID}"
    
    headers = {
        "Authorization": f"Bearer {ACCESS_TOKEN}",
        "Content-Type": "application/json"
    }
    
    print(f"\n{'='*60}")
    print(f"Testing: GET {url}")
    print(f"{'='*60}\n")
    
    try:
        response = requests.get(url, headers=headers)
        
        print(f"Status Code: {response.status_code}")
        print(f"\nResponse:")
        print(json.dumps(response.json(), indent=2))
        
        if response.status_code == 200:
            print("\n[SUCCESS] Appointment retrieved successfully!")
            appointment = response.json().get('appointment', {})
            print(f"\nAppointment Details:")
            print(f"  - ID: {appointment.get('appointment_id')}")
            print(f"  - Date: {appointment.get('appointment_date')}")
            print(f"  - Time: {appointment.get('appointment_time')}")
            print(f"  - Type: {appointment.get('type')}")
            print(f"  - Appointment Type: {appointment.get('appointment_type')}")
            print(f"  - Status: {appointment.get('appointment_status')}")
        elif response.status_code == 404:
            print("\n[ERROR] Appointment not found")
        elif response.status_code == 401:
            print("\n[ERROR] Unauthorized - Invalid token")
        else:
            print(f"\n[ERROR] Request failed")
            
    except requests.exceptions.ConnectionError:
        print("\n[ERROR] Could not connect to server. Make sure the server is running at", BASE_URL)
    except Exception as e:
        print(f"\n[ERROR] {str(e)}")

if __name__ == "__main__":
    print("\n" + "="*60)
    print("GET APPOINTMENT BY ID - Test Script")
    print("="*60)
    print(f"\nBase URL: {BASE_URL}")
    print(f"Appointment ID: {APPOINTMENT_ID}")
    print(f"\nNOTE: Update ACCESS_TOKEN and APPOINTMENT_ID in this script")
    print("="*60)
    
    test_get_appointment_by_id()


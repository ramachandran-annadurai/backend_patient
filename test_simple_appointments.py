#!/usr/bin/env python3
"""
Simple test for appointment endpoint
"""

import requests
import json

def test_simple_appointments():
    print("📅 Simple Appointment Test")
    print("=" * 30)
    
    # Your exact request
    print("Testing: GET /patient/appointments")
    print("This should return all appointments for the logged-in user")
    
    print("\n📝 Instructions:")
    print("1. Make sure you're logged in and have a valid JWT token")
    print("2. Send GET request to /patient/appointments")
    print("3. Check the response for appointments")
    
    print("\nExpected behavior:")
    print("✅ Should return all appointments for the logged-in patient")
    print("✅ Should not filter by status by default")
    print("✅ Should show total count and appointment details")
    print("✅ Should include patient information")
    
    print("\nExample request:")
    print("GET /patient/appointments")
    print("Authorization: Bearer YOUR_JWT_TOKEN")
    
    print("\nExample response:")
    print("""
    {
        "appointments": [
            {
                "appointment_id": "APT123456",
                "appointment_date": "2024-10-01",
                "appointment_time": "10:00",
                "appointment_status": "pending",
                "appointment_type": "consultation",
                "doctor_name": "Dr. Smith",
                "notes": "Regular checkup",
                "patient_id": "PAT1759141374B65D62",
                "patient_name": "John Doe"
            }
        ],
        "total_count": 1,
        "patient_id": "PAT1759141374B65D62",
        "message": "Appointments retrieved successfully"
    }
    """)

if __name__ == "__main__":
    test_simple_appointments()

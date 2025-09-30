#!/usr/bin/env python3
"""
Comprehensive endpoint testing script for pregnancy-ai.onrender.com
Tests all API endpoints to verify they're working correctly
"""

import requests
import json
import time
from datetime import datetime

# Base URL
BASE_URL = "https://pregnancy-ai.onrender.com"

# Test results storage
test_results = {
    "passed": 0,
    "failed": 0,
    "errors": [],
    "details": []
}

def log_test(endpoint, method, status_code, response_time, success, error_msg=None):
    """Log test results"""
    result = {
        "endpoint": endpoint,
        "method": method,
        "status_code": status_code,
        "response_time": f"{response_time:.2f}s",
        "success": success,
        "error": error_msg,
        "timestamp": datetime.now().isoformat()
    }
    
    test_results["details"].append(result)
    
    if success:
        test_results["passed"] += 1
        print(f"✅ {method} {endpoint} - {status_code} ({response_time:.2f}s)")
    else:
        test_results["failed"] += 1
        test_results["errors"].append(f"{method} {endpoint}: {error_msg}")
        print(f"❌ {method} {endpoint} - {status_code} ({response_time:.2f}s) - {error_msg}")

def test_endpoint(endpoint, method="GET", data=None, headers=None, expected_status=200):
    """Test a single endpoint"""
    try:
        url = f"{BASE_URL}{endpoint}"
        start_time = time.time()
        
        if method == "GET":
            response = requests.get(url, timeout=30)
        elif method == "POST":
            response = requests.post(url, json=data, headers=headers, timeout=30)
        elif method == "PUT":
            response = requests.put(url, json=data, headers=headers, timeout=30)
        elif method == "DELETE":
            response = requests.delete(url, headers=headers, timeout=30)
        
        response_time = time.time() - start_time
        
        # Check if status code is acceptable (200-299 or specific expected)
        success = (200 <= response.status_code < 300) or (response.status_code == expected_status)
        
        log_test(endpoint, method, response.status_code, response_time, success)
        
        return response
        
    except requests.exceptions.Timeout:
        log_test(endpoint, method, 0, 30.0, False, "Timeout")
        return None
    except requests.exceptions.ConnectionError:
        log_test(endpoint, method, 0, 0.0, False, "Connection Error")
        return None
    except Exception as e:
        log_test(endpoint, method, 0, 0.0, False, str(e))
        return None

def main():
    """Run comprehensive endpoint tests"""
    print("🚀 Starting comprehensive endpoint testing for pregnancy-ai.onrender.com")
    print("=" * 80)
    
    # Test basic endpoints
    print("\n📋 Testing Basic Endpoints...")
    test_endpoint("/")
    test_endpoint("/health")
    
    # Test authentication endpoints
    print("\n🔐 Testing Authentication Endpoints...")
    test_endpoint("/signup", "POST", {
        "email": "test@example.com",
        "password": "testpass123",
        "username": "testuser"
    }, expected_status=400)  # Expected to fail without proper data
    
    test_endpoint("/send-otp", "POST", {
        "email": "test@example.com"
    }, expected_status=400)
    
    test_endpoint("/login", "POST", {
        "email": "test@example.com",
        "password": "testpass123"
    }, expected_status=400)
    
    test_endpoint("/forgot-password", "POST", {
        "email": "test@example.com"
    }, expected_status=400)
    
    # Test symptoms endpoints
    print("\n🤒 Testing Symptoms Endpoints...")
    test_endpoint("/symptoms/health")
    test_endpoint("/symptoms/assist", "POST", {
        "symptom_text": "nausea and fatigue",
        "weeks_pregnant": 12
    }, expected_status=400)  # May fail without auth
    
    # Test vital signs endpoints
    print("\n💓 Testing Vital Signs Endpoints...")
    test_endpoint("/vitals/record", "POST", {
        "patient_id": "test123",
        "blood_pressure": "120/80",
        "heart_rate": 72
    }, expected_status=400)
    
    test_endpoint("/vitals/ocr", "POST", {
        "file_content": "test"
    }, expected_status=400)
    
    # Test medication endpoints
    print("\n💊 Testing Medication Endpoints...")
    test_endpoint("/medication/save-medication-log", "POST", {
        "patient_id": "test123",
        "medication_name": "test_med"
    }, expected_status=400)
    
    test_endpoint("/medication/process-prescription-document", "POST", {
        "file_content": "test"
    }, expected_status=400)
    
    test_endpoint("/medication/send-reminders", "POST", {})
    
    # Test nutrition endpoints
    print("\n🍎 Testing Nutrition Endpoints...")
    test_endpoint("/nutrition/health")
    test_endpoint("/nutrition/transcribe", "POST", {
        "audio_data": "test"
    }, expected_status=400)
    
    test_endpoint("/nutrition/analyze-with-gpt4", "POST", {
        "food_description": "apple and banana"
    }, expected_status=400)
    
    # Test quantum/LLM endpoints
    print("\n🧠 Testing Quantum/LLM Endpoints...")
    test_endpoint("/quantum/health")
    test_endpoint("/quantum/collections")
    test_endpoint("/llm/health")
    test_endpoint("/llm/test", "POST", {
        "text": "test query"
    }, expected_status=400)
    
    # Test pregnancy tracking endpoints
    print("\n🤱 Testing Pregnancy Tracking Endpoints...")
    test_endpoint("/api/pregnancy/week/12", expected_status=401)  # Requires auth
    test_endpoint("/api/pregnancy/weeks", expected_status=401)
    test_endpoint("/api/pregnancy/trimester/1", expected_status=401)
    
    # Test hydration endpoints
    print("\n💧 Testing Hydration Endpoints...")
    test_endpoint("/api/hydration/intake", "POST", {
        "amount": 250
    }, expected_status=401)
    
    test_endpoint("/api/hydration/history", expected_status=401)
    test_endpoint("/api/hydration/stats", expected_status=401)
    
    # Test mental health endpoints
    print("\n🧘 Testing Mental Health Endpoints...")
    test_endpoint("/api/mental-health/health")
    test_endpoint("/api/mental-health/assess", "POST", {
        "mood": "happy",
        "energy": "high"
    }, expected_status=401)
    
    # Test medical lab endpoints
    print("\n🔬 Testing Medical Lab Endpoints...")
    test_endpoint("/api/medical-lab/health")
    test_endpoint("/api/medical-lab/formats")
    test_endpoint("/api/medical-lab/languages")
    
    # Test voice endpoints
    print("\n🎤 Testing Voice Endpoints...")
    test_endpoint("/api/voice/service-info")
    test_endpoint("/api/voice/health")
    test_endpoint("/api/voice/transcribe", "POST", {
        "audio_data": "test"
    }, expected_status=401)
    
    # Generate final report
    print("\n" + "=" * 80)
    print("📊 TEST RESULTS SUMMARY")
    print("=" * 80)
    print(f"✅ Passed: {test_results['passed']}")
    print(f"❌ Failed: {test_results['failed']}")
    print(f"📈 Success Rate: {(test_results['passed'] / (test_results['passed'] + test_results['failed'])) * 100:.1f}%")
    
    if test_results['errors']:
        print(f"\n❌ Errors encountered:")
        for error in test_results['errors'][:10]:  # Show first 10 errors
            print(f"   • {error}")
        if len(test_results['errors']) > 10:
            print(f"   ... and {len(test_results['errors']) - 10} more errors")
    
    # Save detailed results
    with open('endpoint_test_results.json', 'w') as f:
        json.dump(test_results, f, indent=2)
    
    print(f"\n📄 Detailed results saved to: endpoint_test_results.json")
    
    return test_results['failed'] == 0

if __name__ == "__main__":
    success = main()
    exit(0 if success else 1)

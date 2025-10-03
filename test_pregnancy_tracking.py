#!/usr/bin/env python3
"""
Test script for Pregnancy Tracking Service
This script tests all the pregnancy tracking endpoints.
"""

import requests
import json
import time
import sys

# Configuration
BASE_URL = "http://localhost:8000"
LIGHT_URL = "http://localhost:8001"
AUTH_TOKEN = "test-token-123"

def test_endpoint(url, name, expected_status=200):
    """Test a single endpoint"""
    try:
        print(f"🧪 Testing {name}...")
        response = requests.get(url, 
                              headers={"Authorization": f"Bearer {AUTH_TOKEN}"},
                              timeout=10)
        
        print(f"   Status: {response.status_code}")
        
        if response.status_code == expected_status:
            print(f"   ✅ {name} - PASSED")
            if response.status_code == 200:
                data = response.json()
                if data.get('success'):
                    print(f"   📊 Response: {data.get('quick_action', data.get('phase', 'Success'))}")
                else:
                    print(f"   ⚠️  Response: {data.get('error', 'Unknown error')}")
        else:
            print(f"   ❌ {name} - FAILED (Expected {expected_status}, got {response.status_code})")
            if response.text:
                print(f"   📝 Error: {response.text[:100]}...")
        
        return response.status_code == expected_status
        
    except Exception as e:
        print(f"   ❌ {name} - ERROR: {str(e)}")
        return False

def test_health_endpoints():
    """Test health and status endpoints"""
    print("\n🏥 Testing Health Endpoints")
    print("=" * 50)
    
    # Test main service health
    test_endpoint(f"{BASE_URL}/api/pregnancy/health", "Main Service Health")
    
    # Test lightweight service health
    test_endpoint(f"{LIGHT_URL}/api/pregnancy/health", "Lightweight Service Health")
    
    # Test OpenAI status
    test_endpoint(f"{BASE_URL}/api/pregnancy/openai/status", "OpenAI Status")

def test_auto_trimester():
    """Test auto-trimester selection"""
    print("\n🎯 Testing Auto-Trimester Selection")
    print("=" * 50)
    
    # Test different weeks
    test_weeks = [8, 12, 20, 24, 28, 32, 36]
    
    for week in test_weeks:
        test_endpoint(f"{BASE_URL}/api/pregnancy/auto-trimester/{week}", 
                     f"Auto-Trimester Week {week}")

def test_trimester_1():
    """Test Trimester 1 quick actions"""
    print("\n🤱 Testing Trimester 1 Quick Actions")
    print("=" * 50)
    
    actions = [
        "pregnancy-test",
        "first-prenatal-visit", 
        "early-ultrasound",
        "early-symptoms"
    ]
    
    for action in actions:
        test_endpoint(f"{BASE_URL}/api/pregnancy/trimester-1/{action}",
                     f"Trimester 1 - {action.replace('-', ' ').title()}")

def test_trimester_2():
    """Test Trimester 2 quick actions"""
    print("\n🌱 Testing Trimester 2 Quick Actions")
    print("=" * 50)
    
    actions = [
        "mid-pregnancy-scan",
        "glucose-screening",
        "fetal-movement",
        "birthing-classes",
        "nutrition-tips"
    ]
    
    for action in actions:
        test_endpoint(f"{BASE_URL}/api/pregnancy/trimester-2/{action}",
                     f"Trimester 2 - {action.replace('-', ' ').title()}")

def test_trimester_3():
    """Test Trimester 3 quick actions"""
    print("\n👶 Testing Trimester 3 Quick Actions")
    print("=" * 50)
    
    actions = [
        "kick-counter",
        "contractions",
        "birth-plan",
        "hospital-bag"
    ]
    
    for action in actions:
        test_endpoint(f"{BASE_URL}/api/pregnancy/trimester-3/{action}",
                     f"Trimester 3 - {action.replace('-', ' ').title()}")

def test_general_apis():
    """Test general trimester APIs"""
    print("\n📊 Testing General Trimester APIs")
    print("=" * 50)
    
    # Test trimester info
    for trimester in [1, 2, 3]:
        test_endpoint(f"{BASE_URL}/api/pregnancy/trimester/{trimester}",
                     f"Trimester {trimester} Info")
        
        test_endpoint(f"{BASE_URL}/api/pregnancy/trimester/{trimester}/quick-actions",
                     f"Trimester {trimester} Quick Actions")

def test_error_cases():
    """Test error cases"""
    print("\n🚨 Testing Error Cases")
    print("=" * 50)
    
    # Test invalid week
    test_endpoint(f"{BASE_URL}/api/pregnancy/auto-trimester/50",
                 "Invalid Week (50)", 400)
    
    # Test invalid trimester
    test_endpoint(f"{BASE_URL}/api/pregnancy/trimester/5",
                 "Invalid Trimester (5)", 400)
    
    # Test without token
    try:
        response = requests.get(f"{BASE_URL}/api/pregnancy/auto-trimester/20", timeout=5)
        if response.status_code == 401:
            print("   ✅ No Token - PASSED")
        else:
            print(f"   ❌ No Token - FAILED (Expected 401, got {response.status_code})")
    except Exception as e:
        print(f"   ❌ No Token - ERROR: {str(e)}")

def test_lightweight_service():
    """Test lightweight service"""
    print("\n⚡ Testing Lightweight Service")
    print("=" * 50)
    
    # Test a few key endpoints on lightweight service
    test_endpoint(f"{LIGHT_URL}/api/pregnancy/auto-trimester/20",
                 "Lightweight Auto-Trimester")
    
    test_endpoint(f"{LIGHT_URL}/api/pregnancy/trimester-2/mid-pregnancy-scan",
                 "Lightweight Mid-Pregnancy Scan")
    
    test_endpoint(f"{LIGHT_URL}/api/pregnancy/trimester-3/kick-counter",
                 "Lightweight Kick Counter")

def run_all_tests():
    """Run all tests"""
    print("🧪 Pregnancy Tracking Service Test Suite")
    print("=" * 60)
    print(f"Testing against: {BASE_URL}")
    print(f"Lightweight URL: {LIGHT_URL}")
    print("=" * 60)
    
    # Check if services are running
    try:
        response = requests.get(f"{BASE_URL}/api/pregnancy/health", timeout=5)
        if response.status_code != 200:
            print("❌ Main service is not running. Please start it first:")
            print("   python pregnancy_tracking_app.py")
            return False
    except:
        print("❌ Main service is not running. Please start it first:")
        print("   python pregnancy_tracking_app.py")
        return False
    
    try:
        response = requests.get(f"{LIGHT_URL}/api/pregnancy/health", timeout=5)
        if response.status_code != 200:
            print("⚠️  Lightweight service is not running. Starting tests with main service only.")
    except:
        print("⚠️  Lightweight service is not running. Starting tests with main service only.")
    
    # Run all test suites
    test_health_endpoints()
    test_auto_trimester()
    test_trimester_1()
    test_trimester_2()
    test_trimester_3()
    test_general_apis()
    test_error_cases()
    test_lightweight_service()
    
    print("\n🎉 Test Suite Complete!")
    print("=" * 60)
    print("To start the services:")
    print("  Main:      python pregnancy_tracking_app.py")
    print("  Lightweight: python pregnancy_tracking_light.py")
    print("=" * 60)

if __name__ == "__main__":
    run_all_tests()

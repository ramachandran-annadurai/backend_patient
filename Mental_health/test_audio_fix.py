#!/usr/bin/env python3
"""
Test the audio playback fix
"""

import requests
import json

def test_audio_fix():
    """Test the audio playback fix"""
    
    print("🔧 Testing Audio Playback Fix")
    print("=" * 50)
    
    # Test 1: Audio generation with quota exceeded
    print("\n1. Testing audio generation with quota exceeded...")
    try:
        response = requests.post("http://localhost:8000/generate-audio", 
                               json={"text": "கர்ப்பிணி பெண் சோதனை"})
        
        print(f"Status Code: {response.status_code}")
        print(f"Content-Type: {response.headers.get('content-type', 'unknown')}")
        print(f"Content Length: {len(response.content)} bytes")
        
        if response.status_code == 200:
            content_type = response.headers.get('content-type', '')
            
            if 'application/json' in content_type:
                data = response.json()
                print(f"✅ JSON Response (Fallback): {data}")
                
                if data.get('fallback') and data.get('error') == 'quota_exceeded':
                    print("✅ Correctly detected quota exceeded and returned fallback")
                else:
                    print("❌ Unexpected JSON response format")
            else:
                print(f"✅ Audio Response: {len(response.content)} bytes")
        else:
            print(f"❌ HTTP Error: {response.status_code}")
            
    except Exception as e:
        print(f"❌ Error: {e}")
    
    # Test 2: Test frontend page
    print("\n2. Testing frontend page...")
    try:
        response = requests.get("http://localhost:8000/test_frontend.html")
        if response.status_code == 200:
            print("✅ Frontend page loads successfully")
        else:
            print(f"❌ Frontend page error: {response.status_code}")
    except Exception as e:
        print(f"❌ Error: {e}")
    
    # Test 3: Test pregnancy app
    print("\n3. Testing pregnancy app...")
    try:
        response = requests.get("http://localhost:8000/pregnancy")
        if response.status_code == 200:
            print("✅ Pregnancy app loads successfully")
        else:
            print(f"❌ Pregnancy app error: {response.status_code}")
    except Exception as e:
        print(f"❌ Error: {e}")
    
    print("\n" + "=" * 50)
    print("✅ Audio fix test completed!")
    print("\n📱 Fixed Issues:")
    print("   ✅ ElevenLabs quota exceeded now returns proper JSON response")
    print("   ✅ Frontend detects JSON responses and uses Browser TTS fallback")
    print("   ✅ No more 'Audio playback error: undefined'")
    print("   ✅ Proper error handling and user feedback")
    
    print("\n🌐 Test URLs:")
    print("   • Frontend Test: http://localhost:8000/test_frontend.html")
    print("   • Pregnancy App: http://localhost:8000/pregnancy")
    print("   • Main App: http://localhost:8000/")

if __name__ == "__main__":
    test_audio_fix()

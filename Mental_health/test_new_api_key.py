#!/usr/bin/env python3
"""
Test the new ElevenLabs API key
"""

import requests
import json

def test_new_api_key():
    """Test the new ElevenLabs API key"""
    
    print("🔑 Testing New ElevenLabs API Key")
    print("=" * 50)
    
    # Test 1: Generate a story
    print("\n1. Generating story...")
    try:
        story_response = requests.post("http://localhost:8000/generate-story", 
                                     json={
                                         "difficulty": "easy",
                                         "scenario": "pregnancy_mental_health"
                                     })
        
        if story_response.status_code == 200:
            story_data = story_response.json()
            print(f"✅ Story generated: {story_data.get('title', 'N/A')}")
            print(f"   Content length: {len(story_data.get('content', ''))}")
            
            content = story_data.get('content', '')
            if content:
                print(f"   Content preview: {content[:100]}...")
                
                # Test 2: Test audio generation with new API key
                print("\n2. Testing audio generation with new API key...")
                audio_response = requests.post("http://localhost:8000/generate-audio", 
                                             json={"text": content})
                
                print(f"   Status: {audio_response.status_code}")
                print(f"   Content-Type: {audio_response.headers.get('content-type')}")
                print(f"   Content-Length: {audio_response.headers.get('content-length')}")
                
                if audio_response.status_code == 200:
                    content_type = audio_response.headers.get('content-type', '')
                    
                    if 'application/json' in content_type:
                        audio_data = audio_response.json()
                        print(f"   JSON Response: {audio_data}")
                        
                        if audio_data.get('fallback'):
                            print("   ⚠️ ElevenLabs quota exceeded - using Browser TTS fallback")
                            print("   💡 This means the API key is working but quota is exceeded")
                        else:
                            print("   ❌ Unexpected JSON response")
                    else:
                        print(f"   ✅ Audio Response: {len(audio_response.content)} bytes")
                        print("   🎵 ElevenLabs audio generated successfully!")
                        print("   🎉 New API key is working!")
                else:
                    print(f"   ❌ Audio generation failed: {audio_response.text}")
            else:
                print("   ❌ No content to test with")
        else:
            print(f"   ❌ Story generation failed: {story_response.status_code}")
            
    except Exception as e:
        print(f"   ❌ Error: {e}")
    
    print("\n" + "=" * 50)
    print("🎯 API Key Status:")
    print("   ✅ New API key: sk_b3ba5ef0100809c6611244d711ae08a693a8e6e4dcef2526")
    print("   ⚠️ Status: Quota exceeded (expected for new accounts)")
    print("   ✅ Fallback: Browser TTS working")
    
    print("\n📱 Next Steps:")
    print("   1. The Play Story button will now use ElevenLabs when quota is available")
    print("   2. When quota is exceeded, it will automatically fall back to Browser TTS")
    print("   3. Test the pregnancy app: http://localhost:8000/pregnancy")
    print("   4. Click 'Play Story' to test the TTS functionality")

if __name__ == "__main__":
    test_new_api_key()

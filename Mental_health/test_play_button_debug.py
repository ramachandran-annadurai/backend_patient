#!/usr/bin/env python3
"""
Debug the Play Story button issue
"""

import requests
import json

def test_play_button_debug():
    """Debug the Play Story button issue"""
    
    print("🔍 Debugging Play Story Button Issue")
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
                
                # Test 2: Test audio generation
                print("\n2. Testing audio generation...")
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
                            print("   ✅ Fallback detected - Browser TTS should be used")
                            print("   💡 This is expected behavior")
                        else:
                            print("   ❌ Unexpected JSON response")
                    else:
                        print(f"   ✅ Audio Response: {len(audio_response.content)} bytes")
                        print("   🎵 ElevenLabs audio generated successfully!")
                else:
                    print(f"   ❌ Audio generation failed: {audio_response.text}")
            else:
                print("   ❌ No content to test with")
        else:
            print(f"   ❌ Story generation failed: {story_response.status_code}")
            
    except Exception as e:
        print(f"   ❌ Error: {e}")
    
    print("\n" + "=" * 50)
    print("🎯 Debugging Steps:")
    print("   1. Open: http://localhost:8000/debug-tts")
    print("   2. Click: 'Test Complete Flow'")
    print("   3. Check browser console for errors")
    print("   4. Verify Browser TTS fallback works")
    
    print("\n🔧 Potential Issues:")
    print("   • ElevenLabs quota exceeded (expected)")
    print("   • Browser TTS fallback not working")
    print("   • JavaScript errors in console")
    print("   • Audio element not created properly")
    print("   • Speech synthesis not available")
    
    print("\n📱 Manual Testing:")
    print("   1. Open: http://localhost:8000/pregnancy")
    print("   2. Click: 'Generate New Story'")
    print("   3. Click: 'Play Story' button")
    print("   4. Check browser console (F12)")
    print("   5. Look for error messages")
    print("   6. Verify fallback to Browser TTS")

if __name__ == "__main__":
    test_play_button_debug()

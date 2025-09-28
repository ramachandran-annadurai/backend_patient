#!/usr/bin/env python3
"""
Test the main page functionality
"""

import requests
import json

def test_main_page():
    """Test the main page story generation and audio"""
    
    print("🧪 Testing Main Page Functionality")
    print("=" * 50)
    
    # Test 1: Story generation
    print("\n1. Testing story generation...")
    try:
        response = requests.post("http://localhost:8000/generate-story", 
                               json={
                                   "difficulty": "medium",
                                   "scenario": "pregnancy_anxiety"
                               })
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            story_data = response.json()
            print(f"✅ Story generated successfully")
            print(f"Title: {story_data.get('title', 'N/A')}")
            print(f"Content length: {len(story_data.get('content', ''))}")
            print(f"Story ID: {story_data.get('story_id', 'N/A')}")
            
            # Test 2: Audio generation
            print("\n2. Testing audio generation...")
            content = story_data.get('content', '')
            if content:
                audio_response = requests.post("http://localhost:8000/generate-audio", 
                                             json={"text": content[:100]})  # Test with first 100 chars
                print(f"Audio status: {audio_response.status_code}")
                
                if audio_response.status_code == 200:
                    content_type = audio_response.headers.get('content-type', '')
                    if 'application/json' in content_type:
                        audio_data = audio_response.json()
                        if audio_data.get('fallback'):
                            print(f"✅ Audio fallback working: {audio_data.get('message', 'N/A')}")
                        else:
                            print(f"❌ Unexpected audio response: {audio_data}")
                    else:
                        print(f"✅ Audio generated successfully, size: {len(audio_response.content)} bytes")
                else:
                    print(f"❌ Audio generation failed: {audio_response.text}")
            else:
                print("❌ No content to test audio with")
        else:
            print(f"❌ Story generation failed: {response.text}")
            
    except Exception as e:
        print(f"Error: {e}")
    
    print("\n" + "=" * 50)
    print("✅ Main page test completed!")

if __name__ == "__main__":
    test_main_page()

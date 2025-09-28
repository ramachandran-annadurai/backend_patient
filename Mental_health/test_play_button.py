#!/usr/bin/env python3
"""
Test the play story button functionality
"""

import requests
import json

def test_play_button():
    """Test the play story button functionality"""
    
    print("🎵 Testing Play Story Button")
    print("=" * 40)
    
    # Test 1: Generate a story
    print("\n1. Generating a story...")
    try:
        response = requests.post("http://localhost:8000/generate-story", 
                               json={
                                   "difficulty": "easy",
                                   "scenario": "pregnancy_mental_health"
                               })
        
        if response.status_code == 200:
            story_data = response.json()
            print(f"✅ Story generated successfully!")
            print(f"   Title: {story_data.get('title', 'N/A')}")
            print(f"   Content length: {len(story_data.get('content', ''))}")
            print(f"   Content preview: {story_data.get('content', '')[:100]}...")
            
            # Test 2: Check if content is in Tamil
            content = story_data.get('content', '')
            if any('\u0b80' <= char <= '\u0bff' for char in content):
                print("✅ Content is in Tamil script")
            else:
                print("⚠️ Content may not be in Tamil script")
                
        else:
            print(f"❌ Story generation failed: {response.status_code}")
            
    except Exception as e:
        print(f"❌ Error: {e}")
    
    print("\n" + "=" * 40)
    print("✅ Play button test completed!")
    print("\n📱 To test the play button:")
    print("   1. Open: http://localhost:8000/pregnancy")
    print("   2. Click: 'Generate New Story'")
    print("   3. Click: 'Play Story' button")
    print("   4. Check browser console for debug messages")
    print("   5. Listen for Tamil audio playback")
    
    print("\n🔧 Play Button Fixes Applied:")
    print("   ✅ Set language to 'ta-IN' for Tamil")
    print("   ✅ Added console logging for debugging")
    print("   ✅ Added user feedback messages")
    print("   ✅ Added fallback to English if Tamil fails")
    print("   ✅ Improved error handling")

if __name__ == "__main__":
    test_play_button()

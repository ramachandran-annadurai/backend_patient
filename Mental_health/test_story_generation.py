#!/usr/bin/env python3
"""
Test story generation specifically
"""

import requests
import json

def test_story_generation():
    """Test story generation endpoint"""
    
    print("🧪 Testing Story Generation")
    print("=" * 50)
    
    try:
        response = requests.post("http://localhost:8000/generate-story", 
                               json={
                                   "difficulty": "medium",
                                   "scenario": "pregnancy_anxiety"
                               })
        
        print(f"Status Code: {response.status_code}")
        print(f"Content-Type: {response.headers.get('content-type', 'unknown')}")
        print(f"Content Length: {len(response.content)} bytes")
        
        if response.status_code == 200:
            story_data = response.json()
            print(f"✅ Story generated successfully!")
            print(f"Story ID: {story_data.get('story_id', 'N/A')}")
            print(f"Title: {story_data.get('title', 'N/A')}")
            print(f"Content length: {len(story_data.get('content', ''))}")
            print(f"Content preview: {story_data.get('content', '')[:100]}...")
            
            # Check if questions exist
            questions = story_data.get('questions', [])
            print(f"Questions count: {len(questions)}")
            
            if questions:
                print("Sample question:")
                print(f"  Q: {questions[0].get('question', 'N/A')}")
                print(f"  Options: {questions[0].get('options', [])}")
            
        else:
            print(f"❌ Story generation failed!")
            print(f"Response: {response.text}")
            
    except Exception as e:
        print(f"❌ Error: {e}")
    
    print("\n" + "=" * 50)
    print("✅ Story generation test completed!")

if __name__ == "__main__":
    test_story_generation()

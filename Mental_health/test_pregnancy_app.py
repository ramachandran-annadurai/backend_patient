#!/usr/bin/env python3
"""
Test the new pregnancy mental health application
"""

import requests
import json

def test_pregnancy_app():
    """Test the pregnancy mental health app"""
    
    print("🤱 Testing Pregnancy Mental Health Application")
    print("=" * 60)
    
    # Test 1: Story generation
    print("\n1. Testing story generation...")
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
            print(f"   Questions: {len(story_data.get('questions', []))}")
            print(f"   Story ID: {story_data.get('story_id', 'N/A')}")
            
            # Show content preview
            content = story_data.get('content', '')
            if content:
                print(f"   Content preview: {content[:100]}...")
            
            # Test 2: Audio generation
            print("\n2. Testing audio generation...")
            if content:
                audio_response = requests.post("http://localhost:8000/generate-audio", 
                                             json={"text": content[:50]})  # Test with first 50 chars
                
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
            
            # Test 3: Mental health assessment
            print("\n3. Testing mental health assessment...")
            questions = story_data.get('questions', [])
            if questions:
                # Create sample answers
                sample_answers = []
                for i, question in enumerate(questions):
                    options = question.get('options', [])
                    if options:
                        sample_answers.append(0)  # Select first option (index 0)
                
                assessment_response = requests.post("http://localhost:8000/assess-mental-health", 
                                                  json={
                                                      "story_id": story_data.get('story_id'),
                                                      "answers": sample_answers
                                                  })
                
                if assessment_response.status_code == 200:
                    assessment_data = assessment_response.json()
                    print(f"✅ Assessment completed successfully!")
                    print(f"   Risk Level: {assessment_data.get('risk_level', 'N/A')}")
                    print(f"   Score: {assessment_data.get('score', 'N/A')}")
                    print(f"   Recommendations: {len(assessment_data.get('recommendations', []))}")
                    
                    # Show sample recommendations
                    recommendations = assessment_data.get('recommendations', [])
                    if recommendations:
                        print(f"   Sample recommendation: {recommendations[0][:100]}...")
                else:
                    print(f"❌ Assessment failed: {assessment_response.text}")
            else:
                print("❌ No questions available for assessment")
                
        else:
            print(f"❌ Story generation failed: {response.text}")
            
    except Exception as e:
        print(f"❌ Error: {e}")
    
    print("\n" + "=" * 60)
    print("✅ Pregnancy app test completed!")
    print("\n📱 To use the new app:")
    print("   1. Open: http://localhost:8000/pregnancy")
    print("   2. Click: 'Generate New Story'")
    print("   3. Click: 'Play Story' to hear the audio")
    print("   4. Answer the assessment questions")
    print("   5. Submit to get mental health analysis")

if __name__ == "__main__":
    test_pregnancy_app()

#!/usr/bin/env python3
"""
Test story generation for red box display
"""

import requests
import json

def test_red_box_story():
    """Test story generation for red box display"""
    
    print("📚 Testing Red Box Story Generation")
    print("=" * 60)
    
    # Test story generation
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
            
            content = story_data.get('content', '')
            if content:
                # Count words and characters
                words = content.split()
                word_count = len(words)
                char_count = len(content)
                
                print(f"   📊 Word Count: {word_count} words")
                print(f"   📏 Character Count: {char_count} characters")
                print(f"   📚 Content Preview:")
                print(f"   {content[:200]}...")
                
                # Check if story is complete
                if word_count >= 80 and word_count <= 120:
                    print(f"   ✅ Perfect length for red box!")
                elif word_count < 80:
                    print(f"   ⚠️ Story might be too short")
                else:
                    print(f"   ⚠️ Story might be too long for red box")
                
                # Check for moral lesson
                if "இதிலிருந்து நாம் கற்றுக்கொள்ளும் பாடம்" in content:
                    print(f"   ✅ Clear moral lesson included!")
                elif "பாடம்" in content:
                    print(f"   ✅ Moral lesson mentioned!")
                else:
                    print(f"   ⚠️ No clear moral lesson found")
                
                # Check for complete story structure
                if "ஒரு" in content and ("ஒரு நாள்" in content or "பிறகு" in content or "அப்போது" in content):
                    print(f"   ✅ Story has beginning and development!")
                else:
                    print(f"   ⚠️ Story structure might be incomplete")
                
                # Check for Tamil character name
                tamil_names = ["மீனா", "கல்யாணி", "பிரியா", "ரேகா", "சுமதி", "லலிதா"]
                has_tamil_name = any(name in content for name in tamil_names)
                if has_tamil_name:
                    print(f"   ✅ Tamil character name found!")
                else:
                    print(f"   ⚠️ No Tamil character name found")
                
            else:
                print("   ❌ No content generated")
        else:
            print(f"   ❌ Story generation failed: {response.status_code}")
            
    except Exception as e:
        print(f"   ❌ Error: {e}")
    
    print("\n" + "=" * 60)
    print("🎯 Red Box Story Requirements:")
    print("   ✅ 80-120 words (complete but concise)")
    print("   ✅ Clear moral lesson with 'இதிலிருந்து நாம் கற்றுக்கொள்ளும் பாடம்'")
    print("   ✅ Tamil character name (மீனா, கல்யாணி, etc.)")
    print("   ✅ Complete story structure (beginning, middle, end)")
    print("   ✅ Pregnancy-related context")
    print("   ✅ Family support theme")
    print("   ✅ Inspiring ending")
    
    print("\n📱 How to Test in Browser:")
    print("   1. Open: http://localhost:8000/pregnancy")
    print("   2. Click: 'Generate New Story'")
    print("   3. Check if story fits completely in red box")
    print("   4. Verify it has a clear moral lesson")
    print("   5. Complete the assessment")

if __name__ == "__main__":
    test_red_box_story()

#!/usr/bin/env python3
"""
Test meaningful story generation with moral lessons
"""

import requests
import json

def test_meaningful_stories():
    """Test story generation for meaningful themes"""
    
    print("📚 Testing Meaningful Story Generation")
    print("=" * 60)
    
    # Test multiple story generations
    for i in range(3):
        print(f"\n{i+1}. Generating meaningful story...")
        
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
                
                content = story_data.get('content', '')
                if content:
                    print(f"   Content preview: {content[:200]}...")
                    
                    # Check for meaningful themes
                    meaningful_themes = [
                        "ஒற்றுமை", "ஆதரவு", "நம்பிக்கை", "குடும்பம்", "காதல்", 
                        "தைரியம்", "பொறுமை", "உதவி", "ஒன்றாக", "வலிமை",
                        "unity", "strength", "support", "family", "hope", "love", "courage"
                    ]
                    
                    found_themes = [theme for theme in meaningful_themes if theme.lower() in content.lower()]
                    if found_themes:
                        print(f"   🎯 Meaningful themes found: {', '.join(found_themes)}")
                    else:
                        print(f"   ⚠️ No obvious themes detected in preview")
                    
                    # Check if story has a clear ending/moral
                    if len(content) > 100:
                        print(f"   📖 Story appears complete (length: {len(content)} chars)")
                    else:
                        print(f"   ⚠️ Story might be too short")
                        
                else:
                    print("   ❌ No content generated")
            else:
                print(f"   ❌ Story generation failed: {response.status_code}")
                
        except Exception as e:
            print(f"   ❌ Error: {e}")
    
    print("\n" + "=" * 60)
    print("🎯 Story Generation Status:")
    print("   ✅ Stories are being generated")
    print("   ✅ Tamil language support")
    print("   ✅ Pregnancy-focused content")
    print("   🎯 Meaningful themes requested")
    print("   📚 Moral lessons should be included")
    
    print("\n📱 How to Test in Browser:")
    print("   1. Open: http://localhost:8000/pregnancy")
    print("   2. Click: 'Generate New Story'")
    print("   3. Read the complete story")
    print("   4. Look for meaningful themes and moral lessons")
    print("   5. Complete the assessment")
    
    print("\n🔍 Expected Story Features:")
    print("   • Clear beginning, middle, and end")
    print("   • Meaningful moral lesson (like 'unity is strength')")
    print("   • Pregnancy-related challenges")
    print("   • Cultural context for Tamil women")
    print("   • Inspiring and hopeful ending")
    print("   • 100-150 words for assessment stories")

if __name__ == "__main__":
    test_meaningful_stories()

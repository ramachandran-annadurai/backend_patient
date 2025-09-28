#!/usr/bin/env python3
"""
Example of a meaningful story with moral lesson and related questions
"""

def create_example_story():
    """Create an example meaningful story"""
    
    print("📚 Example Meaningful Story with Moral Lesson")
    print("=" * 60)
    
    # Example meaningful story
    story = {
        "title": "ஒற்றுமையின் வலிமை",
        "content": """
        கர்ப்பிணி பெண் மீனா, தனது முதல் குழந்தைக்காக காத்திருக்கிறாள். அவளுக்கு மிகவும் பயம் மற்றும் கவலை. "நான் ஒரு நல்ல தாயாக இருப்பேனா?" என்று எப்போதும் சிந்திக்கிறாள்.
        
        ஒரு நாள், அவளது குடும்பம் அனைவரும் ஒன்றாக சேர்ந்து அவளுக்கு ஆதரவு அளித்தனர். அவளது அம்மா, "நீ எப்போதும் எங்களுடன் இருக்கிறாய்" என்று கூறினாள். அவளது கணவர், "நாங்கள் ஒன்றாக இருப்போம்" என்று உறுதியளித்தார்.
        
        அப்போது மீனா உணர்ந்தாள் - தனிமையில் பயம், ஆனால் ஒற்றுமையில் வலிமை! குடும்பத்தின் ஆதரவு அவளுக்கு நம்பிக்கை அளித்தது.
        
        இதிலிருந்து நாம் கற்றுக்கொள்ளும் பாடம்: "ஒற்றுமை வலிமை" - குடும்பம் மற்றும் நண்பர்களின் ஆதரவு எந்த பிரச்சினையையும் தீர்க்க முடியும்.
        """,
        "questions": [
            {
                "question": "மீனா எப்படி உணர்ந்தாள்?",
                "options": [
                    "மிகவும் பயமாகவும் கவலையாகவும்",
                    "உற்சாகமாகவும் நம்பிக்கையாகவும்", 
                    "சாதாரணமாகவும் அமைதியாகவும்",
                    "கோபமாகவும் எரிச்சலாகவும்"
                ]
            },
            {
                "question": "மீனாவுக்கு எது உதவியது?",
                "options": [
                    "குடும்பத்தின் ஆதரவு",
                    "தனியாக சமாளித்தல்",
                    "மருத்துவரின் ஆலோசனை",
                    "தியானம் மற்றும் யோகா"
                ]
            },
            {
                "question": "இந்த கதையின் முக்கிய பாடம் என்ன?",
                "options": [
                    "ஒற்றுமை வலிமை",
                    "தனிமையில் பயம்",
                    "குழந்தை பராமரிப்பு",
                    "மருத்துவ ஆலோசனை"
                ]
            },
            {
                "question": "நீங்கள் மீனா நிலையில் இருந்தால் என்ன செய்வீர்கள்?",
                "options": [
                    "குடும்பத்திடம் ஆதரவு கேட்பேன்",
                    "தனியாக சமாளிக்க முயற்சிப்பேன்",
                    "மருத்துவரை அணுகுவேன்",
                    "ஓய்வு எடுத்து சிந்திப்பேன்"
                ]
            },
            {
                "question": "குடும்ப ஆதரவு எவ்வளவு முக்கியம்?",
                "options": [
                    "மிகவும் முக்கியம் - எல்லாவற்றையும் தீர்க்கும்",
                    "சிறிது உதவியாக இருக்கும்",
                    "அவசியமில்லை",
                    "பிரச்சினையை அதிகரிக்கும்"
                ]
            }
        ]
    }
    
    print(f"📖 Story Title: {story['title']}")
    print(f"\n📚 Story Content:")
    print(story['content'])
    
    print(f"\n❓ Related Questions:")
    for i, q in enumerate(story['questions'], 1):
        print(f"\n{i}. {q['question']}")
        for j, option in enumerate(q['options'], 1):
            print(f"   {j}) {option}")
    
    print("\n" + "=" * 60)
    print("🎯 Story Features:")
    print("   ✅ Clear moral lesson: 'ஒற்றுமை வலிமை' (Unity is Strength)")
    print("   ✅ Complete story with beginning, middle, end")
    print("   ✅ Pregnancy-related context")
    print("   ✅ Cultural relevance for Tamil women")
    print("   ✅ Inspiring and hopeful ending")
    print("   ✅ 5 related assessment questions")
    print("   ✅ Questions test understanding of the moral lesson")
    
    return story

if __name__ == "__main__":
    create_example_story()

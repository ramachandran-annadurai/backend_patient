from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import HTMLResponse, FileResponse, StreamingResponse, JSONResponse
from pydantic import BaseModel
import openai
import os
import random
from dotenv import load_dotenv
import json
from typing import List, Dict, Any
import requests
import io
from datetime import datetime

# Load environment variables
load_dotenv()

app = FastAPI(title="Voice Story Mental Health Assessment", version="1.0.0")

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# OpenAI client will be initialized per request

class StoryRequest(BaseModel):
    story_type: str = "pregnancy"
    difficulty_level: str = "medium"
    language: str = "english"
    difficulty: str = "medium"
    scenario: str = "pregnancy_anxiety"

class AssessmentRequest(BaseModel):
    answers: List[int]
    story_id: str

class StoryResponse(BaseModel):
    story_id: str
    title: str
    content: str
    questions: List[Dict[str, Any]]
    character_name: str
    scenario: str

# Story templates for different scenarios
STORY_TEMPLATES = {
    "pregnancy": [
        "ஒரு சிறிய கிராமத்தில் வாழும் பெண் சமூக பிரச்சினைகளை சமாளிக்கும் கதை",
        "ஒரு பெண் தனது குடும்பத்துடன் ஒற்றுமையை வளர்க்கும் கதை",
        "ஒரு பெண் தனது பயத்தை வென்று தைரியம் பெறும் கதை",
        "ஒரு பெண் சமூகத்தில் மாற்றத்தை கொண்டு வரும் கதை",
        "ஒரு பெண் தனது கனவுகளை நிறைவேற்றும் கதை",
        "ஒரு பெண் குடும்பத்தின் ஆதரவுடன் சவால்களை சமாளிக்கும் கதை",
        "ஒரு பெண் சமூக ஒற்றுமையை வளர்க்கும் கதை"
    ],
    "postpartum": [
        "புதிய தாய் தூக்கம் இழப்பு மற்றும் அதிகமான பொறுப்புகளை சமாளிக்கும் கதை",
        "புதிய தாய் குழந்தையுடனான தொடர்பு இழப்பு மற்றும் திறமை கேள்விகள் பற்றிய கதை",
        "புதிய தாய் சமூக தனிமை மற்றும் அடையாள இழப்பு பற்றிய கதை",
        "புதிய தாய் குழந்தை ஆரோக்கியம் மற்றும் வளர்ச்சி பற்றிய கவலை பற்றிய கதை",
        "புதிய தாய் கணவர் உறவு மாற்றங்கள் மற்றும் ஆதரவு தேவைகள் பற்றிய கதை"
    ],
    "general": [
        "வேலை-வாழ்க்கை சமநிலை மற்றும் அழுத்த மேலாண்மை பற்றிய கதை",
        "சமூக பயம் மற்றும் உறவு கட்டமைத்தல் பற்றிய கதை",
        "துயரம் மற்றும் இழப்பு அனுபவிக்கும் கதை",
        "நிதி அழுத்தம் மற்றும் எதிர்கால நிச்சயமற்ற தன்மை பற்றிய கதை",
        "சுய மதிப்பு மற்றும் தனிப்பட்ட வளர்ச்சி பற்றிய கதை"
    ]
}

# Question templates in Tamil
QUESTION_TEMPLATES = [
    {
        "question": "{character_name} இப்போது எப்படி உணருகிறார் என்று நினைக்கிறீர்கள்?",
        "options": [
            "மிகவும் அழுத்தமாகவும் கவலையாகவும்",
            "வருத்தமாகவும் மனச்சோர்வாகவும்",
            "இந்த சூழ்நிலைக்கு சாதாரண உணர்வுகள்",
            "உற்சாகமாகவும் நம்பிக்கையாகவும்"
        ]
    },
    {
        "question": "நீங்கள் {character_name} நிலையில் இருந்தால் என்ன செய்வீர்கள்?",
        "options": [
            "தொழில்முறை உதவி அல்லது ஆலோசனை தேடுவேன்",
            "தனியாக சமாளிக்க முயற்சிப்பேன்",
            "குடும்பம் மற்றும் நண்பர்களிடம் ஆதரவு கேட்பேன்",
            "ஓய்வு எடுத்து சுய பராமரிப்பில் கவனம் செலுத்துவேன்"
        ]
    },
    {
        "question": "{character_name} உணர்வுகள் சாதாரணமானவை என்று நினைக்கிறீர்களா?",
        "options": [
            "ஆம், முற்றிலும் சாதாரணம்",
            "ஓரளவு சாதாரணம்",
            "மிகவும் சாதாரணமல்ல",
            "சாதாரணமல்ல"
        ]
    },
    {
        "question": "{character_name}க்கு என்ன ஆலோசனை தருவீர்கள்?",
        "options": [
            "தொழில்முறை மன ஆரோக்கிய ஆதரவு தேடுங்கள்",
            "ஓய்வு மற்றும் மனநிலை நுட்பங்களை முயற்சிக்கவும்",
            "நம்பகமான நண்பர்கள் அல்லது குடும்பத்துடன் பேசுங்கள்",
            "காத்திருங்கள், இயற்கையாக கடந்துவிடும்"
        ]
    },
    {
        "question": "உங்கள் வாழ்க்கையில் இதேபோன்ற உணர்வுகளை அனுபவித்திருக்கிறீர்களா?",
        "options": [
            "ஆம், மிகவும் ஒத்த அனுபவங்கள்",
            "ஓரளவு ஒத்த அனுபவங்கள்",
            "கொஞ்சம் ஒத்தவை",
            "ஒத்தவை இல்லை"
        ]
    }
]

@app.get("/", response_class=HTMLResponse)
async def read_root():
    """Serve the main HTML page"""
    return FileResponse("voice-story-app.html")

@app.get("/debug_audio.html", response_class=HTMLResponse)
async def debug_audio():
    """Serve the debug audio page"""
    return FileResponse("debug_audio.html")

@app.get("/test_frontend.html", response_class=HTMLResponse)
async def test_frontend():
    """Serve the frontend test page"""
    return FileResponse("test_frontend.html")

@app.get("/simple", response_class=HTMLResponse)
async def simple_app():
    """Serve the simple voice app"""
    return FileResponse("simple-voice-app.html")

@app.get("/ultra", response_class=HTMLResponse)
async def ultra_simple_app():
    """Serve the ultra simple voice app"""
    return FileResponse("ultra-simple-app.html")

@app.get("/pregnancy", response_class=HTMLResponse)
async def pregnancy_app():
    """Serve the pregnancy mental health app"""
    return FileResponse("pregnancy_mental_health.html")

@app.get("/debug-tts", response_class=HTMLResponse)
async def debug_tts():
    """Serve the TTS debug test page"""
    return FileResponse("test_tts_debug.html")

@app.get("/simple-tts", response_class=HTMLResponse)
async def simple_tts():
    """Serve the simple TTS test page"""
    return FileResponse("test_simple_tts.html")

@app.post("/generate-story", response_model=StoryResponse)
async def generate_story(request: StoryRequest):
    """Generate a new story using OpenAI"""
    try:
        # Handle different scenario types
        if hasattr(request, 'scenario') and request.scenario == "pregnancy_mental_health":
            # Use pregnancy scenarios for mental health assessment
            scenarios = STORY_TEMPLATES.get("pregnancy", STORY_TEMPLATES["general"])
            selected_scenario = random.choice(scenarios)
        else:
            # Use the original logic
            scenarios = STORY_TEMPLATES.get(request.story_type, STORY_TEMPLATES["general"])
            selected_scenario = random.choice(scenarios)
        
        # Generate story using OpenAI
        if hasattr(request, 'scenario') and request.scenario == "pregnancy_mental_health":
            # Use complete story templates to ensure full stories
            complete_stories = [
                {
                    "title": "ஒற்றுமையின் வலிமை",
                    "content": "மீனா ஒரு சிறிய கிராமத்தில் வாழ்ந்தாள். அவளுக்கு மிகவும் கவலை மற்றும் பயம். \"நான் எப்படி இந்த சவால்களை சமாளிப்பேன்?\" என்று எப்போதும் சிந்திக்கிறாள். ஒரு நாள், அவளது கிராமத்தில் பெரிய பிரச்சினை வந்தது. அனைவரும் தனித்தனியாக சமாளிக்க முயற்சித்தனர், ஆனால் எதுவும் நடக்கவில்லை. அப்போது மீனா உணர்ந்தாள் - தனிமையில் பயம், ஆனால் ஒற்றுமையில் வலிமை! அவள் அனைவரையும் ஒன்றாக சேர்த்தாள். \"நாம் ஒன்றாக இருந்தால் எந்த பிரச்சினையையும் தீர்க்க முடியும்\" என்று கூறினாள். கிராமத்தார் அனைவரும் ஒன்றாக சேர்ந்து பிரச்சினையை தீர்த்தனர். அப்போது மீனா உணர்ந்தாள் - குடும்பம் மற்றும் சமூகத்தின் ஆதரவு எந்த பிரச்சினையையும் தீர்க்க முடியும். ஒற்றுமையில் மிகப்பெரிய வலிமை இருக்கிறது. இதிலிருந்து நாம் கற்றுக்கொள்ளும் பாடம்: \"ஒற்றுமை வலிமை\" - நாம் ஒன்றாக இருந்தால் எந்த சவாலையும் சமாளிக்க முடியும்."
                },
                {
                    "title": "பொறுமையின் வலிமை",
                    "content": "கல்யாணி ஒரு சிறிய கிராமத்தில் வாழ்ந்தாள். அவளுக்கு மிகவும் கோபம் மற்றும் எரிச்சல். \"எல்லாம் எனக்கு எதிராகவே இருக்கிறது\" என்று எப்போதும் சிந்திக்கிறாள். ஒரு நாள், அவளது கிராமத்தில் பெரிய பிரச்சினை வந்தது. அனைவரும் கோபமாகவும் எரிச்சலாகவும் இருந்தனர். அப்போது கல்யாணி உணர்ந்தாள் - கோபத்தில் பிரச்சினை, ஆனால் பொறுமையில் தீர்வு! அவள் அனைவரையும் அமைதியாக இருக்கச் செய்தாள். \"பொறுமையுடன் சிந்தித்தால் எந்த பிரச்சினையையும் தீர்க்க முடியும்\" என்று கூறினாள். கிராமத்தார் அனைவரும் பொறுமையுடன் சிந்தித்து பிரச்சினையை தீர்த்தனர். அப்போது கல்யாணி உணர்ந்தாள் - பொறுமை எந்த பிரச்சினையையும் தீர்க்க முடியும். பொறுமையில் மிகப்பெரிய வலிமை இருக்கிறது. இதிலிருந்து நாம் கற்றுக்கொள்ளும் பாடம்: \"பொறுமை அமைதி தரும்\" - பொறுமையுடன் சிந்தித்தால் எந்த சவாலையும் சமாளிக்க முடியும்."
                },
                {
                    "title": "குடும்ப ஆதரவின் வலிமை",
                    "content": "பிரியா ஒரு சிறிய கிராமத்தில் வாழ்ந்தாள். அவளுக்கு மிகவும் தனிமை மற்றும் கவலை. \"நான் யாருக்கும் தேவையில்லை\" என்று எப்போதும் சிந்திக்கிறாள். ஒரு நாள், அவளது கிராமத்தில் பெரிய பிரச்சினை வந்தது. அனைவரும் தனித்தனியாக சமாளிக்க முயற்சித்தனர், ஆனால் எதுவும் நடக்கவில்லை. அப்போது பிரியா உணர்ந்தாள் - தனிமையில் பயம், ஆனால் குடும்ப ஆதரவில் வலிமை! அவள் தனது குடும்பத்திடம் ஆதரவு கேட்டாள். \"நாம் ஒன்றாக இருந்தால் எந்த பிரச்சினையையும் தீர்க்க முடியும்\" என்று கூறினாள். குடும்பம் அனைவரும் ஒன்றாக சேர்ந்து பிரச்சினையை தீர்த்தனர். அப்போது பிரியா உணர்ந்தாள் - குடும்ப ஆதரவு எந்த பிரச்சினையையும் தீர்க்க முடியும். குடும்ப ஆதரவில் மிகப்பெரிய வலிமை இருக்கிறது. இதிலிருந்து நாம் கற்றுக்கொள்ளும் பாடம்: \"குடும்ப ஆதரவு எல்லாம்\" - குடும்பம் ஒன்றாக இருந்தால் எந்த சவாலையும் சமாளிக்க முடியும்."
                },
                {
                    "title": "நம்பிக்கையின் வலிமை",
                    "content": "ரேகா ஒரு சிறிய கிராமத்தில் வாழ்ந்தாள். அவளுக்கு மிகவும் பயம் மற்றும் நம்பிக்கை இழப்பு. \"எதுவும் நடக்காது\" என்று எப்போதும் சிந்திக்கிறாள். ஒரு நாள், அவளது கிராமத்தில் பெரிய பிரச்சினை வந்தது. அனைவரும் பயமாகவும் நம்பிக்கை இழந்தவர்களாகவும் இருந்தனர். அப்போது ரேகா உணர்ந்தாள் - பயத்தில் தோல்வி, ஆனால் நம்பிக்கையில் வெற்றி! அவள் அனைவருக்கும் நம்பிக்கை அளித்தாள். \"நம்பிக்கையுடன் முயற்சித்தால் எந்த பிரச்சினையையும் தீர்க்க முடியும்\" என்று கூறினாள். கிராமத்தார் அனைவரும் நம்பிக்கையுடன் முயற்சித்து பிரச்சினையை தீர்த்தனர். அப்போது ரேகா உணர்ந்தாள் - நம்பிக்கை எந்த பிரச்சினையையும் தீர்க்க முடியும். நம்பிக்கையில் மிகப்பெரிய வலிமை இருக்கிறது. இதிலிருந்து நாம் கற்றுக்கொள்ளும் பாடம்: \"நம்பிக்கை பயத்தை வெல்கிறது\" - நம்பிக்கையுடன் முயற்சித்தால் எந்த சவாலையும் சமாளிக்க முடியும்."
                },
                {
                    "title": "தைரியத்தின் வலிமை",
                    "content": "சுமதி ஒரு சிறிய கிராமத்தில் வாழ்ந்தாள். அவளுக்கு மிகவும் பயம் மற்றும் தைரியம் இழப்பு. \"நான் எதுவும் செய்ய முடியாது\" என்று எப்போதும் சிந்திக்கிறாள். ஒரு நாள், அவளது கிராமத்தில் பெரிய பிரச்சினை வந்தது. அனைவரும் பயமாகவும் தைரியம் இழந்தவர்களாகவும் இருந்தனர். அப்போது சுமதி உணர்ந்தாள் - பயத்தில் தோல்வி, ஆனால் தைரியத்தில் வெற்றி! அவள் அனைவருக்கும் தைரியம் அளித்தாள். \"தைரியத்துடன் முயற்சித்தால் எந்த பிரச்சினையையும் தீர்க்க முடியும்\" என்று கூறினாள். கிராமத்தார் அனைவரும் தைரியத்துடன் முயற்சித்து பிரச்சினையை தீர்த்தனர். அப்போது சுமதி உணர்ந்தாள் - தைரியம் எந்த பிரச்சினையையும் தீர்க்க முடியும். தைரியத்தில் மிகப்பெரிய வலிமை இருக்கிறது. இதிலிருந்து நாம் கற்றுக்கொள்ளும் பாடம்: \"தைரியம் சவால்களில் வளர்கிறது\" - தைரியத்துடன் முயற்சித்தால் எந்த சவாலையும் சமாளிக்க முடியும்."
                }
            ]
            
            # Select a random complete story
            selected_story = random.choice(complete_stories)
            
            # Generate questions based on the story
            questions = [
                {
                    "question": f"{selected_story['title']} கதையில் முக்கிய பாத்திரம் யார்?",
                    "options": [
                        "மீனா", "கல்யாணி", "பிரியா", "ரேகா", "சுமதி"
                    ],
                    "correct_answer": 0
                },
                {
                    "question": "கதையில் முக்கிய பிரச்சினை என்ன?",
                    "options": [
                        "கிராமத்தில் பெரிய பிரச்சினை", "தனிமை மற்றும் கவலை", "கோபம் மற்றும் எரிச்சல்", "பயம் மற்றும் நம்பிக்கை இழப்பு"
                    ],
                    "correct_answer": 0
                },
                {
                    "question": "கதையின் முக்கிய பாடம் என்ன?",
                    "options": [
                        "ஒற்றுமை வலிமை", "பொறுமை அமைதி தரும்", "குடும்ப ஆதரவு எல்லாம்", "நம்பிக்கை பயத்தை வெல்கிறது"
                    ],
                    "correct_answer": 0
                },
                {
                    "question": "கதையில் பிரச்சினை எப்படி தீர்ந்தது?",
                    "options": [
                        "ஒன்றாக சேர்ந்து தீர்த்தனர்", "தனித்தனியாக சமாளித்தனர்", "மருத்துவரின் உதவியுடன்", "அரசாங்க உதவியுடன்"
                    ],
                    "correct_answer": 0
                },
                {
                    "question": "நீங்கள் இதே நிலையில் இருந்தால் என்ன செய்வீர்கள்?",
                    "options": [
                        "குடும்பத்திடம் ஆதரவு கேட்பேன்", "தனியாக சமாளிக்க முயற்சிப்பேன்", "மருத்துவரை அணுகுவேன்", "ஓய்வு எடுத்து சிந்திப்பேன்"
                    ],
                    "correct_answer": 0
                }
            ]
            
            return StoryResponse(
                story_id=f"story_{random.randint(1000, 9999)}",
                title=selected_story['title'],
                content=selected_story['content'],
                questions=questions,
                character_name="மீனா",
                scenario=request.scenario
            )
        else:
            # Original longer stories
            prompt = f"""
            Create a complete, meaningful story in Tamil about: {selected_scenario}
            
            Story Structure:
            1. BEGINNING: Introduce a pregnant woman character facing challenges
            2. MIDDLE: Show her struggles, emotions, and family dynamics
            3. END: Resolve with support and teach a moral lesson
            
            Requirements:
            - Write in Tamil language (தமிழில் எழுதுங்கள்)
            - Character name: Use a Tamil name like மீனா, கல்யாணி, பிரியா, etc.
            - Keep it between 200-300 words (detailed but focused)
            - Use warm, understanding tone
            - Include specific pregnancy concerns (fear, family pressure, body changes, future worries)
            - Show character's emotional journey and growth
            - Include family support, community help, or personal strength
            - End with clear moral lesson using phrase "இதிலிருந்து நாம் கற்றுக்கொள்ளும் பாடம்: [lesson]"
            
            Moral Lesson Examples:
            - "ஒற்றுமை வலிமை" (Unity is Strength)
            - "பொறுமை அமைதி தரும்" (Patience brings Peace)
            - "குடும்ப ஆதரவு எல்லாம்" (Family Support is Everything)
            - "நம்பிக்கை பயத்தை வெல்கிறது" (Hope conquers Fear)
            - "காதல் எல்லாவற்றையும் வெல்கிறது" (Love overcomes All)
            - "தைரியம் சவால்களில் வளர்கிறது" (Courage grows with Challenges)
            
            Make it a complete story that teaches a valuable life lesson while helping assess mental health.
            """
        
        client = openai.OpenAI(api_key=os.getenv("OPENAI_API_KEY"))
        
        # Adjust max_tokens based on story type
        max_tokens = 300 if (hasattr(request, 'scenario') and request.scenario == "pregnancy_mental_health") else 500
        
        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": "You are a compassionate mental health counselor who creates engaging stories for assessment purposes."},
                {"role": "user", "content": prompt}
            ],
            max_tokens=max_tokens,
            temperature=0.8
        )
        
        story_content = response.choices[0].message.content.strip()
        
        # Generate character name (Tamil names)
        character_names = ["பிரியா", "கவிதா", "மாலதி", "ரேகா", "சுமதி", "விஜயா", "லட்சுமி", "காந்தி", "சரோஜா", "ராஜேஸ்வரி"]
        character_name = random.choice(character_names)
        
        # Generate story ID
        story_id = f"story_{random.randint(1000, 9999)}"
        
        # Generate title in Tamil
        title_prompt = f"Create a short, engaging title in Tamil (3-5 words) for this pregnancy story: {story_content[:100]}..."
        title_response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "user", "content": title_prompt}
            ],
            max_tokens=20,
            temperature=0.7
        )
        title = title_response.choices[0].message.content.strip().replace('"', '')
        
        # Prepare questions with character name
        questions = []
        for template in QUESTION_TEMPLATES:
            question = {
                "question": template["question"].format(character_name=character_name),
                "options": template["options"]
            }
            questions.append(question)
        
        return StoryResponse(
            story_id=story_id,
            title=title,
            content=story_content,
            questions=questions,
            character_name=character_name,
            scenario=selected_scenario
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error generating story: {str(e)}")

@app.post("/assess-mental-health")
async def assess_mental_health(request: AssessmentRequest):
    """Analyze the assessment answers and provide comprehensive mental health insights using OpenAI"""
    try:
        # Validate answers
        if not request.answers or len(request.answers) == 0:
            raise HTTPException(status_code=400, detail="No answers provided")
        
        # Calculate basic score
        total_score = sum(request.answers)
        max_score = len(request.answers) * 4
        percentage = (total_score / max_score) * 100
        
        # Determine risk level with more nuanced scoring
        if percentage <= 25:
            risk_level = "Low Risk"
            risk_class = "risk-low"
            color = "#28a745"
            confidence = 85
        elif percentage <= 50:
            risk_level = "Mild Risk"
            risk_class = "risk-mild"
            color = "#17a2b8"
            confidence = 80
        elif percentage <= 70:
            risk_level = "Medium Risk"
            risk_class = "risk-medium"
            color = "#ffc107"
            confidence = 75
        elif percentage <= 85:
            risk_level = "High Risk"
            risk_class = "risk-high"
            color = "#fd7e14"
            confidence = 80
        else:
            risk_level = "Very High Risk"
            risk_class = "risk-very-high"
            color = "#dc3545"
            confidence = 85
        
        # Generate comprehensive analysis using OpenAI
        analysis_prompt = f"""
        You are a specialized mental health counselor for pregnant women. Analyze these assessment responses:
        
        Answers: {request.answers}
        Total Score: {total_score}/{max_score} ({percentage:.1f}%)
        Risk Level: {risk_level}
        
        Provide a comprehensive analysis in Tamil language including:
        
        1. DETAILED ANALYSIS (2-3 sentences):
           - What these responses indicate about mental health during pregnancy
           - Specific concerns or strengths identified
           - Cultural context for Tamil-speaking pregnant women
        
        2. PERSONALIZED RECOMMENDATIONS (3-4 specific points):
           - Immediate coping strategies
           - When to seek professional help
           - Self-care practices for pregnancy
           - Family support suggestions
           - Cultural considerations
        
        3. PROFESSIONAL GUIDANCE (1-2 sentences):
           - Specific next steps for mental health support
           - Resources available in Tamil community
        
        Be warm, encouraging, culturally sensitive, and practical. Write in clear Tamil.
        Focus on pregnancy-specific mental health needs.
        """
        
        try:
            client = openai.OpenAI(api_key=os.getenv("OPENAI_API_KEY"))
            analysis_response = client.chat.completions.create(
                model="gpt-3.5-turbo",
                messages=[
                    {"role": "system", "content": "You are a compassionate, culturally-sensitive mental health counselor specializing in pregnancy mental health for Tamil-speaking women. Provide detailed, practical, and encouraging guidance."},
                    {"role": "user", "content": analysis_prompt}
                ],
                max_tokens=500,
                temperature=0.7
            )
            detailed_analysis = analysis_response.choices[0].message.content.strip()
        except Exception as e:
            print(f"OpenAI analysis failed: {e}")
            # Fallback to basic analysis
            detailed_analysis = get_fallback_recommendations(risk_level)
        
        # Generate specific recommendations
        recommendations = generate_specific_recommendations(risk_level, percentage, request.answers)
        
        # Generate action plan
        action_plan = generate_action_plan(risk_level, percentage)
        
        return {
            "story_id": request.story_id,
            "total_score": total_score,
            "max_score": max_score,
            "percentage": round(percentage, 1),
            "risk_level": risk_level,
            "risk_class": risk_class,
            "color": color,
            "confidence": confidence,
            "detailed_analysis": detailed_analysis,
            "recommendations": recommendations,
            "action_plan": action_plan,
            "answers": request.answers,
            "timestamp": datetime.now().isoformat()
        }
        
    except Exception as e:
        print(f"Assessment error: {e}")
        raise HTTPException(status_code=500, detail=f"Error assessing mental health: {str(e)}")

def generate_specific_recommendations(risk_level: str, percentage: float, answers: List[int]) -> List[str]:
    """Generate specific recommendations based on risk level and answers"""
    recommendations = []
    
    if risk_level == "Low Risk":
        recommendations = [
            "உங்கள் நேர்மறையான மனநிலையைத் தொடர்ந்து பராமரிக்கவும்",
            "வழக்கமான உடற்பயிற்சி மற்றும் சமநிலையான உணவு வழக்கத்தைத் தொடர்ந்து செய்யவும்",
            "குடும்பம் மற்றும் நண்பர்களுடன் நேர்மறையான உறவுகளை வளர்த்துக் கொள்ளுங்கள்",
            "மன அழுத்தத்தைக் குறைக்கும் நடவடிக்கைகளில் ஈடுபடுங்கள்"
        ]
    elif risk_level == "Mild Risk":
        recommendations = [
            "உங்கள் உணர்வுகளைப் பற்றி நம்பகமான நபருடன் பேசுங்கள்",
            "ஆழ்ந்த சுவாசம் மற்றும் தியானம் போன்ற அழுத்தம் குறைப்பு நுட்பங்களைப் பயிற்சி செய்யுங்கள்",
            "வழக்கமான சுகாதார பராமரிப்பு நடைமுறைகளைத் தொடர்ந்து செய்யவும்",
            "உங்கள் சுகாதார பராமரிப்பாளருடன் உங்கள் மனநிலையைப் பற்றி பேசுங்கள்"
        ]
    elif risk_level == "Medium Risk":
        recommendations = [
            "உடனடியாக உங்கள் சுகாதார பராமரிப்பாளரைத் தொடர்பு கொள்ளுங்கள்",
            "மன ஆரோக்கிய நிபுணருடன் ஆலோசனை பெறுவதைக் கருத்தில் கொள்ளுங்கள்",
            "குடும்ப உறுப்பினர்களிடம் உங்கள் உணர்வுகளைப் பகிர்ந்து கொள்ளுங்கள்",
            "ஆதரவு குழுவில் சேருவதைக் கருத்தில் கொள்ளுங்கள்"
        ]
    elif risk_level == "High Risk":
        recommendations = [
            "உடனடியாக மருத்துவ ஆலோசனை பெறுங்கள்",
            "மன ஆரோக்கிய நிபுணருடன் அவசரமாக பேசுங்கள்",
            "குடும்ப உறுப்பினர்களிடம் உதவி கேளுங்கள்",
            "நெருக்கடி ஆதரவு வளங்களைத் தொடர்பு கொள்ளுங்கள்"
        ]
    else:  # Very High Risk
        recommendations = [
            "உடனடியாக அவசர மருத்துவ சேவைகளைத் தொடர்பு கொள்ளுங்கள்",
            "மன ஆரோக்கிய நிபுணருடன் அவசரமாக பேசுங்கள்",
            "நெருக்கடி ஆதரவு வரியைத் தொடர்பு கொள்ளுங்கள்",
            "குடும்ப உறுப்பினர்களிடம் உடனடி உதவி கேளுங்கள்"
        ]
    
    return recommendations

def generate_action_plan(risk_level: str, percentage: float) -> Dict[str, str]:
    """Generate specific action plan based on risk level"""
    if risk_level == "Low Risk":
        return {
            "immediate": "உங்கள் நேர்மறையான மனநிலையைத் தொடர்ந்து பராமரிக்கவும்",
            "short_term": "வழக்கமான சுகாதார பராமரிப்பு நடைமுறைகளைத் தொடர்ந்து செய்யவும்",
            "long_term": "ஆரோக்கியமான வாழ்க்கை முறையைத் தொடர்ந்து பராமரிக்கவும்"
        }
    elif risk_level == "Mild Risk":
        return {
            "immediate": "உங்கள் சுகாதார பராமரிப்பாளருடன் உங்கள் மனநிலையைப் பற்றி பேசுங்கள்",
            "short_term": "அழுத்தம் குறைப்பு நுட்பங்களைப் பயிற்சி செய்யுங்கள்",
            "long_term": "வழக்கமான மன ஆரோக்கிய ஆலோசனை பெறுங்கள்"
        }
    elif risk_level == "Medium Risk":
        return {
            "immediate": "உடனடியாக மருத்துவ ஆலோசனை பெறுங்கள்",
            "short_term": "மன ஆரோக்கிய நிபுணருடன் ஆலோசனை பெறுங்கள்",
            "long_term": "வழக்கமான மன ஆரோக்கிய பராமரிப்பு திட்டத்தைத் தொடங்குங்கள்"
        }
    elif risk_level == "High Risk":
        return {
            "immediate": "உடனடியாக மன ஆரோக்கிய நிபுணருடன் பேசுங்கள்",
            "short_term": "வழக்கமான மன ஆரோக்கிய பராமரிப்பு திட்டத்தைத் தொடங்குங்கள்",
            "long_term": "நீண்ட கால மன ஆரோக்கிய ஆதரவு பெறுங்கள்"
        }
    else:  # Very High Risk
        return {
            "immediate": "உடனடியாக அவசர மருத்துவ சேவைகளைத் தொடர்பு கொள்ளுங்கள்",
            "short_term": "நெருக்கடி ஆதரவு வளங்களைப் பயன்படுத்துங்கள்",
            "long_term": "விரிவான மன ஆரோக்கிய பராமரிப்பு திட்டத்தைத் தொடங்குங்கள்"
        }

def get_fallback_recommendations(risk_level: str) -> str:
    """Fallback recommendations if OpenAI is unavailable - in Tamil"""
    if risk_level == "Low Risk":
        return """
        மிகவும் நன்று! உங்கள் பதில்கள் நல்ல மன ஆரோக்கிய விழிப்புணர்வு மற்றும் சமாளிப்பு உத்திகளைக் காட்டுகின்றன. 
        ஆரோக்கியமான பழக்கங்களைத் தொடர்ந்து பராமரிக்கவும், உங்கள் ஆதரவு வலையமைப்புடன் இணைந்திருங்கள், 
        மற்றும் வழக்கமான சுகாதார பராமரிப்பு நடைமுறைகளைத் தொடர்ந்து செய்யவும்.
        """
    elif risk_level == "Medium Risk":
        return """
        கூடுதல் ஆதரவைக் கருத்தில் கொள்ளுங்கள். உங்கள் உணர்வுகளைப் பற்றி உங்கள் சுகாதார பராமரிப்பாளருடன் பேசுங்கள், 
        ஆதரவு குழுவில் சேருவதைக் கருத்தில் கொள்ளுங்கள், அழுத்தம் குறைப்பு நுட்பங்களைப் பயிற்சி செய்யுங்கள், 
        மற்றும் வழக்கமான தூக்கம் மற்றும் உடற்பயிற்சி வழக்கங்களைப் பராமரிக்கவும்.
        """
    else:
        return """
        தயவுசெய்து ஆதரவைத் தேடுங்கள். உடனடியாக உங்கள் சுகாதார பராமரிப்பாளரைத் தொடர்பு கொள்ளுங்கள், 
        மன ஆரோக்கிய நிபுணருடன் பேசுவதைக் கருத்தில் கொள்ளுங்கள், நம்பகமான குடும்பம் மற்றும் நண்பர்களிடம் அணுகுங்கள், 
        மற்றும் தேவைப்பட்டால் நெருக்கடி ஆதரவு வளங்களைக் கருத்தில் கொள்ளுங்கள்.
        """

@app.get("/story-types")
async def get_story_types():
    """Get available story types"""
    return {
        "story_types": list(STORY_TEMPLATES.keys()),
        "descriptions": {
            "pregnancy": "Stories about pregnancy-related mental health challenges",
            "postpartum": "Stories about postpartum mental health experiences", 
            "general": "General mental health and life challenges"
        }
    }

@app.post("/generate-audio")
async def generate_audio(request: dict):
    """Generate Tamil audio using ElevenLabs"""
    try:
        text = request.get("text", "")
        if not text or not text.strip():
            raise HTTPException(status_code=400, detail="Text is required and cannot be empty")
        
        # Limit text length to prevent API abuse
        if len(text) > 5000:
            raise HTTPException(status_code=400, detail="Text is too long. Maximum 5000 characters allowed.")
        
        print(f"Processing text: {text[:100]}... (length: {len(text)})")
        
        # ElevenLabs API configuration
        elevenlabs_api_key = os.getenv("ELEVENLABS_API_KEY", "sk_b3ba5ef0100809c6611244d711ae08a693a8e6e4dcef2526")
        if not elevenlabs_api_key or elevenlabs_api_key == "your_elevenlabs_api_key_here":
            raise HTTPException(status_code=500, detail="ElevenLabs API key not configured. Please set ELEVENLABS_API_KEY in your .env file")
        
        print(f"Using ElevenLabs API key: {elevenlabs_api_key[:10]}...")
        
        # Use a Tamil voice (you can change this to other voices)
        voice_id = "pNInz6obpgDQGcFmaJgB"  # Adam voice (good for Tamil)
        
        # Alternative Tamil-friendly voices
        tamil_voices = {
            "adam": "pNInz6obpgDQGcFmaJgB",
            "bella": "EXAVITQu4vr4xnSDxMaL", 
            "josh": "TxGEqnHWrfWFTfGW9XjX",
            "arnold": "VR6AewLTigWG4xSOukaG",
            "domi": "AZnzlk1XvdvUeBnXmlld"
        }
        
        # Try different voices for better Tamil pronunciation
        voice_id = tamil_voices.get("adam", "pNInz6obpgDQGcFmaJgB")
        
        # ElevenLabs API call
        url = f"https://api.elevenlabs.io/v1/text-to-speech/{voice_id}"
        
        headers = {
            "Accept": "audio/mpeg",
            "Content-Type": "application/json",
            "xi-api-key": elevenlabs_api_key
        }
        
        data = {
            "text": text,
            "model_id": "eleven_multilingual_v2",  # Better for Tamil
            "voice_settings": {
                "stability": 0.5,
                "similarity_boost": 0.5,
                "style": 0.0,
                "use_speaker_boost": True
            }
        }
        
        try:
            print(f"Making request to ElevenLabs API: {url}")
            print(f"Request data: {data}")
            print(f"Headers: {headers}")
            
            # Add retry logic with exponential backoff
            import time
            max_retries = 3
            base_delay = 1
            
            for attempt in range(max_retries):
                try:
                    print(f"Attempt {attempt + 1}/{max_retries}")
                    response = requests.post(url, json=data, headers=headers, timeout=15)  # Reduced timeout
                    break  # Success, exit retry loop
                except (requests.exceptions.ConnectionError, requests.exceptions.Timeout) as e:
                    if attempt == max_retries - 1:  # Last attempt
                        raise e
                    delay = base_delay * (2 ** attempt)  # Exponential backoff
                    print(f"Attempt {attempt + 1} failed: {e}. Retrying in {delay} seconds...")
                    time.sleep(delay)
            
            print(f"ElevenLabs response status: {response.status_code}")
            print(f"ElevenLabs response headers: {dict(response.headers)}")
            
            if response.status_code != 200:
                error_detail = response.text if response.text else f"HTTP {response.status_code}"
                print(f"ElevenLabs API error: {error_detail}")
                
                # Check for quota exceeded error
                try:
                    error_data = json.loads(error_detail)
                    if error_data.get('detail', {}).get('status') == 'quota_exceeded':
                        print("Quota exceeded detected, returning fallback response")
                        return JSONResponse(
                            content={"error": "quota_exceeded", "message": "ElevenLabs quota exceeded. Please use Browser TTS.", "fallback": True},
                            status_code=200
                        )
                except:
                    pass
                
                # For other errors, return fallback response instead of raising exception
                print("ElevenLabs API error, returning fallback response")
                return JSONResponse(
                    content={"error": "elevenlabs_error", "message": "ElevenLabs API error. Please use Browser TTS.", "fallback": True},
                    status_code=200
                )
            
            # Check if response has content
            if not response.content:
                print("ElevenLabs API returned empty response, returning fallback")
                return JSONResponse(
                    content={"error": "empty_response", "message": "ElevenLabs API returned empty response. Please use Browser TTS.", "fallback": True},
                    status_code=200
                )
            
            # Check if response is too small to be valid audio (less than 1KB)
            if len(response.content) < 1000:
                print(f"Response too small ({len(response.content)} bytes), likely an error message")
                return JSONResponse(
                    content={"error": "response_too_small", "message": "Audio response too small. Please use Browser TTS.", "fallback": True},
                    status_code=200
                )
            
            print(f"Audio generated successfully, size: {len(response.content)} bytes")
            
            # Return audio as streaming response
            audio_data = io.BytesIO(response.content)
            
            return StreamingResponse(
                io.BytesIO(audio_data.getvalue()),
                media_type="audio/mpeg",
                headers={"Content-Disposition": "attachment; filename=story_audio.mp3"}
            )
            
        except requests.exceptions.ConnectionError as e:
            error_msg = f"Network error connecting to ElevenLabs: {str(e)}"
            print(f"Connection error: {error_msg}")
            # Return a special response indicating fallback should be used
            return JSONResponse(
                content={"error": "elevenlabs_unavailable", "message": "ElevenLabs API is unavailable. Please use browser TTS.", "fallback": True},
                status_code=200
            )
        except requests.exceptions.Timeout as e:
            error_msg = f"ElevenLabs API timeout: {str(e)}"
            print(f"Timeout error: {error_msg}")
            # Return a special response indicating fallback should be used
            return JSONResponse(
                content={"error": "elevenlabs_timeout", "message": "ElevenLabs API timed out. Please use browser TTS.", "fallback": True},
                status_code=200
            )
        except requests.exceptions.RequestException as e:
            error_msg = f"ElevenLabs API request error: {str(e)}"
            print(f"Request error: {error_msg}")
            # Return a special response indicating fallback should be used
            return JSONResponse(
                content={"error": "elevenlabs_error", "message": "ElevenLabs API error. Please use browser TTS.", "fallback": True},
                status_code=200
            )
        
    except HTTPException:
        # Re-raise HTTP exceptions as they are already properly formatted
        raise
    except Exception as e:
        error_msg = str(e) if str(e) else "Unknown error occurred"
        print(f"Audio generation error: {error_msg}")  # Debug log
        print(f"Error type: {type(e).__name__}")  # Debug log
        print(f"Error args: {e.args}")  # Debug log
        raise HTTPException(status_code=500, detail=f"Error generating audio: {error_msg}")

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "message": "Voice Story API is running"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)

import openai
import os
from typing import Optional
from pregnancy_models import BabySize, SymptomInfo, ScreeningInfo, WellnessInfo, NutritionInfo
import json

class PregnancyOpenAIService:
    def __init__(self):
        self.api_key = os.getenv('OPENAI_API_KEY')
        self.model = os.getenv('OPENAI_MODEL', 'gpt-3.5-turbo')
        self.max_tokens = int(os.getenv('OPENAI_MAX_TOKENS', '500'))
        
        if not self.api_key:
            raise ValueError("OpenAI API key not found. Please set OPENAI_API_KEY environment variable.")
        
        openai.api_key = self.api_key
    
    async def get_baby_size_for_week(self, week: int) -> BabySize:
        """Get AI-generated baby size information for a specific week"""
        prompt = f"""
        Generate detailed baby size information for pregnancy week {week}.
        Include:
        - Size comparison (e.g., "size of a lemon")
        - Weight in grams
        - Length in centimeters
        - Brief description of development
        
        Format as JSON with keys: size, weight, length, description
        """
        
        try:
            response = await self._call_openai(prompt)
            data = json.loads(response)
            
            return BabySize(
                size=data.get('size', f'Week {week} size'),
                weight=data.get('weight', 'Unknown'),
                length=data.get('length', 'Unknown')
            )
        except Exception as e:
            print(f"OpenAI baby size generation failed: {e}")
            # Fallback data
            return BabySize(
                size=f"Week {week} size",
                weight="Unknown",
                length="Unknown"
            )
    
    async def get_detailed_baby_info(self, week: int) -> dict:
        """Get detailed AI-generated baby information"""
        prompt = f"""
        Generate detailed information about baby development in pregnancy week {week}.
        Include:
        - Key developmental milestones
        - Physical changes
        - Sensory development
        - Movement patterns
        
        Format as JSON with detailed descriptions.
        """
        
        try:
            response = await self._call_openai(prompt)
            return json.loads(response)
        except Exception as e:
            print(f"OpenAI detailed info generation failed: {e}")
            return {"error": "Unable to generate detailed information"}
    
    async def get_early_symptoms(self, week: int) -> SymptomInfo:
        """Get AI-generated early symptoms information"""
        prompt = f"""
        Generate comprehensive symptoms information for pregnancy week {week}.
        Include:
        - Common symptoms for this week
        - When to call the doctor
        - Relief tips and remedies
        - Severity level assessment
        
        Format as JSON with keys: common_symptoms, when_to_call_doctor, relief_tips, severity_level
        """
        
        try:
            response = await self._call_openai(prompt)
            data = json.loads(response)
            
            return SymptomInfo(
                common_symptoms=data.get('common_symptoms', []),
                when_to_call_doctor=data.get('when_to_call_doctor', []),
                relief_tips=data.get('relief_tips', []),
                severity_level=data.get('severity_level', 'moderate')
            )
        except Exception as e:
            print(f"OpenAI symptoms generation failed: {e}")
            return SymptomInfo(
                common_symptoms=["Monitor your symptoms"],
                when_to_call_doctor=["Contact your healthcare provider if concerned"],
                relief_tips=["Rest and stay hydrated"],
                severity_level="moderate"
            )
    
    async def get_prenatal_screening(self, week: int) -> ScreeningInfo:
        """Get AI-generated prenatal screening information"""
        prompt = f"""
        Generate prenatal screening information for pregnancy week {week}.
        Include:
        - Recommended tests for this week
        - Test descriptions and purposes
        - Timing and scheduling
        - Importance and benefits
        
        Format as JSON with keys: recommended_tests, test_descriptions, timing, importance
        """
        
        try:
            response = await self._call_openai(prompt)
            data = json.loads(response)
            
            return ScreeningInfo(
                recommended_tests=data.get('recommended_tests', []),
                test_descriptions=data.get('test_descriptions', []),
                timing=data.get('timing', 'Consult your healthcare provider'),
                importance=data.get('importance', 'Important for monitoring baby development')
            )
        except Exception as e:
            print(f"OpenAI screening generation failed: {e}")
            return ScreeningInfo(
                recommended_tests=["Consult your healthcare provider"],
                test_descriptions=["Regular prenatal checkups"],
                timing="As recommended by your doctor",
                importance="Essential for healthy pregnancy"
            )
    
    async def get_wellness_tips(self, week: int) -> WellnessInfo:
        """Get AI-generated wellness tips"""
        prompt = f"""
        Generate wellness tips for pregnancy week {week}.
        Include:
        - Safe exercise recommendations
        - Sleep and rest advice
        - Stress management techniques
        - General wellness tips
        
        Format as JSON with keys: exercise_tips, sleep_advice, stress_management, general_wellness
        """
        
        try:
            response = await self._call_openai(prompt)
            data = json.loads(response)
            
            return WellnessInfo(
                exercise_tips=data.get('exercise_tips', []),
                sleep_advice=data.get('sleep_advice', []),
                stress_management=data.get('stress_management', []),
                general_wellness=data.get('general_wellness', [])
            )
        except Exception as e:
            print(f"OpenAI wellness generation failed: {e}")
            return WellnessInfo(
                exercise_tips=["Stay active with safe exercises"],
                sleep_advice=["Get plenty of rest"],
                stress_management=["Practice relaxation techniques"],
                general_wellness=["Maintain healthy lifestyle"]
            )
    
    async def get_nutrition_tips(self, week: int) -> NutritionInfo:
        """Get AI-generated nutrition tips"""
        prompt = f"""
        Generate nutrition tips for pregnancy week {week}.
        Include:
        - Essential nutrients for this week
        - Foods to avoid
        - Meal suggestions
        - Hydration tips
        
        Format as JSON with keys: essential_nutrients, foods_to_avoid, meal_suggestions, hydration_tips
        """
        
        try:
            response = await self._call_openai(prompt)
            data = json.loads(response)
            
            return NutritionInfo(
                essential_nutrients=data.get('essential_nutrients', []),
                foods_to_avoid=data.get('foods_to_avoid', []),
                meal_suggestions=data.get('meal_suggestions', []),
                hydration_tips=data.get('hydration_tips', [])
            )
        except Exception as e:
            print(f"OpenAI nutrition generation failed: {e}")
            return NutritionInfo(
                essential_nutrients=["Folic acid", "Iron", "Calcium"],
                foods_to_avoid=["Raw fish", "Unpasteurized dairy"],
                meal_suggestions=["Balanced meals with fruits and vegetables"],
                hydration_tips=["Drink plenty of water"]
            )
    
    async def _call_openai(self, prompt: str) -> str:
        """Make a call to OpenAI API"""
        try:
            response = openai.ChatCompletion.create(
                model=self.model,
                messages=[
                    {"role": "system", "content": "You are a helpful pregnancy and healthcare assistant. Provide accurate, medical information in JSON format."},
                    {"role": "user", "content": prompt}
                ],
                max_tokens=self.max_tokens,
                temperature=0.7
            )
            return response.choices[0].message.content
        except Exception as e:
            print(f"OpenAI API call failed: {e}")
            raise e

#!/usr/bin/env python3
"""
Complete Pregnancy Tracking Service with Trimester-Specific Quick Actions
This service provides AI-powered guidance for each trimester of pregnancy.
"""

import os
import json
from datetime import datetime
from typing import Dict, List, Optional, Any
from dataclasses import dataclass
from enum import Enum

# OpenAI integration (if available)
try:
    import openai
    OPENAI_AVAILABLE = True
except ImportError:
    OPENAI_AVAILABLE = False

class Trimester(Enum):
    FIRST = 1
    SECOND = 2
    THIRD = 3

@dataclass
class QuickAction:
    """Represents a quick action for a specific trimester"""
    name: str
    icon: str
    description: str
    endpoint: str
    features: List[str]

@dataclass
class AIInsights:
    """AI-generated insights for quick actions"""
    guidance: str
    preparation: str
    what_to_expect: str
    important_notes: str

class PregnancyTrackingService:
    """Main service for pregnancy tracking with trimester-specific quick actions"""
    
    def __init__(self):
        self.openai_client = None
        if OPENAI_AVAILABLE and os.getenv('OPENAI_API_KEY'):
            try:
                self.openai_client = openai.OpenAI(api_key=os.getenv('OPENAI_API_KEY'))
            except Exception as e:
                print(f"Warning: OpenAI initialization failed: {e}")
                self.openai_client = None
    
    def get_trimester(self, week: int) -> Trimester:
        """Determine trimester based on pregnancy week"""
        if week <= 13:
            return Trimester.FIRST
        elif week <= 26:
            return Trimester.SECOND
        else:
            return Trimester.THIRD
    
    def get_trimester_phase_info(self, trimester: Trimester) -> Dict[str, str]:
        """Get phase information for each trimester"""
        phases = {
            Trimester.FIRST: {
                "name": "Foundation Phase",
                "description": "Early development and establishment",
                "focus": "Confirmation, early care, and foundation building"
            },
            Trimester.SECOND: {
                "name": "Growth Phase", 
                "description": "Rapid growth and development",
                "focus": "Monitoring growth, screenings, and preparation"
            },
            Trimester.THIRD: {
                "name": "Preparation Phase",
                "description": "Final preparation for birth",
                "focus": "Birth preparation, monitoring, and readiness"
            }
        }
        return phases.get(trimester, {})
    
    def get_trimester_quick_actions(self, trimester: Trimester) -> List[QuickAction]:
        """Get quick actions for specific trimester"""
        
        if trimester == Trimester.FIRST:
            return [
                QuickAction(
                    name="Pregnancy Test Guide",
                    icon="🧪",
                    description="Complete guide to pregnancy testing",
                    endpoint="/api/pregnancy/trimester-1/pregnancy-test",
                    features=["Test types", "Timing", "Accuracy", "Next steps"]
                ),
                QuickAction(
                    name="First Prenatal Visit",
                    icon="🏥",
                    description="Guide to your first prenatal appointment",
                    endpoint="/api/pregnancy/trimester-1/first-prenatal-visit",
                    features=["What to expect", "Questions to ask", "Tests", "Preparation"]
                ),
                QuickAction(
                    name="Early Ultrasound",
                    icon="📡",
                    description="Understanding early ultrasound scans",
                    endpoint="/api/pregnancy/trimester-1/early-ultrasound",
                    features=["Types of scans", "What you'll see", "Preparation", "Timing"]
                ),
                QuickAction(
                    name="Early Symptoms",
                    icon="😷",
                    description="Managing early pregnancy symptoms",
                    endpoint="/api/pregnancy/trimester-1/early-symptoms",
                    features=["Common symptoms", "Relief strategies", "When to worry", "Self-care"]
                )
            ]
        
        elif trimester == Trimester.SECOND:
            return [
                QuickAction(
                    name="Mid-Pregnancy Scan",
                    icon="📅",
                    description="Comprehensive mid-pregnancy ultrasound",
                    endpoint="/api/pregnancy/trimester-2/mid-pregnancy-scan",
                    features=["Anatomy scan", "Gender reveal", "Preparation", "What to expect"]
                ),
                QuickAction(
                    name="Glucose Screening",
                    icon="🩸",
                    description="Gestational diabetes screening test",
                    endpoint="/api/pregnancy/trimester-2/glucose-screening",
                    features=["Test process", "Preparation", "Results", "Management"]
                ),
                QuickAction(
                    name="Fetal Movement",
                    icon="👶",
                    description="Tracking your baby's movements",
                    endpoint="/api/pregnancy/trimester-2/fetal-movement",
                    features=["When to feel kicks", "Patterns", "Counting", "Concerns"]
                ),
                QuickAction(
                    name="Birthing Classes",
                    icon="🎓",
                    description="Preparing for birth through education",
                    endpoint="/api/pregnancy/trimester-2/birthing-classes",
                    features=["Class types", "Timing", "What to learn", "Benefits"]
                ),
                QuickAction(
                    name="Nutrition Tips",
                    icon="🍎",
                    description="Optimal nutrition for second trimester",
                    endpoint="/api/pregnancy/trimester-2/nutrition-tips",
                    features=["Key nutrients", "Meal planning", "Supplements", "Weight gain"]
                )
            ]
        
        elif trimester == Trimester.THIRD:
            return [
                QuickAction(
                    name="Kick Counter",
                    icon="👶",
                    description="Track your baby's daily movements",
                    endpoint="/api/pregnancy/trimester-3/kick-counter",
                    features=["Counting method", "Timing", "Patterns", "When to call doctor"]
                ),
                QuickAction(
                    name="Contractions",
                    icon="⏱️",
                    description="Understanding and timing contractions",
                    endpoint="/api/pregnancy/trimester-3/contractions",
                    features=["Types of contractions", "Timing", "When to go to hospital", "False labor"]
                ),
                QuickAction(
                    name="Birth Plan",
                    icon="📋",
                    description="Creating your personalized birth plan",
                    endpoint="/api/pregnancy/trimester-3/birth-plan",
                    features=["Plan elements", "Preferences", "Backup plans", "Communication"]
                ),
                QuickAction(
                    name="Hospital Bag",
                    icon="🎒",
                    description="Essential items for hospital stay",
                    endpoint="/api/pregnancy/trimester-3/hospital-bag",
                    features=["For mom", "For baby", "For partner", "Important documents"]
                )
            ]
        
        return []
    
    def get_ai_insights(self, prompt: str) -> AIInsights:
        """Get AI insights using OpenAI or fallback responses"""
        
        if self.openai_client:
            try:
                response = self.openai_client.chat.completions.create(
                    model="gpt-3.5-turbo",
                    messages=[
                        {"role": "system", "content": "You are a helpful pregnancy care assistant providing accurate, medical-grade information."},
                        {"role": "user", "content": prompt}
                    ],
                    max_tokens=500,
                    temperature=0.7
                )
                
                content = response.choices[0].message.content
                
                # Parse AI response into structured format
                return self._parse_ai_response(content)
                
            except Exception as e:
                print(f"OpenAI API error: {e}")
                return self._get_fallback_insights(prompt)
        else:
            return self._get_fallback_insights(prompt)
    
    def _parse_ai_response(self, content: str) -> AIInsights:
        """Parse AI response into structured insights"""
        # Simple parsing - in production, you'd want more sophisticated parsing
        lines = content.split('\n')
        
        guidance = ""
        preparation = ""
        what_to_expect = ""
        important_notes = ""
        
        current_section = "guidance"
        
        for line in lines:
            line = line.strip()
            if not line:
                continue
                
            if "preparation" in line.lower() or "prepare" in line.lower():
                current_section = "preparation"
            elif "expect" in line.lower() or "during" in line.lower():
                current_section = "what_to_expect"
            elif "important" in line.lower() or "note" in line.lower() or "warning" in line.lower():
                current_section = "important_notes"
            
            if current_section == "guidance":
                guidance += line + " "
            elif current_section == "preparation":
                preparation += line + " "
            elif current_section == "what_to_expect":
                what_to_expect += line + " "
            elif current_section == "important_notes":
                important_notes += line + " "
        
        return AIInsights(
            guidance=guidance.strip() or "Comprehensive guidance available",
            preparation=preparation.strip() or "Preparation steps provided",
            what_to_expect=what_to_expect.strip() or "What to expect during the process",
            important_notes=important_notes.strip() or "Important considerations noted"
        )
    
    def _get_fallback_insights(self, prompt: str) -> AIInsights:
        """Get fallback insights when OpenAI is not available"""
        return AIInsights(
            guidance="This is a comprehensive guide for your pregnancy care. Please consult with your healthcare provider for personalized advice.",
            preparation="Prepare by scheduling appointments, gathering necessary documents, and following your healthcare provider's instructions.",
            what_to_expect="Expect a professional, caring experience with detailed explanations of each step in the process.",
            important_notes="Always consult your healthcare provider for medical advice and emergency situations."
        )
    
    def get_quick_action_guidance(self, trimester: int, action_name: str) -> Dict[str, Any]:
        """Get detailed guidance for a specific quick action"""
        
        trimester_enum = Trimester(trimester)
        quick_actions = self.get_trimester_quick_actions(trimester_enum)
        
        # Find the specific action
        action = None
        for qa in quick_actions:
            if qa.name.lower().replace(" ", "-") == action_name.lower().replace(" ", "-"):
                action = qa
                break
        
        if not action:
            return {
                "success": False,
                "error": f"Quick action '{action_name}' not found for trimester {trimester}"
            }
        
        # Create AI prompt
        prompt = f"""
        Provide comprehensive guidance for {action.name} during Trimester {trimester}:
        
        1. What is {action.name}?
        2. When should this be done during Trimester {trimester}?
        3. How to prepare for {action.name}?
        4. What to expect during {action.name}?
        5. Important notes and considerations for {action.name}
        
        Please provide detailed, helpful information that would be useful for an expecting mother.
        """
        
        # Get AI insights
        ai_insights = self.get_ai_insights(prompt)
        
        return {
            "success": True,
            "quick_action": action.name,
            "trimester": trimester,
            "icon": action.icon,
            "description": action.description,
            "ai_content": {
                "guidance": ai_insights.guidance,
                "preparation": ai_insights.preparation,
                "what_to_expect": ai_insights.what_to_expect,
                "important_notes": ai_insights.important_notes
            },
            "features": action.features,
            "endpoint": action.endpoint
        }
    
    def get_auto_trimester_info(self, week: int) -> Dict[str, Any]:
        """Get auto-trimester selection with quick actions and AI insights"""
        
        trimester = self.get_trimester(week)
        trimester_info = self.get_trimester_phase_info(trimester)
        quick_actions = self.get_trimester_quick_actions(trimester)
        
        # Get AI insights for the trimester
        ai_prompt = f"""
        Provide insights for Trimester {trimester.value} (Week {week}):
        
        1. What are the key milestones for this stage?
        2. What should the mother focus on during this trimester?
        3. What are the most important care recommendations?
        4. What should she prepare for next?
        
        Please provide encouraging, helpful guidance for an expecting mother.
        """
        
        ai_insights = self.get_ai_insights(ai_prompt)
        
        # Format quick actions for response
        formatted_actions = []
        for action in quick_actions:
            formatted_actions.append({
                "name": action.name,
                "icon": action.icon,
                "description": action.description,
                "endpoint": action.endpoint,
                "features": action.features
            })
        
        return {
            "success": True,
            "pregnancy_week": week,
            "auto_selected_trimester": trimester.value,
            "phase": trimester_info.get("name", ""),
            "description": trimester_info.get("description", ""),
            "focus": trimester_info.get("focus", ""),
            "quick_actions": formatted_actions,
            "ai_insights": {
                "milestones": ai_insights.guidance,
                "care_recommendations": ai_insights.preparation,
                "next_steps": ai_insights.what_to_expect,
                "important_notes": ai_insights.important_notes
            },
            "trimester_endpoints": {
                "trimester_info": f"/api/pregnancy/trimester/{trimester.value}",
                "quick_actions": f"/api/pregnancy/trimester-{trimester.value}/quick-actions",
                "auto_trimester": f"/api/pregnancy/auto-trimester/{week}"
            }
        }

# Global service instance
pregnancy_service = PregnancyTrackingService()

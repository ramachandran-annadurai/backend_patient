from pregnancy_models import PregnancyWeek, KeyDevelopment, BabySize
from typing import Dict
import json
import os

class PregnancyDataService:
    def __init__(self):
        self.pregnancy_data = self._initialize_data()
    
    def _initialize_data(self) -> Dict[int, PregnancyWeek]:
        """Initialize pregnancy week data with key developments"""
        data = {}
        
        # Week 1-4 (Trimester 1)
        data[1] = PregnancyWeek(
            week=1,
            trimester=1,
            days_remaining=280,
            baby_size=BabySize(size="Poppy seed", weight="0.1g", length="0.1cm"),
            key_developments=[
                KeyDevelopment(
                    title="Fertilization",
                    description="The egg is fertilized by sperm, beginning the journey of pregnancy.",
                    icon="🌱",
                    category="conception"
                ),
                KeyDevelopment(
                    title="Cell Division Begins",
                    description="The fertilized egg starts dividing rapidly into multiple cells.",
                    icon="🔬",
                    category="development"
                )
            ],
            symptoms=["Implantation bleeding", "Mild cramping", "Fatigue"],
            tips=["Start taking prenatal vitamins", "Avoid alcohol and smoking", "Maintain healthy diet"]
        )
        
        data[2] = PregnancyWeek(
            week=2,
            trimester=1,
            days_remaining=273,
            baby_size=BabySize(size="Poppy seed", weight="0.1g", length="0.1cm"),
            key_developments=[
                KeyDevelopment(
                    title="Implantation",
                    description="The fertilized egg implants into the uterine wall.",
                    icon="🏠",
                    category="implantation"
                ),
                KeyDevelopment(
                    title="Hormone Production",
                    description="The body starts producing hCG hormone to support pregnancy.",
                    icon="🧬",
                    category="hormonal"
                )
            ],
            symptoms=["Implantation bleeding", "Mild cramping", "Fatigue"],
            tips=["Start taking prenatal vitamins", "Avoid alcohol and smoking", "Maintain healthy diet"]
        )
        
        # Continue with more weeks... (abbreviated for brevity)
        # In a real implementation, you'd have all 40 weeks
        
        # Week 5-8 (Trimester 1)
        data[5] = PregnancyWeek(
            week=5,
            trimester=1,
            days_remaining=245,
            baby_size=BabySize(size="Sesame seed", weight="0.5g", length="0.3cm"),
            key_developments=[
                KeyDevelopment(
                    title="Heart Formation",
                    description="The baby's heart begins to form and may start beating.",
                    icon="❤️",
                    category="cardiovascular"
                ),
                KeyDevelopment(
                    title="Neural Tube Development",
                    description="The neural tube, which becomes the brain and spinal cord, starts forming.",
                    icon="🧠",
                    category="neurological"
                )
            ],
            symptoms=["Morning sickness", "Breast tenderness", "Fatigue", "Frequent urination"],
            tips=["Eat small, frequent meals", "Stay hydrated", "Get plenty of rest", "Take folic acid"]
        )
        
        data[8] = PregnancyWeek(
            week=8,
            trimester=1,
            days_remaining=224,
            baby_size=BabySize(size="Raspberry", weight="1g", length="1.6cm"),
            key_developments=[
                KeyDevelopment(
                    title="Limb Buds Appear",
                    description="Small limb buds begin to form, which will become arms and legs.",
                    icon="👶",
                    category="physical"
                ),
                KeyDevelopment(
                    title="Facial Features",
                    description="Basic facial features start to develop.",
                    icon="😊",
                    category="facial"
                )
            ],
            symptoms=["Morning sickness", "Breast tenderness", "Fatigue", "Frequent urination"],
            tips=["Eat small, frequent meals", "Stay hydrated", "Get plenty of rest", "Take folic acid"]
        )
        
        # Week 12 (End of Trimester 1)
        data[12] = PregnancyWeek(
            week=12,
            trimester=1,
            days_remaining=196,
            baby_size=BabySize(size="Lime", weight="14g", length="5.4cm"),
            key_developments=[
                KeyDevelopment(
                    title="First Trimester Complete",
                    description="The first trimester is complete! Risk of miscarriage significantly decreases.",
                    icon="🎉",
                    category="milestone"
                ),
                KeyDevelopment(
                    title="Reflexes Develop",
                    description="The baby starts developing reflexes and can make small movements.",
                    icon="🤸",
                    category="motor"
                )
            ],
            symptoms=["Morning sickness may decrease", "Breast tenderness", "Fatigue", "Frequent urination"],
            tips=["Schedule your first prenatal appointment", "Consider announcing your pregnancy", "Continue taking prenatal vitamins"]
        )
        
        # Week 20 (Mid-pregnancy)
        data[20] = PregnancyWeek(
            week=20,
            trimester=2,
            days_remaining=140,
            baby_size=BabySize(size="Banana", weight="300g", length="16.4cm"),
            key_developments=[
                KeyDevelopment(
                    title="Halfway Point",
                    description="You're halfway through your pregnancy! The baby is growing rapidly.",
                    icon="🎯",
                    category="milestone"
                ),
                KeyDevelopment(
                    title="Hair and Nails",
                    description="The baby's hair and nails start to grow.",
                    icon="💅",
                    category="physical"
                )
            ],
            symptoms=["Fetal movements", "Back pain", "Leg cramps", "Heartburn"],
            tips=["Start feeling baby movements", "Consider maternity clothes", "Stay active with safe exercises"]
        )
        
        # Week 28 (Third Trimester)
        data[28] = PregnancyWeek(
            week=28,
            trimester=3,
            days_remaining=84,
            baby_size=BabySize(size="Large eggplant", weight="1kg", length="25.6cm"),
            key_developments=[
                KeyDevelopment(
                    title="Third Trimester Begins",
                    description="Welcome to the third trimester! The baby is preparing for birth.",
                    icon="🚀",
                    category="milestone"
                ),
                KeyDevelopment(
                    title="Eyes Open",
                    description="The baby's eyes can now open and close.",
                    icon="👀",
                    category="sensory"
                )
            ],
            symptoms=["Increased fetal movements", "Shortness of breath", "Swelling", "Braxton Hicks contractions"],
            tips=["Start preparing for birth", "Consider childbirth classes", "Monitor baby movements daily"]
        )
        
        # Week 40 (Full Term)
        data[40] = PregnancyWeek(
            week=40,
            trimester=3,
            days_remaining=0,
            baby_size=BabySize(size="Small pumpkin", weight="3.4kg", length="51cm"),
            key_developments=[
                KeyDevelopment(
                    title="Full Term",
                    description="Your baby is considered full term and ready for birth!",
                    icon="🎊",
                    category="milestone"
                ),
                KeyDevelopment(
                    title="Ready for Birth",
                    description="All organs are fully developed and ready for life outside the womb.",
                    icon="🌟",
                    category="completion"
                )
            ],
            symptoms=["Strong contractions", "Water breaking", "Back pain", "Nesting instinct"],
            tips=["Pack your hospital bag", "Know the signs of labor", "Stay calm and ready"]
        )
        
        return data
    
    def get_week_data(self, week: int) -> PregnancyWeek:
        """Get pregnancy data for a specific week"""
        if week not in self.pregnancy_data:
            # Generate data for missing weeks
            return self._generate_week_data(week)
        return self.pregnancy_data[week]
    
    def get_all_weeks(self) -> Dict[int, PregnancyWeek]:
        """Get all pregnancy week data"""
        # Ensure we have data for all 40 weeks
        for week in range(1, 41):
            if week not in self.pregnancy_data:
                self.pregnancy_data[week] = self._generate_week_data(week)
        return self.pregnancy_data
    
    def get_trimester_weeks(self, trimester: int) -> Dict[int, PregnancyWeek]:
        """Get all weeks for a specific trimester"""
        all_weeks = self.get_all_weeks()
        return {
            week: data for week, data in all_weeks.items() 
            if data.trimester == trimester
        }
    
    def _generate_week_data(self, week: int) -> PregnancyWeek:
        """Generate basic data for missing weeks"""
        if week <= 12:
            trimester = 1
        elif week <= 28:
            trimester = 2
        else:
            trimester = 3
        
        days_remaining = 280 - (week - 1) * 7
        
        # Basic size progression
        if week <= 4:
            size = "Poppy seed"
            weight = "0.1g"
            length = "0.1cm"
        elif week <= 8:
            size = "Sesame seed"
            weight = "0.5g"
            length = "0.3cm"
        elif week <= 12:
            size = "Lime"
            weight = "14g"
            length = "5.4cm"
        elif week <= 20:
            size = "Banana"
            weight = "300g"
            length = "16.4cm"
        elif week <= 28:
            size = "Large eggplant"
            weight = "1kg"
            length = "25.6cm"
        else:
            size = "Small pumpkin"
            weight = "3.4kg"
            length = "51cm"
        
        return PregnancyWeek(
            week=week,
            trimester=trimester,
            days_remaining=days_remaining,
            baby_size=BabySize(size=size, weight=weight, length=length),
            key_developments=[
                KeyDevelopment(
                    title=f"Week {week} Development",
                    description=f"Your baby continues to grow and develop in week {week}.",
                    icon="👶",
                    category="general"
                )
            ],
            symptoms=["Continue monitoring your symptoms", "Stay in touch with your healthcare provider"],
            tips=["Maintain healthy lifestyle", "Attend regular checkups", "Stay hydrated"]
        )

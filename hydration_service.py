import os
from datetime import datetime, date, timedelta
from typing import List, Dict, Optional, Any
from hydration_models import *
import json
import asyncio
from openai import OpenAI
from pymongo import MongoClient

class HydrationService:
    def __init__(self):
        self.openai_client = None
        # Use the same MongoDB URI as the main backend
        self.mongo_uri = os.getenv('MONGO_URI', 'mongodb+srv://ramya:XxFn6n0NXx0wBplV@cluster0.c1g1bm5.mongodb.net')
        self.db_name = os.getenv('DB_NAME', 'patients_db')
        
        # Initialize MongoDB connection
        try:
            self.mongo_client = MongoClient(self.mongo_uri)
            self.db = self.mongo_client[self.db_name]
            self.hydration_collection = self.db.hydration_logs
            self.goals_collection = self.db.hydration_goals
            self.reminders_collection = self.db.hydration_reminders
            print("✅ Hydration MongoDB service initialized")
        except Exception as e:
            print(f"⚠️ Hydration MongoDB service not available: {e}")
            self.mongo_client = None
        
        # Initialize OpenAI if available
        try:
            api_key = os.getenv('OPENAI_API_KEY')
            if api_key:
                self.openai_client = OpenAI(api_key=api_key)
                print("✅ Hydration OpenAI service initialized")
        except Exception as e:
            print(f"⚠️ Hydration OpenAI service not available: {e}")
    
    def save_hydration_intake(self, patient_id: str, intake_data: HydrationIntakeRequest) -> HydrationResponse:
        """Save hydration intake record"""
        try:
            # Convert to ml if needed
            amount_ml = intake_data.amount_ml
            
            # Create intake record
            intake_record = HydrationIntake(
                patient_id=patient_id,
                hydration_type=intake_data.hydration_type,
                amount_ml=amount_ml,
                amount_oz=amount_ml * 0.033814,  # Convert ml to oz
                timestamp=datetime.now(),
                notes=intake_data.notes,
                temperature=intake_data.temperature,
                additives=intake_data.additives
            )
            
            # Save to MongoDB
            if self.mongo_client:
                intake_doc = intake_record.dict()
                intake_doc["created_at"] = datetime.now()
                result = self.hydration_collection.insert_one(intake_doc)
                intake_doc["_id"] = str(result.inserted_id)
                print(f"✅ Hydration intake saved to MongoDB: {result.inserted_id}")
                
                return HydrationResponse(
                    success=True,
                    data=intake_doc,
                    message="Hydration intake saved successfully to database"
                )
            else:
                # Fallback if MongoDB not available
                return HydrationResponse(
                    success=False,
                    message="Database connection not available"
                )
        except Exception as e:
            print(f"❌ Error saving hydration intake: {str(e)}")
            return HydrationResponse(
                success=False,
                message=f"Error saving hydration intake: {str(e)}"
            )
    
    def get_hydration_history(self, patient_id: str, days: int = 7) -> HydrationResponse:
        """Get hydration intake history from MongoDB"""
        try:
            if self.mongo_client:
                # Calculate date range
                end_date = datetime.now()
                start_date = end_date - timedelta(days=days)
                
                # Query MongoDB
                query = {
                    "patient_id": patient_id,
                    "timestamp": {
                        "$gte": start_date,
                        "$lte": end_date
                    }
                }
                
                # Sort by timestamp descending (newest first)
                history_docs = list(self.hydration_collection.find(query).sort("timestamp", -1))
                
                # Convert ObjectId to string for JSON serialization
                for doc in history_docs:
                    doc["_id"] = str(doc["_id"])
                    if isinstance(doc.get("timestamp"), datetime):
                        doc["timestamp"] = doc["timestamp"].isoformat()
                
                print(f"✅ Retrieved {len(history_docs)} hydration records from MongoDB")
                
                return HydrationResponse(
                    success=True,
                    data={"history": history_docs, "days": days},
                    message=f"Retrieved {len(history_docs)} hydration records from database"
                )
            else:
                # Fallback to mock data if MongoDB not available
                mock_history = [
                    {
                        "id": "1",
                        "patient_id": patient_id,
                        "hydration_type": "water",
                        "amount_ml": 250,
                        "amount_oz": 8.45,
                        "timestamp": datetime.now().isoformat(),
                        "notes": "Morning water"
                    }
                ]
                
                return HydrationResponse(
                    success=True,
                    data={"history": mock_history, "days": days},
                    message=f"Retrieved {len(mock_history)} hydration records (mock data)"
                )
        except Exception as e:
            print(f"❌ Error retrieving hydration history: {str(e)}")
            return HydrationResponse(
                success=False,
                message=f"Error retrieving hydration history: {str(e)}"
            )
    
    def get_daily_hydration_stats(self, patient_id: str, target_date: Optional[date] = None) -> HydrationStats:
        """Get daily hydration statistics"""
        try:
            if target_date is None:
                target_date = date.today()
            
            # Mock data - in real implementation, calculate from database
            total_intake_ml = 1500.0
            goal_ml = 2000.0
            
            return HydrationStats(
                patient_id=patient_id,
                date=target_date,
                total_intake_ml=total_intake_ml,
                total_intake_oz=total_intake_ml * 0.033814,
                goal_ml=goal_ml,
                goal_oz=goal_ml * 0.033814,
                goal_percentage=(total_intake_ml / goal_ml) * 100,
                intake_by_type={
                    "water": 1000.0,
                    "coffee": 300.0,
                    "tea": 200.0
                },
                average_intake_per_hour=total_intake_ml / 16,  # Assuming 16 waking hours
                peak_hour="14:00",
                last_intake_time=datetime.now() - timedelta(minutes=30),
                hours_since_last_intake=0.5,
                is_goal_met=total_intake_ml >= goal_ml,
                hydration_score=7
            )
        except Exception as e:
            return HydrationStats(
                patient_id=patient_id,
                date=target_date or date.today(),
                total_intake_ml=0,
                total_intake_oz=0,
                goal_ml=2000,
                goal_oz=67.6,
                goal_percentage=0,
                intake_by_type={},
                average_intake_per_hour=0,
                is_goal_met=False,
                hydration_score=1
            )
    
    def set_hydration_goal(self, patient_id: str, goal_data: HydrationGoalRequest) -> HydrationResponse:
        """Set or update hydration goal"""
        try:
            goal = HydrationGoal(
                patient_id=patient_id,
                daily_goal_ml=goal_data.daily_goal_ml,
                daily_goal_oz=goal_data.daily_goal_ml * 0.033814,
                start_date=date.today(),
                reminder_enabled=goal_data.reminder_enabled,
                reminder_times=goal_data.reminder_times or ["08:00", "12:00", "16:00", "20:00"]
            )
            
            return HydrationResponse(
                success=True,
                data=goal.dict(),
                message="Hydration goal set successfully"
            )
        except Exception as e:
            return HydrationResponse(
                success=False,
                error=f"Error setting hydration goal: {str(e)}"
            )
    
    def get_hydration_goal(self, patient_id: str) -> HydrationResponse:
        """Get current hydration goal"""
        try:
            # Mock data - in real implementation, query from database
            goal = {
                "patient_id": patient_id,
                "daily_goal_ml": 2000,
                "daily_goal_oz": 67.6,
                "start_date": date.today().isoformat(),
                "is_active": True,
                "reminder_enabled": True,
                "reminder_times": ["08:00", "12:00", "16:00", "20:00"]
            }
            
            return HydrationResponse(
                success=True,
                data=goal,
                message="Hydration goal retrieved successfully"
            )
        except Exception as e:
            return HydrationResponse(
                success=False,
                error=f"Error retrieving hydration goal: {str(e)}"
            )
    
    def create_hydration_reminder(self, patient_id: str, reminder_data: HydrationReminderRequest) -> HydrationResponse:
        """Create hydration reminder"""
        try:
            reminder = HydrationReminder(
                patient_id=patient_id,
                reminder_time=reminder_data.reminder_time,
                message=reminder_data.message,
                days_of_week=reminder_data.days_of_week
            )
            
            return HydrationResponse(
                success=True,
                data=reminder.dict(),
                message="Hydration reminder created successfully"
            )
        except Exception as e:
            return HydrationResponse(
                success=False,
                error=f"Error creating hydration reminder: {str(e)}"
            )
    
    def get_hydration_reminders(self, patient_id: str) -> HydrationResponse:
        """Get all hydration reminders for patient"""
        try:
            # Mock data
            reminders = [
                {
                    "id": "1",
                    "patient_id": patient_id,
                    "reminder_time": "08:00",
                    "message": "Time for your morning water!",
                    "is_enabled": True,
                    "days_of_week": [0, 1, 2, 3, 4, 5, 6]
                },
                {
                    "id": "2",
                    "patient_id": patient_id,
                    "reminder_time": "14:00",
                    "message": "Stay hydrated! Have some water.",
                    "is_enabled": True,
                    "days_of_week": [0, 1, 2, 3, 4, 5, 6]
                }
            ]
            
            return HydrationResponse(
                success=True,
                data={"reminders": reminders},
                message=f"Retrieved {len(reminders)} hydration reminders"
            )
        except Exception as e:
            return HydrationResponse(
                success=False,
                error=f"Error retrieving hydration reminders: {str(e)}"
            )
    
    async def analyze_hydration_patterns(self, patient_id: str, days: int = 7) -> HydrationAnalysis:
        """Analyze hydration patterns using AI"""
        try:
            if not self.openai_client:
                # Fallback analysis without AI
                return HydrationAnalysis(
                    patient_id=patient_id,
                    analysis_date=date.today(),
                    current_hydration_level="good",
                    recommendations=[
                        "Drink water consistently throughout the day",
                        "Aim for 8 glasses of water daily",
                        "Monitor urine color for hydration status"
                    ],
                    warnings=[],
                    trends={"weekly_average": 1500, "consistency": "moderate"},
                    comparison_to_goal={"achievement_rate": 75},
                    optimal_times=["08:00", "10:00", "14:00", "16:00", "18:00"],
                    dehydration_risk="low"
                )
            
            # AI-powered analysis
            prompt = f"""
            Analyze hydration patterns for patient {patient_id} over the last {days} days.
            Provide insights on:
            1. Current hydration level (excellent, good, fair, poor, critical)
            2. Specific recommendations for improvement
            3. Any warnings about dehydration risk
            4. Optimal times for drinking water
            5. Trends and patterns observed
            
            Format as JSON with the following structure:
            {{
                "current_hydration_level": "string",
                "recommendations": ["string1", "string2"],
                "warnings": ["string1", "string2"],
                "trends": {{"key": "value"}},
                "comparison_to_goal": {{"key": "value"}},
                "optimal_times": ["time1", "time2"],
                "dehydration_risk": "low/medium/high"
            }}
            """
            
            response = self.openai_client.chat.completions.create(
                model="gpt-3.5-turbo",
                messages=[{"role": "user", "content": prompt}],
                max_tokens=500
            )
            
            analysis_data = json.loads(response.choices[0].message.content)
            
            return HydrationAnalysis(
                patient_id=patient_id,
                analysis_date=date.today(),
                current_hydration_level=analysis_data.get("current_hydration_level", "good"),
                recommendations=analysis_data.get("recommendations", []),
                warnings=analysis_data.get("warnings", []),
                trends=analysis_data.get("trends", {}),
                comparison_to_goal=analysis_data.get("comparison_to_goal", {}),
                optimal_times=analysis_data.get("optimal_times", []),
                dehydration_risk=analysis_data.get("dehydration_risk", "low")
            )
        except Exception as e:
            return HydrationAnalysis(
                patient_id=patient_id,
                analysis_date=date.today(),
                current_hydration_level="fair",
                recommendations=["Monitor your water intake more closely"],
                warnings=["Unable to analyze patterns due to service error"],
                trends={},
                comparison_to_goal={},
                optimal_times=[],
                dehydration_risk="medium"
            )
    
    def get_weekly_hydration_report(self, patient_id: str, week_start: Optional[date] = None) -> HydrationWeeklyReport:
        """Generate weekly hydration report"""
        try:
            if week_start is None:
                week_start = date.today() - timedelta(days=date.today().weekday())
            
            week_end = week_start + timedelta(days=6)
            
            # Mock data - in real implementation, calculate from database
            return HydrationWeeklyReport(
                patient_id=patient_id,
                week_start=week_start,
                week_end=week_end,
                total_intake_ml=10500.0,
                average_daily_intake_ml=1500.0,
                goal_achievement_rate=75.0,
                most_consumed_type="water",
                best_day=week_start + timedelta(days=2),
                worst_day=week_start + timedelta(days=5),
                improvement_suggestions=[
                    "Set more frequent reminders",
                    "Keep a water bottle nearby",
                    "Track intake more consistently"
                ],
                weekly_trend="stable"
            )
        except Exception as e:
            return HydrationWeeklyReport(
                patient_id=patient_id,
                week_start=week_start or date.today(),
                week_end=(week_start or date.today()) + timedelta(days=6),
                total_intake_ml=0,
                average_daily_intake_ml=0,
                goal_achievement_rate=0,
                most_consumed_type="water",
                best_day=week_start or date.today(),
                worst_day=week_start or date.today(),
                improvement_suggestions=["Start tracking your hydration"],
                weekly_trend="unknown"
            )
    
    def get_hydration_tips(self, patient_id: str, current_week: Optional[int] = None) -> HydrationResponse:
        """Get personalized hydration tips"""
        try:
            tips = [
                "Start your day with a glass of water",
                "Keep a water bottle with you at all times",
                "Set hourly reminders to drink water",
                "Eat water-rich foods like fruits and vegetables",
                "Monitor your urine color - it should be light yellow",
                "Drink water before, during, and after exercise",
                "Limit caffeine and alcohol as they can dehydrate",
                "Listen to your body's thirst signals"
            ]
            
            if current_week and 1 <= current_week <= 40:
                # Pregnancy-specific tips
                pregnancy_tips = [
                    "Pregnant women need extra hydration - aim for 10-12 glasses daily",
                    "Drink water to help with morning sickness",
                    "Stay hydrated to prevent constipation during pregnancy",
                    "Water helps with amniotic fluid production",
                    "Avoid dehydration to prevent preterm labor"
                ]
                tips.extend(pregnancy_tips)
            
            return HydrationResponse(
                success=True,
                data={"tips": tips, "personalized": True},
                message="Hydration tips retrieved successfully"
            )
        except Exception as e:
            return HydrationResponse(
                success=False,
                error=f"Error retrieving hydration tips: {str(e)}"
            )
    
    def get_hydration_status(self, patient_id: str) -> HydrationResponse:
        """Get current hydration status and recommendations"""
        try:
            stats = self.get_daily_hydration_stats(patient_id)
            
            status = {
                "current_intake_ml": stats.total_intake_ml,
                "goal_ml": stats.goal_ml,
                "progress_percentage": stats.goal_percentage,
                "is_goal_met": stats.is_goal_met,
                "hydration_score": stats.hydration_score,
                "hours_since_last_intake": stats.hours_since_last_intake,
                "recommendation": self._get_hydration_recommendation(stats)
            }
            
            return HydrationResponse(
                success=True,
                data=status,
                message="Hydration status retrieved successfully"
            )
        except Exception as e:
            return HydrationResponse(
                success=False,
                error=f"Error retrieving hydration status: {str(e)}"
            )
    
    def _get_hydration_recommendation(self, stats: HydrationStats) -> str:
        """Get personalized hydration recommendation based on stats"""
        if stats.hours_since_last_intake and stats.hours_since_last_intake > 3:
            return "You haven't had water in a while. Time to hydrate!"
        elif stats.goal_percentage < 50:
            return "You're behind on your hydration goal. Try to catch up!"
        elif stats.goal_percentage < 75:
            return "Good progress! Keep drinking water throughout the day."
        elif stats.goal_percentage < 100:
            return "Almost at your goal! Just a bit more to go."
        else:
            return "Excellent! You've met your hydration goal for today."

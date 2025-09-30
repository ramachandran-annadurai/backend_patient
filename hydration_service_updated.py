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
            self.hydration_collection = self.db.Patient_test
            self.goals_collection = self.db.Patient_test
            self.reminders_collection = self.db.Patient_test
            self.patient_test_collection = self.db.Patient_test
            print("✅ Hydration MongoDB service initialized with Patient_test collection")
        except Exception as e:
            print(f"⚠️ Hydration MongoDB service not available: {e}")
            self.mongo_client = None    
            
    def save_hydration_intake(self, patient_id: str, intake_data: HydrationIntakeRequest) -> HydrationResponse:
        """Save hydration intake record in Patient_test collection"""
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
            
            # Save to Patient_test collection
            if self.mongo_client:
                # Check if patient exists in Patient_test collection
                patient = self.patient_test_collection.find_one({"patient_id": patient_id})
                if not patient:
                    return HydrationResponse(
                        success=False,
                        message=f"Patient with ID {patient_id} not found in Patient_test collection"
                    )
                
                # Add hydration record to patient's hydration_records array
                result = self.patient_test_collection.update_one(
                    {"patient_id": patient_id},
                    {"$push": {"hydration_records": intake_record.dict()}}
                )
                
                if result.modified_count > 0:
                    print(f"✅ Hydration intake saved to Patient_test collection for patient {patient_id}")
                    
                    return HydrationResponse(
                        success=True,
                        data=intake_record.dict(),
                        message="Hydration intake saved successfully to Patient_test collection"
                    )
                else:
                    return HydrationResponse(
                        success=False,
                        message="Failed to update patient record in Patient_test collection"
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
        """Get hydration intake history from Patient_test collection"""
        try:
            if self.mongo_client:
                # Find patient and get their hydration records
                patient = self.patient_test_collection.find_one({"patient_id": patient_id})
                if not patient:
                    return HydrationResponse(
                        success=False,
                        message=f"Patient with ID {patient_id} not found in Patient_test collection"
                    )
                
                # Get hydration records from patient document
                hydration_records = patient.get("hydration_records", [])
                
                # Filter by date range
                cutoff_date = datetime.now() - timedelta(days=days)
                filtered_records = [
                    record for record in hydration_records
                    if record.get("timestamp", datetime.min) >= cutoff_date
                ]
                
                # Sort by timestamp (newest first)
                filtered_records.sort(key=lambda x: x.get("timestamp", datetime.min), reverse=True)
                
                return HydrationResponse(
                    success=True,
                    data=filtered_records,
                    message=f"Retrieved {len(filtered_records)} hydration records from Patient_test collection"
                )
            else:
                return HydrationResponse(
                    success=False,
                    message="Database connection not available"
                )
        except Exception as e:
            print(f"❌ Error getting hydration history: {str(e)}")
            return HydrationResponse(
                success=False,
                message=f"Error getting hydration history: {str(e)}"
            )   
            
    def get_daily_hydration_stats(self, patient_id: str, target_date: Optional[date] = None) -> HydrationStats:
        """Get daily hydration statistics from Patient_test collection"""
        try:
            if target_date is None:
                target_date = date.today()
            
            if not self.mongo_client:
                # Fallback stats if no database
                return HydrationStats(
                    patient_id=patient_id,
                    date=target_date,
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
            
            # Find patient and get their hydration records
            patient = self.patient_test_collection.find_one({"patient_id": patient_id})
            if not patient:
                return HydrationStats(
                    patient_id=patient_id,
                    date=target_date,
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
            
            # Get hydration records from patient document
            hydration_records = patient.get("hydration_records", [])
            hydration_goal = patient.get("hydration_goal", {})
            
            # Filter records for target date
            target_date_str = target_date.isoformat()
            daily_records = [
                record for record in hydration_records
                if record.get("timestamp", "").startswith(target_date_str)
            ]
            
            # Calculate total intake
            total_intake_ml = sum(record.get("amount_ml", 0) for record in daily_records)
            total_intake_oz = sum(record.get("amount_oz", 0) for record in daily_records)
            
            # Get goal from patient data
            goal_ml = hydration_goal.get("daily_goal_ml", 2000)
            goal_oz = hydration_goal.get("daily_goal_oz", 67.6)
            
            # Calculate intake by type
            intake_by_type = {}
            for record in daily_records:
                hydration_type = record.get("hydration_type", "water")
                amount = record.get("amount_ml", 0)
                intake_by_type[hydration_type] = intake_by_type.get(hydration_type, 0) + amount
            
            # Calculate other stats
            goal_percentage = (total_intake_ml / goal_ml * 100) if goal_ml > 0 else 0
            is_goal_met = total_intake_ml >= goal_ml
            hydration_score = min(10, int(goal_percentage / 10)) if goal_percentage > 0 else 1
            
            # Calculate average intake per hour (assuming 16 waking hours)
            average_intake_per_hour = total_intake_ml / 16 if total_intake_ml > 0 else 0
            
            # Find peak hour
            hour_intakes = {}
            for record in daily_records:
                timestamp = record.get("timestamp")
                if timestamp:
                    try:
                        dt = datetime.fromisoformat(timestamp.replace('Z', '+00:00'))
                        hour = dt.hour
                        hour_intakes[hour] = hour_intakes.get(hour, 0) + record.get("amount_ml", 0)
                    except:
                        pass
            
            peak_hour = max(hour_intakes.items(), key=lambda x: x[1])[0] if hour_intakes else "14:00"
            peak_hour_str = f"{peak_hour:02d}:00"
            
            # Calculate hours since last intake
            if daily_records:
                last_record = max(daily_records, key=lambda x: x.get("timestamp", ""))
                last_timestamp = last_record.get("timestamp")
                if last_timestamp:
                    try:
                        last_dt = datetime.fromisoformat(last_timestamp.replace('Z', '+00:00'))
                        hours_since = (datetime.now() - last_dt).total_seconds() / 3600
                    except:
                        hours_since = 0
                else:
                    hours_since = 0
            else:
                hours_since = 24  # No intake today
            
            return HydrationStats(
                patient_id=patient_id,
                date=target_date,
                total_intake_ml=total_intake_ml,
                total_intake_oz=total_intake_oz,
                goal_ml=goal_ml,
                goal_oz=goal_oz,
                goal_percentage=goal_percentage,
                intake_by_type=intake_by_type,
                average_intake_per_hour=average_intake_per_hour,
                peak_hour=peak_hour_str,
                last_intake_time=datetime.now() - timedelta(hours=hours_since),
                hours_since_last_intake=hours_since,
                is_goal_met=is_goal_met,
                hydration_score=hydration_score
            )
        except Exception as e:
            print(f"❌ Error getting daily hydration stats: {str(e)}")
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
        """Set or update hydration goal in Patient_test collection"""
        try:
            if not self.mongo_client:
                return HydrationResponse(
                    success=False,
                    message="Database connection not available"
                )
            
            # Check if patient exists
            patient = self.patient_test_collection.find_one({"patient_id": patient_id})
            if not patient:
                return HydrationResponse(
                    success=False,
                    message=f"Patient with ID {patient_id} not found in Patient_test collection"
                )
            
            # Create goal data
            goal_data_dict = {
                "daily_goal_ml": goal_data.daily_goal_ml,
                "daily_goal_oz": goal_data.daily_goal_ml * 0.033814,
                "start_date": date.today().isoformat(),
                "reminder_enabled": goal_data.reminder_enabled,
                "reminder_times": goal_data.reminder_times or ["08:00", "12:00", "16:00", "20:00"],
                "updated_at": datetime.now().isoformat()
            }
            
            # Update patient's hydration goal
            result = self.patient_test_collection.update_one(
                {"patient_id": patient_id},
                {"$set": {"hydration_goal": goal_data_dict}}
            )
            
            if result.modified_count > 0:
                print(f"✅ Hydration goal saved to Patient_test collection for patient {patient_id}")
                return HydrationResponse(
                    success=True,
                    data=goal_data_dict,
                    message="Hydration goal set successfully in Patient_test collection"
                )
            else:
                return HydrationResponse(
                    success=False,
                    message="Failed to update hydration goal in Patient_test collection"
                )
        except Exception as e:
            return HydrationResponse(
                success=False,
                error=f"Error setting hydration goal: {str(e)}"
            )
    
    def get_hydration_goal(self, patient_id: str) -> HydrationResponse:
        """Get current hydration goal from Patient_test collection"""
        try:
            if not self.mongo_client:
                return HydrationResponse(
                    success=False,
                    message="Database connection not available"
                )
            
            # Find patient and get their hydration goal
            patient = self.patient_test_collection.find_one({"patient_id": patient_id})
            if not patient:
                return HydrationResponse(
                    success=False,
                    message=f"Patient with ID {patient_id} not found in Patient_test collection"
                )
            
            # Get hydration goal from patient document
            hydration_goal = patient.get("hydration_goal", {})
            
            if not hydration_goal:
                # Return default goal if none set
                default_goal = {
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
                    data=default_goal,
                    message="No hydration goal set, returning default"
                )
            
            return HydrationResponse(
                success=True,
                data=hydration_goal,
                message="Hydration goal retrieved successfully from Patient_test collection"
            )
        except Exception as e:
            return HydrationResponse(
                success=False,
                error=f"Error retrieving hydration goal: {str(e)}"
            )
    
    def create_hydration_reminder(self, patient_id: str, reminder_data: HydrationReminderRequest) -> HydrationResponse:
        """Create hydration reminder in Patient_test collection"""
        try:
            if not self.mongo_client:
                return HydrationResponse(
                    success=False,
                    message="Database connection not available"
                )
            
            # Check if patient exists
            patient = self.patient_test_collection.find_one({"patient_id": patient_id})
            if not patient:
                return HydrationResponse(
                    success=False,
                    message=f"Patient with ID {patient_id} not found in Patient_test collection"
                )
            
            # Create reminder data
            reminder_data_dict = {
                "reminder_id": str(datetime.now().timestamp()),
                "patient_id": patient_id,
                "reminder_time": reminder_data.reminder_time,
                "message": reminder_data.message,
                "days_of_week": reminder_data.days_of_week,
                "is_enabled": True,
                "created_at": datetime.now().isoformat()
            }
            
            # Add reminder to patient's hydration_reminders array
            result = self.patient_test_collection.update_one(
                {"patient_id": patient_id},
                {"$push": {"hydration_reminders": reminder_data_dict}}
            )
            
            if result.modified_count > 0:
                print(f"✅ Hydration reminder saved to Patient_test collection for patient {patient_id}")
                return HydrationResponse(
                    success=True,
                    data=reminder_data_dict,
                    message="Hydration reminder created successfully in Patient_test collection"
                )
            else:
                return HydrationResponse(
                    success=False,
                    message="Failed to create hydration reminder in Patient_test collection"
                )
        except Exception as e:
            return HydrationResponse(
                success=False,
                error=f"Error creating hydration reminder: {str(e)}"
            )
    
    def get_hydration_reminders(self, patient_id: str) -> HydrationResponse:
        """Get all hydration reminders from Patient_test collection"""
        try:
            if not self.mongo_client:
                return HydrationResponse(
                    success=False,
                    message="Database connection not available"
                )
            
            # Find patient and get their hydration reminders
            patient = self.patient_test_collection.find_one({"patient_id": patient_id})
            if not patient:
                return HydrationResponse(
                    success=False,
                    message=f"Patient with ID {patient_id} not found in Patient_test collection"
                )
            
            # Get hydration reminders from patient document
            reminders = patient.get("hydration_reminders", [])
            
            return HydrationResponse(
                success=True,
                data={"reminders": reminders},
                message=f"Retrieved {len(reminders)} hydration reminders from Patient_test collection"
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
        """Generate weekly hydration report from Patient_test collection"""
        try:
            if week_start is None:
                week_start = date.today() - timedelta(days=date.today().weekday())
            
            week_end = week_start + timedelta(days=6)
            
            if not self.mongo_client:
                # Fallback report if no database
                return HydrationWeeklyReport(
                    patient_id=patient_id,
                    week_start=week_start,
                    week_end=week_end,
                    total_intake_ml=0,
                    average_daily_intake_ml=0,
                    goal_achievement_rate=0,
                    most_consumed_type="water",
                    best_day=week_start,
                    worst_day=week_start,
                    improvement_suggestions=["Start tracking your hydration"],
                    weekly_trend="unknown"
                )
            
            # Find patient and get their hydration records
            patient = self.patient_test_collection.find_one({"patient_id": patient_id})
            if not patient:
                return HydrationWeeklyReport(
                    patient_id=patient_id,
                    week_start=week_start,
                    week_end=week_end,
                    total_intake_ml=0,
                    average_daily_intake_ml=0,
                    goal_achievement_rate=0,
                    most_consumed_type="water",
                    best_day=week_start,
                    worst_day=week_start,
                    improvement_suggestions=["Patient not found"],
                    weekly_trend="unknown"
                )
            
            # Get hydration records from patient document
            hydration_records = patient.get("hydration_records", [])
            hydration_goal = patient.get("hydration_goal", {})
            
            # Filter records for the week
            week_records = []
            for record in hydration_records:
                timestamp = record.get("timestamp", "")
                if timestamp:
                    try:
                        record_date = datetime.fromisoformat(timestamp.replace('Z', '+00:00')).date()
                        if week_start <= record_date <= week_end:
                            week_records.append(record)
                    except:
                        pass
            
            # Calculate weekly stats
            total_intake_ml = sum(record.get("amount_ml", 0) for record in week_records)
            average_daily_intake_ml = total_intake_ml / 7 if week_records else 0
            
            # Calculate goal achievement rate
            daily_goal_ml = hydration_goal.get("daily_goal_ml", 2000)
            weekly_goal_ml = daily_goal_ml * 7
            goal_achievement_rate = (total_intake_ml / weekly_goal_ml * 100) if weekly_goal_ml > 0 else 0
            
            # Find most consumed type
            type_counts = {}
            for record in week_records:
                hydration_type = record.get("hydration_type", "water")
                type_counts[hydration_type] = type_counts.get(hydration_type, 0) + record.get("amount_ml", 0)
            most_consumed_type = max(type_counts.items(), key=lambda x: x[1])[0] if type_counts else "water"
            
            # Find best and worst days
            daily_totals = {}
            for record in week_records:
                timestamp = record.get("timestamp", "")
                if timestamp:
                    try:
                        record_date = datetime.fromisoformat(timestamp.replace('Z', '+00:00')).date()
                        daily_totals[record_date] = daily_totals.get(record_date, 0) + record.get("amount_ml", 0)
                    except:
                        pass
            
            best_day = max(daily_totals.items(), key=lambda x: x[1])[0] if daily_totals else week_start
            worst_day = min(daily_totals.items(), key=lambda x: x[1])[0] if daily_totals else week_start
            
            # Generate improvement suggestions
            improvement_suggestions = []
            if goal_achievement_rate < 50:
                improvement_suggestions.append("Set more frequent reminders")
                improvement_suggestions.append("Keep a water bottle nearby")
            if goal_achievement_rate < 75:
                improvement_suggestions.append("Track intake more consistently")
            if not week_records:
                improvement_suggestions.append("Start tracking your hydration")
            
            # Determine weekly trend
            if len(daily_totals) >= 3:
                daily_values = list(daily_totals.values())
                if daily_values[-1] > daily_values[0]:
                    weekly_trend = "improving"
                elif daily_values[-1] < daily_values[0]:
                    weekly_trend = "declining"
                else:
                    weekly_trend = "stable"
            else:
                weekly_trend = "insufficient_data"
            
            return HydrationWeeklyReport(
                patient_id=patient_id,
                week_start=week_start,
                week_end=week_end,
                total_intake_ml=total_intake_ml,
                average_daily_intake_ml=average_daily_intake_ml,
                goal_achievement_rate=goal_achievement_rate,
                most_consumed_type=most_consumed_type,
                best_day=best_day,
                worst_day=worst_day,
                improvement_suggestions=improvement_suggestions,
                weekly_trend=weekly_trend
            )
        except Exception as e:
            print(f"❌ Error generating weekly report: {str(e)}")
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
                improvement_suggestions=["Error generating report"],
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

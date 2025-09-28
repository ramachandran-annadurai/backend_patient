from pydantic import BaseModel
from typing import List, Optional, Dict, Any
from datetime import datetime, date
from enum import Enum

class HydrationType(str, Enum):
    WATER = "water"
    TEA = "tea"
    COFFEE = "coffee"
    JUICE = "juice"
    SODA = "soda"
    SPORTS_DRINK = "sports_drink"
    SOUP = "soup"
    MILK = "milk"
    OTHER = "other"

class HydrationIntake(BaseModel):
    id: Optional[str] = None
    patient_id: str
    hydration_type: HydrationType
    amount_ml: float
    amount_oz: Optional[float] = None
    timestamp: datetime
    notes: Optional[str] = None
    temperature: Optional[str] = None  # hot, cold, room temperature
    additives: Optional[List[str]] = None  # sugar, lemon, etc.
    created_at: datetime = datetime.now()
    updated_at: datetime = datetime.now()

class HydrationGoal(BaseModel):
    id: Optional[str] = None
    patient_id: str
    daily_goal_ml: float
    daily_goal_oz: Optional[float] = None
    start_date: date
    end_date: Optional[date] = None
    is_active: bool = True
    reminder_enabled: bool = True
    reminder_times: Optional[List[str]] = None  # ["08:00", "12:00", "16:00", "20:00"]
    created_at: datetime = datetime.now()
    updated_at: datetime = datetime.now()

class HydrationReminder(BaseModel):
    id: Optional[str] = None
    patient_id: str
    reminder_time: str  # HH:MM format
    message: str
    is_enabled: bool = True
    days_of_week: List[int] = [0, 1, 2, 3, 4, 5, 6]  # 0=Monday, 6=Sunday
    created_at: datetime = datetime.now()

class HydrationStats(BaseModel):
    patient_id: str
    date: date
    total_intake_ml: float
    total_intake_oz: float
    goal_ml: float
    goal_oz: float
    goal_percentage: float
    intake_by_type: Dict[str, float]  # type -> amount in ml
    average_intake_per_hour: float
    peak_hour: Optional[str] = None
    last_intake_time: Optional[datetime] = None
    hours_since_last_intake: Optional[float] = None
    is_goal_met: bool
    hydration_score: int  # 1-10 scale

class HydrationAnalysis(BaseModel):
    patient_id: str
    analysis_date: date
    current_hydration_level: str  # excellent, good, fair, poor, critical
    recommendations: List[str]
    warnings: List[str]
    trends: Dict[str, Any]  # weekly trends, patterns
    comparison_to_goal: Dict[str, Any]
    optimal_times: List[str]  # best times to drink water
    dehydration_risk: str  # low, medium, high

class HydrationResponse(BaseModel):
    success: bool
    data: Optional[Dict] = None
    message: Optional[str] = None
    error: Optional[str] = None

class HydrationIntakeRequest(BaseModel):
    hydration_type: HydrationType
    amount_ml: float
    notes: Optional[str] = None
    temperature: Optional[str] = None
    additives: Optional[List[str]] = None

class HydrationGoalRequest(BaseModel):
    daily_goal_ml: float
    reminder_enabled: bool = True
    reminder_times: Optional[List[str]] = None

class HydrationReminderRequest(BaseModel):
    reminder_time: str
    message: str
    days_of_week: List[int] = [0, 1, 2, 3, 4, 5, 6]

class HydrationWeeklyReport(BaseModel):
    patient_id: str
    week_start: date
    week_end: date
    total_intake_ml: float
    average_daily_intake_ml: float
    goal_achievement_rate: float
    most_consumed_type: str
    best_day: date
    worst_day: date
    improvement_suggestions: List[str]
    weekly_trend: str  # improving, declining, stable

from pydantic import BaseModel, EmailStr
from typing import Optional, List
from datetime import datetime

# User Schemas
class UserBase(BaseModel):
    email: EmailStr
    first_name: str
    last_name: str
    phone_number: Optional[str] = None
    date_of_birth: Optional[datetime] = None
    pregnancy_week: Optional[int] = None
    due_date: Optional[datetime] = None
    weight: Optional[float] = None
    height: Optional[float] = None
    location_lat: Optional[float] = None
    location_lon: Optional[float] = None
    timezone: str = "UTC"

class UserCreate(UserBase):
    password: str

class UserUpdate(BaseModel):
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    phone_number: Optional[str] = None
    pregnancy_week: Optional[int] = None
    due_date: Optional[datetime] = None
    weight: Optional[float] = None
    height: Optional[float] = None
    location_lat: Optional[float] = None
    location_lon: Optional[float] = None
    timezone: Optional[str] = None

class User(UserBase):
    id: int
    is_active: bool
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True

# Patient Schemas
class PatientBase(BaseModel):
    patient_id: str
    name: str
    email: Optional[str] = None
    pregnancy_week: Optional[int] = None
    due_date: Optional[datetime] = None
    daily_goal_ml: int = 2500

class PatientCreate(PatientBase):
    pass

class Patient(PatientBase):
    id: int
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True

class PatientHydrationLogBase(BaseModel):
    amount_ml: int
    drink_type: str = "water"
    notes: Optional[str] = None
    pregnancy_week: Optional[int] = None

class PatientHydrationLogCreate(PatientHydrationLogBase):
    pass

class PatientHydrationLog(PatientHydrationLogBase):
    id: int
    patient_id: str
    timestamp: datetime

    class Config:
        from_attributes = True

# Hydration Schemas
class HydrationLogBase(BaseModel):
    amount_ml: int
    drink_type: str = "water"
    notes: Optional[str] = None

class HydrationLogCreate(HydrationLogBase):
    pass

class HydrationLog(HydrationLogBase):
    id: int
    user_id: int
    timestamp: datetime

    class Config:
        from_attributes = True

# Weather Schemas
class WeatherDataBase(BaseModel):
    temperature: float
    humidity: float
    location_lat: float
    location_lon: float
    weather_condition: Optional[str] = None

class WeatherDataCreate(WeatherDataBase):
    pass

class WeatherData(WeatherDataBase):
    id: int
    user_id: int
    timestamp: datetime

    class Config:
        from_attributes = True

# Symptom Schemas
class SymptomLogBase(BaseModel):
    symptom_type: str
    severity: int
    notes: Optional[str] = None

class SymptomLogCreate(SymptomLogBase):
    pass

class SymptomLog(SymptomLogBase):
    id: int
    user_id: int
    timestamp: datetime

    class Config:
        from_attributes = True

# Alert Schemas
class AlertBase(BaseModel):
    alert_type: str
    message: str
    severity: str = "medium"
    alert_metadata: Optional[dict] = None

class AlertCreate(AlertBase):
    pass

class Alert(AlertBase):
    id: int
    user_id: int
    sent_via: Optional[str] = None
    is_read: bool
    timestamp: datetime

    class Config:
        from_attributes = True

# Hydration Goal Schemas
class HydrationGoalBase(BaseModel):
    daily_goal_ml: int
    weather_adjustment: float = 1.0
    pregnancy_adjustment: float = 1.0
    activity_adjustment: float = 1.0

class HydrationGoalCreate(HydrationGoalBase):
    pass

class HydrationGoal(HydrationGoalBase):
    id: int
    user_id: int
    effective_date: datetime
    is_active: bool

    class Config:
        from_attributes = True

# Educational Content Schemas
class EducationalContentBase(BaseModel):
    title: str
    content: str
    content_type: str
    target_audience: str = "pregnant_women"
    pregnancy_week_min: Optional[int] = None
    pregnancy_week_max: Optional[int] = None

class EducationalContentCreate(EducationalContentBase):
    pass

class EducationalContent(EducationalContentBase):
    id: int
    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True

# Dashboard/Summary Schemas
class HydrationSummary(BaseModel):
    date: datetime
    total_intake_ml: int
    goal_ml: int
    percentage_complete: float
    weather_adjustment: float
    pregnancy_adjustment: float
    risk_score: float

class WeeklyReport(BaseModel):
    user_id: int
    week_start: datetime
    week_end: datetime
    total_intake_ml: int
    average_daily_intake_ml: float
    goal_completion_rate: float
    dehydration_risk_events: int
    weather_impact: dict
    recommendations: List[str]

# Authentication Schemas
class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    email: Optional[str] = None

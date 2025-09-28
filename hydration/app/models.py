from sqlalchemy import Column, Integer, String, Float, DateTime, Boolean, Text, ForeignKey, JSON
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.database import Base

class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    first_name = Column(String, nullable=False)
    last_name = Column(String, nullable=False)
    phone_number = Column(String, nullable=True)
    date_of_birth = Column(DateTime, nullable=True)
    pregnancy_week = Column(Integer, nullable=True)
    due_date = Column(DateTime, nullable=True)
    weight = Column(Float, nullable=True)  # kg
    height = Column(Float, nullable=True)  # cm
    location_lat = Column(Float, nullable=True)
    location_lon = Column(Float, nullable=True)
    timezone = Column(String, default="UTC")
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    hydration_logs = relationship("HydrationLog", back_populates="user")
    weather_data = relationship("WeatherData", back_populates="user")
    alerts = relationship("Alert", back_populates="user")
    symptoms = relationship("SymptomLog", back_populates="user")

class HydrationLog(Base):
    __tablename__ = "hydration_logs"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    amount_ml = Column(Integer, nullable=False)  # Amount in milliliters
    timestamp = Column(DateTime(timezone=True), server_default=func.now())
    drink_type = Column(String, default="water")  # water, juice, tea, etc.
    notes = Column(Text, nullable=True)
    
    # Relationships
    user = relationship("User", back_populates="hydration_logs")

class WeatherData(Base):
    __tablename__ = "weather_data"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    temperature = Column(Float, nullable=False)  # Celsius
    humidity = Column(Float, nullable=False)  # Percentage
    location_lat = Column(Float, nullable=False)
    location_lon = Column(Float, nullable=False)
    timestamp = Column(DateTime(timezone=True), server_default=func.now())
    weather_condition = Column(String, nullable=True)  # sunny, cloudy, rainy, etc.
    
    # Relationships
    user = relationship("User", back_populates="weather_data")

class SymptomLog(Base):
    __tablename__ = "symptom_logs"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    symptom_type = Column(String, nullable=False)  # headache, fatigue, dizziness, etc.
    severity = Column(Integer, nullable=False)  # 1-10 scale
    timestamp = Column(DateTime(timezone=True), server_default=func.now())
    notes = Column(Text, nullable=True)
    
    # Relationships
    user = relationship("User", back_populates="symptoms")

class Alert(Base):
    __tablename__ = "alerts"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    alert_type = Column(String, nullable=False)  # low_hydration, dehydration_risk, etc.
    message = Column(Text, nullable=False)
    severity = Column(String, default="medium")  # low, medium, high, critical
    sent_via = Column(String, nullable=True)  # push, sms, email
    is_read = Column(Boolean, default=False)
    timestamp = Column(DateTime(timezone=True), server_default=func.now())
    alert_metadata = Column(JSON, nullable=True)  # Additional data like risk_score, etc.
    
    # Relationships
    user = relationship("User", back_populates="alerts")

class HydrationGoal(Base):
    __tablename__ = "hydration_goals"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    daily_goal_ml = Column(Integer, nullable=False)
    weather_adjustment = Column(Float, default=1.0)
    pregnancy_adjustment = Column(Float, default=1.0)
    activity_adjustment = Column(Float, default=1.0)
    effective_date = Column(DateTime(timezone=True), server_default=func.now())
    is_active = Column(Boolean, default=True)
    
    # Relationships
    user = relationship("User")

class Patient(Base):
    __tablename__ = "patients"
    
    id = Column(Integer, primary_key=True, index=True)
    patient_id = Column(String, unique=True, index=True, nullable=False)  # External patient ID
    name = Column(String, nullable=False)
    email = Column(String, nullable=True)
    pregnancy_week = Column(Integer, nullable=True)
    due_date = Column(DateTime, nullable=True)
    daily_goal_ml = Column(Integer, default=2500)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    hydration_logs = relationship("PatientHydrationLog", back_populates="patient")

class PatientHydrationLog(Base):
    __tablename__ = "patient_hydration_logs"
    
    id = Column(Integer, primary_key=True, index=True)
    patient_id = Column(String, ForeignKey("patients.patient_id"), nullable=False)
    amount_ml = Column(Integer, nullable=False)  # Amount in milliliters
    timestamp = Column(DateTime(timezone=True), server_default=func.now())
    drink_type = Column(String, default="water")  # water, juice, tea, etc.
    notes = Column(Text, nullable=True)
    pregnancy_week = Column(Integer, nullable=True)
    
    # Relationships
    patient = relationship("Patient", back_populates="hydration_logs")

class EducationalContent(Base):
    __tablename__ = "educational_content"
    
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    content = Column(Text, nullable=False)
    content_type = Column(String, nullable=False)  # tip, article, reminder
    target_audience = Column(String, default="pregnant_women")
    pregnancy_week_min = Column(Integer, nullable=True)
    pregnancy_week_max = Column(Integer, nullable=True)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

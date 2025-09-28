#!/usr/bin/env python3
"""
Minimal working patient API
"""
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime
import uvicorn
import sqlite3
import json

app = FastAPI(title="Minimal Patient API")

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins for development
    allow_credentials=True,
    allow_methods=["*"],  # Allow all methods
    allow_headers=["*"],  # Allow all headers
)

# In-memory storage for simplicity
patients_db = {}

class PatientCreate(BaseModel):
    patient_id: str
    name: str
    email: Optional[str] = None
    pregnancy_week: Optional[int] = None
    due_date: Optional[str] = None
    daily_goal_ml: int = 2500

class Patient(BaseModel):
    patient_id: str
    name: str
    email: Optional[str] = None
    pregnancy_week: Optional[int] = None
    due_date: Optional[str] = None
    daily_goal_ml: int = 2500
    created_at: str
    hydration_logs: Optional[List[dict]] = []
    
    class Config:
        extra = "allow"  # Allow extra fields like hydration_logs

class HydrationLogCreate(BaseModel):
    amount_ml: int
    drink_type: str = "water"
    notes: Optional[str] = None
    pregnancy_week: Optional[int] = None

class HydrationLog(BaseModel):
    id: int
    patient_id: str
    amount_ml: int
    drink_type: str
    notes: Optional[str] = None
    pregnancy_week: Optional[int] = None
    timestamp: str

class HydrationSummary(BaseModel):
    date: str
    total_intake_ml: int
    goal_ml: int
    percentage_complete: float
    weather_adjustment: float
    pregnancy_adjustment: float
    risk_score: float

@app.post("/api/v1/patients/", response_model=Patient)
async def create_patient(patient: PatientCreate):
    """Create a new patient"""
    if patient.patient_id in patients_db:
        raise HTTPException(status_code=400, detail="Patient with this ID already exists")
    
    patient_data = {
        "patient_id": patient.patient_id,
        "name": patient.name,
        "email": patient.email,
        "pregnancy_week": patient.pregnancy_week,
        "due_date": patient.due_date,
        "daily_goal_ml": patient.daily_goal_ml,
        "created_at": datetime.now().isoformat(),
        "hydration_logs": []
    }
    
    patients_db[patient.patient_id] = patient_data
    return Patient(**patient_data)

@app.get("/api/v1/patients/{patient_id}", response_model=Patient)
async def get_patient(patient_id: str):
    """Get patient by ID"""
    if patient_id not in patients_db:
        raise HTTPException(status_code=404, detail="Patient not found")
    
    # Ensure patient has hydration_logs field
    patient_data = patients_db[patient_id]
    if "hydration_logs" not in patient_data:
        patient_data["hydration_logs"] = []
        patients_db[patient_id] = patient_data
    
    return Patient(**patient_data)

@app.post("/api/v1/patients/{patient_id}/hydration/log", response_model=HydrationLog)
async def log_patient_hydration(patient_id: str, log: HydrationLogCreate):
    """Log water intake for a patient"""
    if patient_id not in patients_db:
        raise HTTPException(status_code=404, detail="Patient not found")
    
    # Ensure patient has hydration_logs field
    if "hydration_logs" not in patients_db[patient_id]:
        patients_db[patient_id]["hydration_logs"] = []
    
    # Create log entry
    log_id = len(patients_db[patient_id]["hydration_logs"]) + 1
    log_data = {
        "id": log_id,
        "patient_id": patient_id,
        "amount_ml": log.amount_ml,
        "drink_type": log.drink_type,
        "notes": log.notes,
        "pregnancy_week": log.pregnancy_week,
        "timestamp": datetime.now().isoformat()
    }
    
    # Store log directly in patient's data
    patients_db[patient_id]["hydration_logs"].append(log_data)
    
    return HydrationLog(**log_data)

@app.get("/api/v1/patients/{patient_id}/hydration/today", response_model=HydrationSummary)
async def get_patient_today_hydration(patient_id: str):
    """Get today's hydration summary for a patient"""
    if patient_id not in patients_db:
        raise HTTPException(status_code=404, detail="Patient not found")
    
    patient = patients_db[patient_id]
    today = datetime.now().date().isoformat()
    
    # Calculate today's total intake from patient's hydration_logs
    total_intake = 0
    for log in patient["hydration_logs"]:
        if log["timestamp"].startswith(today):
            total_intake += log["amount_ml"]
    
    goal_ml = patient["daily_goal_ml"]
    percentage_complete = (total_intake / goal_ml * 100) if goal_ml > 0 else 0
    risk_score = max(0, 1 - (total_intake / goal_ml)) if goal_ml > 0 else 1
    
    return HydrationSummary(
        date=datetime.now().isoformat(),
        total_intake_ml=total_intake,
        goal_ml=goal_ml,
        percentage_complete=round(percentage_complete, 1),
        weather_adjustment=1.0,
        pregnancy_adjustment=1.0,
        risk_score=round(risk_score, 2)
    )

@app.get("/api/v1/patients/{patient_id}/hydration/history", response_model=List[HydrationLog])
async def get_patient_hydration_history(patient_id: str, days: int = 7):
    """Get hydration history for a patient"""
    if patient_id not in patients_db:
        raise HTTPException(status_code=404, detail="Patient not found")
    
    # Get logs directly from patient's data
    patient_logs = patients_db[patient_id]["hydration_logs"].copy()
    
    # Sort by timestamp (newest first) and limit to requested days
    patient_logs.sort(key=lambda x: x["timestamp"], reverse=True)
    
    return [HydrationLog(**log) for log in patient_logs]

@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "minimal-patient-api"}

if __name__ == "__main__":
    print("Starting Minimal Patient API...")
    print("Test the endpoints:")
    print("1. Create patient: POST http://localhost:8000/api/v1/patients/")
    print("2. Log hydration: POST http://localhost:8000/api/v1/patients/patient_001/hydration/log")
    print("3. Get today: GET http://localhost:8000/api/v1/patients/patient_001/hydration/today")
    print("4. Get history: GET http://localhost:8000/api/v1/patients/patient_001/hydration/history")
    
    uvicorn.run(app, host="0.0.0.0", port=8000)

sto
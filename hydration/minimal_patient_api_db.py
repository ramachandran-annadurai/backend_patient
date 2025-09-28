#!/usr/bin/env python3
"""
Minimal Patient API with SQLite Database Storage
"""
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime
import uvicorn
import sqlite3
import json
import os

app = FastAPI(title="Minimal Patient API with Database")

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins for development
    allow_credentials=True,
    allow_methods=["*"],  # Allow all methods
    allow_headers=["*"],  # Allow all headers
)

# Database setup
DATABASE_FILE = "patients_db.sqlite"

def init_database():
    """Initialize the SQLite database with tables"""
    conn = sqlite3.connect(DATABASE_FILE)
    cursor = conn.cursor()
    
    # Create patients table
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS patients (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            patient_id TEXT UNIQUE NOT NULL,
            name TEXT NOT NULL,
            email TEXT,
            pregnancy_week INTEGER,
            due_date TEXT,
            daily_goal_ml INTEGER DEFAULT 2500,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    
    # Create hydration_logs table
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS hydration_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            patient_id TEXT NOT NULL,
            amount_ml INTEGER NOT NULL,
            drink_type TEXT DEFAULT 'water',
            notes TEXT,
            pregnancy_week INTEGER,
            timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (patient_id) REFERENCES patients (patient_id)
        )
    ''')
    
    conn.commit()
    conn.close()
    print(f"✅ Database initialized: {DATABASE_FILE}")

# Initialize database on startup
init_database()

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
    """Create a new patient in database"""
    conn = sqlite3.connect(DATABASE_FILE)
    cursor = conn.cursor()
    
    try:
        # Check if patient already exists
        cursor.execute("SELECT patient_id FROM patients WHERE patient_id = ?", (patient.patient_id,))
        if cursor.fetchone():
            raise HTTPException(status_code=400, detail="Patient with this ID already exists")
        
        # Insert new patient
        cursor.execute('''
            INSERT INTO patients (patient_id, name, email, pregnancy_week, due_date, daily_goal_ml)
            VALUES (?, ?, ?, ?, ?, ?)
        ''', (
            patient.patient_id,
            patient.name,
            patient.email,
            patient.pregnancy_week,
            patient.due_date,
            patient.daily_goal_ml
        ))
        
        conn.commit()
        
        # Get the created patient
        cursor.execute("SELECT * FROM patients WHERE patient_id = ?", (patient.patient_id,))
        patient_row = cursor.fetchone()
        
        patient_data = {
            "patient_id": patient_row[1],
            "name": patient_row[2],
            "email": patient_row[3],
            "pregnancy_week": patient_row[4],
            "due_date": patient_row[5],
            "daily_goal_ml": patient_row[6],
            "created_at": patient_row[7],
            "hydration_logs": []
        }
        
        return Patient(**patient_data)
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")
    finally:
        conn.close()

@app.get("/api/v1/patients/{patient_id}", response_model=Patient)
async def get_patient(patient_id: str):
    """Get patient by ID from database"""
    conn = sqlite3.connect(DATABASE_FILE)
    cursor = conn.cursor()
    
    try:
        # Get patient data
        cursor.execute("SELECT * FROM patients WHERE patient_id = ?", (patient_id,))
        patient_row = cursor.fetchone()
        
        if not patient_row:
            raise HTTPException(status_code=404, detail="Patient not found")
        
        # Get hydration logs
        cursor.execute('''
            SELECT id, patient_id, amount_ml, drink_type, notes, pregnancy_week, timestamp
            FROM hydration_logs WHERE patient_id = ? ORDER BY timestamp DESC
        ''', (patient_id,))
        log_rows = cursor.fetchall()
        
        hydration_logs = []
        for log_row in log_rows:
            hydration_logs.append({
                "id": log_row[0],
                "patient_id": log_row[1],
                "amount_ml": log_row[2],
                "drink_type": log_row[3],
                "notes": log_row[4],
                "pregnancy_week": log_row[5],
                "timestamp": log_row[6]
            })
        
        patient_data = {
            "patient_id": patient_row[1],
            "name": patient_row[2],
            "email": patient_row[3],
            "pregnancy_week": patient_row[4],
            "due_date": patient_row[5],
            "daily_goal_ml": patient_row[6],
            "created_at": patient_row[7],
            "hydration_logs": hydration_logs
        }
        
        return Patient(**patient_data)
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")
    finally:
        conn.close()

@app.post("/api/v1/patients/{patient_id}/hydration/log", response_model=HydrationLog)
async def log_patient_hydration(patient_id: str, log: HydrationLogCreate):
    """Log water intake for a patient in database"""
    conn = sqlite3.connect(DATABASE_FILE)
    cursor = conn.cursor()
    
    try:
        # Check if patient exists
        cursor.execute("SELECT patient_id FROM patients WHERE patient_id = ?", (patient_id,))
        if not cursor.fetchone():
            raise HTTPException(status_code=404, detail="Patient not found")
        
        # Insert hydration log
        cursor.execute('''
            INSERT INTO hydration_logs (patient_id, amount_ml, drink_type, notes, pregnancy_week)
            VALUES (?, ?, ?, ?, ?)
        ''', (
            patient_id,
            log.amount_ml,
            log.drink_type,
            log.notes,
            log.pregnancy_week
        ))
        
        conn.commit()
        
        # Get the created log
        log_id = cursor.lastrowid
        cursor.execute('''
            SELECT id, patient_id, amount_ml, drink_type, notes, pregnancy_week, timestamp
            FROM hydration_logs WHERE id = ?
        ''', (log_id,))
        log_row = cursor.fetchone()
        
        log_data = {
            "id": log_row[0],
            "patient_id": log_row[1],
            "amount_ml": log_row[2],
            "drink_type": log_row[3],
            "notes": log_row[4],
            "pregnancy_week": log_row[5],
            "timestamp": log_row[6]
        }
        
        return HydrationLog(**log_data)
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")
    finally:
        conn.close()

@app.get("/api/v1/patients/{patient_id}/hydration/today", response_model=HydrationSummary)
async def get_patient_today_hydration(patient_id: str):
    """Get today's hydration summary for a patient from database"""
    conn = sqlite3.connect(DATABASE_FILE)
    cursor = conn.cursor()
    
    try:
        # Get patient data
        cursor.execute("SELECT daily_goal_ml FROM patients WHERE patient_id = ?", (patient_id,))
        patient_row = cursor.fetchone()
        
        if not patient_row:
            raise HTTPException(status_code=404, detail="Patient not found")
        
        goal_ml = patient_row[0]
        
        # Get today's total intake
        today = datetime.now().date().isoformat()
        cursor.execute('''
            SELECT SUM(amount_ml) FROM hydration_logs 
            WHERE patient_id = ? AND DATE(timestamp) = ?
        ''', (patient_id, today))
        
        result = cursor.fetchone()
        total_intake = result[0] if result[0] else 0
        
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
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")
    finally:
        conn.close()

@app.get("/api/v1/patients/{patient_id}/hydration/history", response_model=List[HydrationLog])
async def get_patient_hydration_history(patient_id: str, days: int = 7):
    """Get hydration history for a patient from database"""
    conn = sqlite3.connect(DATABASE_FILE)
    cursor = conn.cursor()
    
    try:
        # Check if patient exists
        cursor.execute("SELECT patient_id FROM patients WHERE patient_id = ?", (patient_id,))
        if not cursor.fetchone():
            raise HTTPException(status_code=404, detail="Patient not found")
        
        # Get hydration logs
        cursor.execute('''
            SELECT id, patient_id, amount_ml, drink_type, notes, pregnancy_week, timestamp
            FROM hydration_logs 
            WHERE patient_id = ? 
            ORDER BY timestamp DESC
        ''', (patient_id,))
        
        log_rows = cursor.fetchall()
        hydration_logs = []
        
        for log_row in log_rows:
            hydration_logs.append(HydrationLog(
                id=log_row[0],
                patient_id=log_row[1],
                amount_ml=log_row[2],
                drink_type=log_row[3],
                notes=log_row[4],
                pregnancy_week=log_row[5],
                timestamp=log_row[6]
            ))
        
        return hydration_logs
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")
    finally:
        conn.close()

@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "minimal-patient-api-db"}

if __name__ == "__main__":
    print("Starting Minimal Patient API with Database Storage...")
    print(f"Database file: {DATABASE_FILE}")
    print("Test the endpoints:")
    print("1. Create patient: POST http://localhost:8000/api/v1/patients/")
    print("2. Log hydration: POST http://localhost:8000/api/v1/patients/patient_001/hydration/log")
    print("3. Get today: GET http://localhost:8000/api/v1/patients/patient_001/hydration/today")
    print("4. Get history: GET http://localhost:8000/api/v1/patients/patient_001/hydration/history")
    
    uvicorn.run(app, host="0.0.0.0", port=8000)

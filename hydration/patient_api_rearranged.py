#!/usr/bin/env python3
"""
Patient API - Rearranged to store in patient collection with specific MongoDB Atlas config
"""
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime
import uvicorn
import pymongo
from pymongo import MongoClient
import os

app = FastAPI(title="Patient API - MongoDB Atlas Patient Collection")

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins for development
    allow_credentials=True,
    allow_methods=["*"],  # Allow all methods
    allow_headers=["*"],  # Allow all headers
)

# MongoDB Atlas configuration - Rearranged as requested
MONGO_URI = "mongodb+srv://ramya:XxFn6n0NXx0wBplV@cluster0.c1g1bm5.mongodb.net"
DB_NAME = "patients_db"
COLLECTION_NAME = "patient"

# MongoDB client
client = None
db = None

def init_mongodb():
    """Initialize MongoDB Atlas connection with rearranged config"""
    global client, db
    try:
        # Connect to MongoDB Atlas with SSL/TLS
        client = MongoClient(MONGO_URI, tls=True, tlsAllowInvalidCertificates=True)
        db = client[DB_NAME]
        
        # Test connection
        client.admin.command('ping')
        print(f"✅ Connected to MongoDB Atlas: cluster0.c1g1bm5.mongodb.net")
        print(f"✅ Database: {DB_NAME}")
        print(f"✅ Collection: {COLLECTION_NAME}")
        
        # Create index for better performance (handle existing data)
        try:
            db[COLLECTION_NAME].create_index("patient_id", unique=True)
        except Exception as e:
            print(f"⚠️ Index creation warning: {e}")
            print("   Continuing without unique index...")
        
    except Exception as e:
        print(f"❌ MongoDB Atlas connection failed: {e}")
        raise

# Initialize MongoDB on startup
init_mongodb()

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
    id: str
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
    """Create a new patient in MongoDB Atlas patient collection"""
    try:
        # Check if patient already exists
        existing_patient = db[COLLECTION_NAME].find_one({"patient_id": patient.patient_id})
        if existing_patient:
            raise HTTPException(status_code=400, detail="Patient with this ID already exists")
        
        # Create patient document with empty hydration_logs array
        patient_doc = {
            "patient_id": patient.patient_id,
            "name": patient.name,
            "email": patient.email,
            "pregnancy_week": patient.pregnancy_week,
            "due_date": patient.due_date,
            "daily_goal_ml": patient.daily_goal_ml,
            "created_at": datetime.now().isoformat(),
            "hydration_logs": []  # Empty array to store water intake logs
        }
        
        # Insert patient into patient collection
        result = db[COLLECTION_NAME].insert_one(patient_doc)
        
        # Return patient data
        patient_data = {
            "patient_id": patient_doc["patient_id"],
            "name": patient_doc["name"],
            "email": patient_doc["email"],
            "pregnancy_week": patient_doc["pregnancy_week"],
            "due_date": patient_doc["due_date"],
            "daily_goal_ml": patient_doc["daily_goal_ml"],
            "created_at": patient_doc["created_at"],
            "hydration_logs": []
        }
        
        return Patient(**patient_data)
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"MongoDB error: {str(e)}")

@app.get("/api/v1/patients/{patient_id}", response_model=Patient)
async def get_patient(patient_id: str):
    """Get patient by ID from MongoDB Atlas patient collection"""
    try:
        # Get patient data from patient collection
        patient_doc = db[COLLECTION_NAME].find_one({"patient_id": patient_id})
        if not patient_doc:
            raise HTTPException(status_code=404, detail="Patient not found")
        
        # Get hydration logs from patient document
        hydration_logs = patient_doc.get("hydration_logs", [])
        
        patient_data = {
            "patient_id": patient_doc["patient_id"],
            "name": patient_doc["name"],
            "email": patient_doc.get("email"),
            "pregnancy_week": patient_doc.get("pregnancy_week"),
            "due_date": patient_doc.get("due_date"),
            "daily_goal_ml": patient_doc["daily_goal_ml"],
            "created_at": patient_doc["created_at"],
            "hydration_logs": hydration_logs
        }
        
        return Patient(**patient_data)
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"MongoDB error: {str(e)}")

@app.post("/api/v1/patients/{patient_id}/hydration/log", response_model=HydrationLog)
async def log_patient_hydration(patient_id: str, log: HydrationLogCreate):
    """Log water intake for a patient - store in patient collection"""
    try:
        # Check if patient exists in patient collection
        patient_doc = db[COLLECTION_NAME].find_one({"patient_id": patient_id})
        if not patient_doc:
            raise HTTPException(status_code=404, detail="Patient not found")
        
        # Create hydration log entry
        log_entry = {
            "id": str(datetime.now().timestamp()),  # Simple ID based on timestamp
            "patient_id": patient_id,
            "amount_ml": log.amount_ml,
            "drink_type": log.drink_type,
            "notes": log.notes,
            "pregnancy_week": log.pregnancy_week,
            "timestamp": datetime.now().isoformat()
        }
        
        # Add log to patient's hydration_logs array in patient collection
        db[COLLECTION_NAME].update_one(
            {"patient_id": patient_id},
            {"$push": {"hydration_logs": log_entry}}
        )
        
        # Return log data
        log_data = {
            "id": log_entry["id"],
            "patient_id": log_entry["patient_id"],
            "amount_ml": log_entry["amount_ml"],
            "drink_type": log_entry["drink_type"],
            "notes": log_entry["notes"],
            "pregnancy_week": log_entry["pregnancy_week"],
            "timestamp": log_entry["timestamp"]
        }
        
        return HydrationLog(**log_data)
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"MongoDB error: {str(e)}")

@app.get("/api/v1/patients/{patient_id}/hydration/today", response_model=HydrationSummary)
async def get_patient_today_hydration(patient_id: str):
    """Get today's hydration summary from patient collection"""
    try:
        # Get patient data from patient collection
        patient_doc = db[COLLECTION_NAME].find_one({"patient_id": patient_id})
        if not patient_doc:
            raise HTTPException(status_code=404, detail="Patient not found")
        
        goal_ml = patient_doc["daily_goal_ml"]
        hydration_logs = patient_doc.get("hydration_logs", [])
        
        # Calculate today's total intake from patient's hydration_logs
        today = datetime.now().date().isoformat()
        total_intake = 0
        
        for log in hydration_logs:
            if log.get("timestamp", "").startswith(today):
                total_intake += log.get("amount_ml", 0)
        
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
        raise HTTPException(status_code=500, detail=f"MongoDB error: {str(e)}")

@app.get("/api/v1/patients/{patient_id}/hydration/history", response_model=List[HydrationLog])
async def get_patient_hydration_history(patient_id: str, days: int = 7):
    """Get hydration history from patient collection"""
    try:
        # Get patient data from patient collection
        patient_doc = db[COLLECTION_NAME].find_one({"patient_id": patient_id})
        if not patient_doc:
            raise HTTPException(status_code=404, detail="Patient not found")
        
        # Get hydration logs from patient document
        hydration_logs = patient_doc.get("hydration_logs", [])
        
        # Sort by timestamp (newest first)
        hydration_logs.sort(key=lambda x: x.get("timestamp", ""), reverse=True)
        
        # Convert to HydrationLog objects
        result_logs = []
        for log in hydration_logs:
            result_logs.append(HydrationLog(
                id=log.get("id", ""),
                patient_id=log.get("patient_id", ""),
                amount_ml=log.get("amount_ml", 0),
                drink_type=log.get("drink_type", "water"),
                notes=log.get("notes"),
                pregnancy_week=log.get("pregnancy_week"),
                timestamp=log.get("timestamp", "")
            ))
        
        return result_logs
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"MongoDB error: {str(e)}")

@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "patient-api-rearranged"}

if __name__ == "__main__":
    print("Starting Patient API - Rearranged MongoDB Atlas Configuration...")
    print(f"MongoDB Atlas: cluster0.c1g1bm5.mongodb.net")
    print(f"Database: {DB_NAME}")
    print(f"Collection: {COLLECTION_NAME}")
    print("Test the endpoints:")
    print("1. Create patient: POST http://localhost:8000/api/v1/patients/")
    print("2. Log hydration: POST http://localhost:8000/api/v1/patients/patient_001/hydration/log")
    print("3. Get today: GET http://localhost:8000/api/v1/patients/patient_001/hydration/today")
    print("4. Get history: GET http://localhost:8000/api/v1/patients/patient_001/hydration/history")
    
    uvicorn.run(app, host="0.0.0.0", port=8000)

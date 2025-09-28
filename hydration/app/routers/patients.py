from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from datetime import datetime, timedelta
from sqlalchemy import func, and_

from app.database import get_db
from app.models import Patient, PatientHydrationLog
from app.schemas import (
    PatientCreate,
    Patient as PatientSchema,
    PatientHydrationLogCreate,
    PatientHydrationLog as PatientHydrationLogSchema,
    HydrationSummary
)

router = APIRouter()

@router.post("/", response_model=PatientSchema)
async def create_patient(
    patient: PatientCreate,
    db: Session = Depends(get_db)
):
    """Create a new patient"""
    # Check if patient already exists
    existing_patient = db.query(Patient).filter(
        Patient.patient_id == patient.patient_id
    ).first()
    
    if existing_patient:
        raise HTTPException(
            status_code=400,
            detail="Patient with this ID already exists"
        )
    
    db_patient = Patient(
        patient_id=patient.patient_id,
        name=patient.name,
        email=patient.email,
        pregnancy_week=patient.pregnancy_week,
        due_date=patient.due_date,
        daily_goal_ml=patient.daily_goal_ml
    )
    
    db.add(db_patient)
    db.commit()
    db.refresh(db_patient)
    
    return db_patient

@router.get("/{patient_id}", response_model=PatientSchema)
async def get_patient(
    patient_id: str,
    db: Session = Depends(get_db)
):
    """Get patient by ID"""
    patient = db.query(Patient).filter(
        Patient.patient_id == patient_id
    ).first()
    
    if not patient:
        raise HTTPException(
            status_code=404,
            detail="Patient not found"
        )
    
    return patient

@router.post("/{patient_id}/hydration/log", response_model=PatientHydrationLogSchema)
async def log_patient_hydration(
    patient_id: str,
    log: PatientHydrationLogCreate,
    db: Session = Depends(get_db)
):
    """Log water intake for a patient"""
    # Check if patient exists
    patient = db.query(Patient).filter(
        Patient.patient_id == patient_id
    ).first()
    
    if not patient:
        raise HTTPException(
            status_code=404,
            detail="Patient not found"
        )
    
    db_log = PatientHydrationLog(
        patient_id=patient_id,
        amount_ml=log.amount_ml,
        drink_type=log.drink_type,
        notes=log.notes,
        pregnancy_week=log.pregnancy_week
    )
    
    db.add(db_log)
    db.commit()
    db.refresh(db_log)
    
    return db_log

@router.get("/{patient_id}/hydration/today", response_model=HydrationSummary)
async def get_patient_today_hydration(
    patient_id: str,
    db: Session = Depends(get_db)
):
    """Get today's hydration summary for a patient"""
    # Check if patient exists
    patient = db.query(Patient).filter(
        Patient.patient_id == patient_id
    ).first()
    
    if not patient:
        raise HTTPException(
            status_code=404,
            detail="Patient not found"
        )
    
    today = datetime.utcnow().date()
    
    # Get today's total intake
    total_intake = db.query(func.sum(PatientHydrationLog.amount_ml)).filter(
        and_(
            PatientHydrationLog.patient_id == patient_id,
            func.date(PatientHydrationLog.timestamp) == today
        )
    ).scalar() or 0
    
    # Get patient's daily goal
    goal_ml = patient.daily_goal_ml
    
    # Calculate percentage
    percentage_complete = (total_intake / goal_ml * 100) if goal_ml > 0 else 0
    
    # Simple risk score calculation
    risk_score = max(0, 1 - (total_intake / goal_ml)) if goal_ml > 0 else 1
    
    return HydrationSummary(
        date=datetime.utcnow(),
        total_intake_ml=total_intake,
        goal_ml=goal_ml,
        percentage_complete=round(percentage_complete, 1),
        weather_adjustment=1.0,
        pregnancy_adjustment=1.0,
        risk_score=round(risk_score, 2)
    )

@router.get("/{patient_id}/hydration/history", response_model=List[PatientHydrationLogSchema])
async def get_patient_hydration_history(
    patient_id: str,
    days: int = 7,
    db: Session = Depends(get_db)
):
    """Get hydration history for a patient"""
    # Check if patient exists
    patient = db.query(Patient).filter(
        Patient.patient_id == patient_id
    ).first()
    
    if not patient:
        raise HTTPException(
            status_code=404,
            detail="Patient not found"
        )
    
    cutoff_time = datetime.utcnow() - timedelta(days=days)
    
    logs = db.query(PatientHydrationLog).filter(
        and_(
            PatientHydrationLog.patient_id == patient_id,
            PatientHydrationLog.timestamp >= cutoff_time
        )
    ).order_by(PatientHydrationLog.timestamp.desc()).all()
    
    return logs

@router.delete("/{patient_id}/hydration/logs/{log_id}")
async def delete_patient_hydration_log(
    patient_id: str,
    log_id: int,
    db: Session = Depends(get_db)
):
    """Delete a hydration log entry for a patient"""
    log = db.query(PatientHydrationLog).filter(
        and_(
            PatientHydrationLog.id == log_id,
            PatientHydrationLog.patient_id == patient_id
        )
    ).first()
    
    if not log:
        raise HTTPException(
            status_code=404,
            detail="Hydration log not found"
        )
    
    db.delete(log)
    db.commit()
    
    return {"message": "Hydration log deleted successfully"}

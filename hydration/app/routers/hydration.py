from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from datetime import datetime, timedelta
from sqlalchemy import func, and_

from app.database import get_db
from app.models import User, HydrationLog, HydrationGoal
from app.schemas import (
    HydrationLogCreate, 
    HydrationLog as HydrationLogSchema,
    HydrationSummary,
    HydrationGoalCreate,
    HydrationGoal as HydrationGoalSchema
)
from app.core.security import get_current_active_user
from app.services.hydration_engine import hydration_engine
# from app.services.weather_service import weather_service

router = APIRouter()

@router.post("/log", response_model=HydrationLogSchema)
async def log_hydration_intake(
    log: HydrationLogCreate,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Log water intake"""
    db_log = HydrationLog(
        user_id=current_user.id,
        amount_ml=log.amount_ml,
        drink_type=log.drink_type,
        notes=log.notes
    )
    
    db.add(db_log)
    db.commit()
    db.refresh(db_log)
    
    return db_log

@router.get("/logs", response_model=List[HydrationLogSchema])
async def get_hydration_logs(
    days: int = 7,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Get hydration logs for the specified number of days"""
    cutoff_time = datetime.utcnow() - timedelta(days=days)
    
    logs = db.query(HydrationLog).filter(
        and_(
            HydrationLog.user_id == current_user.id,
            HydrationLog.timestamp >= cutoff_time
        )
    ).order_by(HydrationLog.timestamp.desc()).all()
    
    return logs

@router.get("/today", response_model=HydrationSummary)
async def get_today_summary(
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Get today's hydration summary"""
    today = datetime.utcnow().date()
    
    # Get today's total intake
    total_intake = db.query(func.sum(HydrationLog.amount_ml)).filter(
        and_(
            HydrationLog.user_id == current_user.id,
            func.date(HydrationLog.timestamp) == today
        )
    ).scalar() or 0
    
    # Get dynamic goal
    goal_data = await hydration_engine.calculate_dynamic_hydration_goal(current_user, db)
    goal_ml = goal_data["final_goal_ml"]
    
    # Calculate percentage
    percentage_complete = (total_intake / goal_ml * 100) if goal_ml > 0 else 0
    
    # Calculate risk score
    risk_score = hydration_engine.calculate_dehydration_risk_score(current_user, db)
    
    return HydrationSummary(
        date=datetime.utcnow(),
        total_intake_ml=total_intake,
        goal_ml=goal_ml,
        percentage_complete=round(percentage_complete, 1),
        weather_adjustment=goal_data["weather_adjustment"],
        pregnancy_adjustment=goal_data["pregnancy_adjustment"],
        risk_score=round(risk_score, 2)
    )

@router.get("/goal", response_model=HydrationGoalSchema)
async def get_current_goal(
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Get current hydration goal"""
    goal_data = await hydration_engine.calculate_dynamic_hydration_goal(current_user, db)
    
    # Get or create goal record
    goal = db.query(HydrationGoal).filter(
        and_(
            HydrationGoal.user_id == current_user.id,
            HydrationGoal.is_active == True
        )
    ).first()
    
    if not goal:
        goal = HydrationGoal(
            user_id=current_user.id,
            daily_goal_ml=goal_data["final_goal_ml"],
            weather_adjustment=goal_data["weather_adjustment"],
            pregnancy_adjustment=goal_data["pregnancy_adjustment"],
            activity_adjustment=1.0
        )
        db.add(goal)
        db.commit()
        db.refresh(goal)
    else:
        # Update existing goal
        goal.daily_goal_ml = goal_data["final_goal_ml"]
        goal.weather_adjustment = goal_data["weather_adjustment"]
        goal.pregnancy_adjustment = goal_data["pregnancy_adjustment"]
        db.commit()
        db.refresh(goal)
    
    return goal

@router.get("/trend")
async def get_hydration_trend(
    days: int = 7,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Get hydration trend over time"""
    return hydration_engine.calculate_hydration_trend(current_user, db, days)

@router.get("/anomalies")
async def get_hydration_anomalies(
    days: int = 7,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Get detected hydration anomalies"""
    return hydration_engine.detect_anomalies(current_user, db, days)

@router.get("/recommendations")
async def get_hydration_recommendations(
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Get personalized hydration recommendations"""
    return hydration_engine.generate_hydration_recommendations(current_user, db)

@router.delete("/logs/{log_id}")
async def delete_hydration_log(
    log_id: int,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Delete a hydration log entry"""
    log = db.query(HydrationLog).filter(
        and_(
            HydrationLog.id == log_id,
            HydrationLog.user_id == current_user.id
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

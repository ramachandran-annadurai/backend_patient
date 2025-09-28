from fastapi import APIRouter, Depends, HTTPException, status, BackgroundTasks
from sqlalchemy.orm import Session
from typing import List
from datetime import datetime, timedelta

from app.database import get_db
from app.models import User, Alert
from app.schemas import Alert as AlertSchema
from app.core.security import get_current_active_user
from app.services.alert_service import alert_service
from app.services.hydration_engine import hydration_engine

router = APIRouter()

@router.get("/", response_model=List[AlertSchema])
async def get_user_alerts(
    days: int = 7,
    unread_only: bool = False,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Get user's alerts"""
    alerts = await alert_service.get_user_alerts(
        current_user, db, days, unread_only
    )
    return alerts

@router.post("/check")
async def check_hydration_alerts(
    background_tasks: BackgroundTasks,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Manually trigger hydration alert check"""
    # Run alert check in background
    background_tasks.add_task(
        alert_service.check_hydration_alerts,
        current_user,
        db
    )
    
    return {"message": "Alert check initiated"}

@router.put("/{alert_id}/read")
async def mark_alert_as_read(
    alert_id: int,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Mark an alert as read"""
    success = await alert_service.mark_alert_as_read(alert_id, current_user, db)
    
    if not success:
        raise HTTPException(
            status_code=404,
            detail="Alert not found"
        )
    
    return {"message": "Alert marked as read"}

@router.put("/mark-all-read")
async def mark_all_alerts_as_read(
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Mark all user's alerts as read"""
    # Get all unread alerts
    unread_alerts = await alert_service.get_user_alerts(
        current_user, db, unread_only=True
    )
    
    # Mark all as read
    for alert in unread_alerts:
        alert.is_read = True
    
    db.commit()
    
    return {"message": f"Marked {len(unread_alerts)} alerts as read"}

@router.get("/risk-score")
async def get_dehydration_risk_score(
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Get current dehydration risk score"""
    risk_score = hydration_engine.calculate_dehydration_risk_score(current_user, db)
    
    # Determine risk level
    if risk_score >= 0.8:
        risk_level = "critical"
    elif risk_score >= 0.6:
        risk_level = "high"
    elif risk_score >= 0.4:
        risk_level = "medium"
    else:
        risk_level = "low"
    
    return {
        "risk_score": round(risk_score, 2),
        "risk_level": risk_level,
        "recommendations": hydration_engine.generate_hydration_recommendations(current_user, db)
    }

@router.delete("/{alert_id}")
async def delete_alert(
    alert_id: int,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Delete an alert"""
    alert = db.query(Alert).filter(
        Alert.id == alert_id,
        Alert.user_id == current_user.id
    ).first()
    
    if not alert:
        raise HTTPException(
            status_code=404,
            detail="Alert not found"
        )
    
    db.delete(alert)
    db.commit()
    
    return {"message": "Alert deleted successfully"}


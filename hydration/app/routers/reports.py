from fastapi import APIRouter, Depends, HTTPException, status, BackgroundTasks
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime, timedelta

from app.database import get_db
from app.models import User
from app.schemas import WeeklyReport
from app.core.security import get_current_active_user
from app.services.report_service import report_service

router = APIRouter()

@router.get("/weekly", response_model=WeeklyReport)
async def get_weekly_report(
    week_start: Optional[datetime] = None,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Generate weekly hydration report"""
    report = await report_service.generate_weekly_report(current_user, db, week_start)
    return report

@router.post("/weekly/send")
async def send_weekly_report_to_clinician(
    clinician_email: str,
    week_start: Optional[datetime] = None,
    background_tasks: BackgroundTasks = None,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Send weekly report to clinician"""
    # Generate report
    report = await report_service.generate_weekly_report(current_user, db, week_start)
    
    # Send in background
    if background_tasks:
        background_tasks.add_task(
            report_service.send_weekly_report_to_clinician,
            current_user,
            report,
            clinician_email
        )
    
    return {
        "message": "Weekly report sent to clinician",
        "report_summary": report["summary"]
    }

@router.get("/monthly")
async def get_monthly_summary(
    month: Optional[int] = None,
    year: Optional[int] = None,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Get monthly hydration summary"""
    # Default to current month
    if not month or not year:
        now = datetime.utcnow()
        month = month or now.month
        year = year or now.year
    
    # Calculate month boundaries
    month_start = datetime(year, month, 1)
    if month == 12:
        month_end = datetime(year + 1, 1, 1)
    else:
        month_end = datetime(year, month + 1, 1)
    
    # Generate weekly reports for the month
    weekly_reports = []
    current_week_start = month_start
    
    while current_week_start < month_end:
        week_end = min(current_week_start + timedelta(days=7), month_end)
        report = await report_service.generate_weekly_report(
            current_user, db, current_week_start
        )
        weekly_reports.append(report)
        current_week_start = week_end
    
    # Aggregate monthly data
    total_intake = sum(report["summary"]["total_intake_ml"] for report in weekly_reports)
    avg_completion_rate = sum(report["summary"]["goal_completion_rate"] for report in weekly_reports) / len(weekly_reports)
    total_risk_events = sum(report["summary"]["dehydration_risk_events"] for report in weekly_reports)
    total_symptoms = sum(report["summary"]["symptom_episodes"] for report in weekly_reports)
    
    return {
        "month": month,
        "year": year,
        "monthly_summary": {
            "total_intake_ml": total_intake,
            "average_completion_rate": round(avg_completion_rate, 1),
            "total_risk_events": total_risk_events,
            "total_symptom_episodes": total_symptoms,
            "weeks_analyzed": len(weekly_reports)
        },
        "weekly_reports": weekly_reports
    }

@router.get("/trends")
async def get_hydration_trends(
    days: int = 30,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Get hydration trends over specified period"""
    from app.services.hydration_engine import hydration_engine
    
    # Get trend data
    trend_data = hydration_engine.calculate_hydration_trend(current_user, db, days)
    
    # Get daily breakdown
    cutoff_time = datetime.utcnow() - timedelta(days=days)
    from sqlalchemy import func, and_
    from app.models import HydrationLog
    
    daily_totals = db.query(
        func.date(HydrationLog.timestamp).label('date'),
        func.sum(HydrationLog.amount_ml).label('total_ml')
    ).filter(
        and_(
            HydrationLog.user_id == current_user.id,
            HydrationLog.timestamp >= cutoff_time
        )
    ).group_by(func.date(HydrationLog.timestamp)).order_by('date').all()
    
    # Format data for charts
    chart_data = []
    for day in daily_totals:
        chart_data.append({
            "date": day.date.isoformat(),
            "intake_ml": day.total_ml
        })
    
    return {
        "period_days": days,
        "trend_analysis": trend_data,
        "daily_data": chart_data,
        "summary": {
            "total_days": len(daily_totals),
            "average_daily": trend_data["average_daily"],
            "trend_direction": trend_data["trend"],
            "consistency": trend_data["consistency_score"]
        }
    }

@router.get("/export")
async def export_hydration_data(
    format: str = "json",  # json, csv
    days: int = 30,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Export hydration data in specified format"""
    cutoff_time = datetime.utcnow() - timedelta(days=days)
    
    from sqlalchemy import func, and_
    from app.models import HydrationLog, WeatherData, SymptomLog
    
    # Get all data
    hydration_logs = db.query(HydrationLog).filter(
        and_(
            HydrationLog.user_id == current_user.id,
            HydrationLog.timestamp >= cutoff_time
        )
    ).order_by(HydrationLog.timestamp).all()
    
    weather_data = db.query(WeatherData).filter(
        and_(
            WeatherData.user_id == current_user.id,
            WeatherData.timestamp >= cutoff_time
        )
    ).order_by(WeatherData.timestamp).all()
    
    symptoms = db.query(SymptomLog).filter(
        and_(
            SymptomLog.user_id == current_user.id,
            SymptomLog.timestamp >= cutoff_time
        )
    ).order_by(SymptomLog.timestamp).all()
    
    export_data = {
        "user_id": current_user.id,
        "export_date": datetime.utcnow().isoformat(),
        "period_days": days,
        "hydration_logs": [
            {
                "timestamp": log.timestamp.isoformat(),
                "amount_ml": log.amount_ml,
                "drink_type": log.drink_type,
                "notes": log.notes
            } for log in hydration_logs
        ],
        "weather_data": [
            {
                "timestamp": w.timestamp.isoformat(),
                "temperature": w.temperature,
                "humidity": w.humidity,
                "condition": w.weather_condition
            } for w in weather_data
        ],
        "symptoms": [
            {
                "timestamp": s.timestamp.isoformat(),
                "symptom_type": s.symptom_type,
                "severity": s.severity,
                "notes": s.notes
            } for s in symptoms
        ]
    }
    
    if format.lower() == "csv":
        # Convert to CSV format (simplified)
        import csv
        import io
        
        output = io.StringIO()
        writer = csv.writer(output)
        
        # Write headers
        writer.writerow(["Type", "Timestamp", "Value1", "Value2", "Notes"])
        
        # Write hydration data
        for log in hydration_logs:
            writer.writerow([
                "hydration",
                log.timestamp.isoformat(),
                log.amount_ml,
                log.drink_type,
                log.notes or ""
            ])
        
        # Write weather data
        for w in weather_data:
            writer.writerow([
                "weather",
                w.timestamp.isoformat(),
                w.temperature,
                w.humidity,
                w.weather_condition or ""
            ])
        
        # Write symptoms
        for s in symptoms:
            writer.writerow([
                "symptom",
                s.timestamp.isoformat(),
                s.symptom_type,
                s.severity,
                s.notes or ""
            ])
        
        return {
            "format": "csv",
            "data": output.getvalue(),
            "filename": f"hydration_data_{current_user.id}_{datetime.utcnow().strftime('%Y%m%d')}.csv"
        }
    
    return {
        "format": "json",
        "data": export_data,
        "filename": f"hydration_data_{current_user.id}_{datetime.utcnow().strftime('%Y%m%d')}.json"
    }


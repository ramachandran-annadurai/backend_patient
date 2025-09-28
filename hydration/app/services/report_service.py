from typing import Dict, List, Optional
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from sqlalchemy import func, and_
import numpy as np
import logging

from app.models import User, HydrationLog, WeatherData, SymptomLog, Alert
from app.services.hydration_engine import hydration_engine
from app.services.notification_service import notification_service

logger = logging.getLogger(__name__)

class ReportService:
    def __init__(self):
        self.report_metrics = {
            "hydration_compliance": "Percentage of days meeting hydration goals",
            "risk_events": "Number of high dehydration risk events",
            "symptom_frequency": "Frequency of dehydration-related symptoms",
            "weather_impact": "Impact of weather on hydration patterns",
            "trend_analysis": "Weekly hydration trend analysis"
        }
    
    async def generate_weekly_report(self, user: User, db: Session, week_start: Optional[datetime] = None) -> Dict:
        """
        Generate comprehensive weekly hydration report for clinicians
        """
        if not week_start:
            # Default to start of current week (Monday)
            today = datetime.utcnow().date()
            week_start = datetime.combine(today - timedelta(days=today.weekday()), datetime.min.time())
        
        week_end = week_start + timedelta(days=7)
        
        # Get weekly data
        hydration_data = await self._get_weekly_hydration_data(user, db, week_start, week_end)
        weather_data = await self._get_weekly_weather_data(user, db, week_start, week_end)
        symptom_data = await self._get_weekly_symptom_data(user, db, week_start, week_end)
        alert_data = await self._get_weekly_alert_data(user, db, week_start, week_end)
        
        # Calculate metrics
        metrics = await self._calculate_weekly_metrics(user, db, week_start, week_end)
        
        # Generate recommendations
        recommendations = await self._generate_clinical_recommendations(
            user, hydration_data, symptom_data, alert_data, metrics
        )
        
        # Create report
        report = {
            "user_id": user.id,
            "user_name": f"{user.first_name} {user.last_name}",
            "pregnancy_week": user.pregnancy_week,
            "report_period": {
                "week_start": week_start.isoformat(),
                "week_end": week_end.isoformat()
            },
            "summary": {
                "total_intake_ml": hydration_data["total_intake"],
                "average_daily_intake_ml": hydration_data["average_daily"],
                "goal_completion_rate": hydration_data["completion_rate"],
                "dehydration_risk_events": alert_data["risk_events"],
                "symptom_episodes": symptom_data["total_episodes"]
            },
            "detailed_metrics": metrics,
            "daily_breakdown": hydration_data["daily_breakdown"],
            "weather_impact": weather_data,
            "symptom_analysis": symptom_data,
            "alert_summary": alert_data,
            "clinical_recommendations": recommendations,
            "generated_at": datetime.utcnow().isoformat()
        }
        
        return report
    
    async def _get_weekly_hydration_data(self, user: User, db: Session, week_start: datetime, week_end: datetime) -> Dict:
        """Get weekly hydration data"""
        # Get daily totals
        daily_totals = db.query(
            func.date(HydrationLog.timestamp).label('date'),
            func.sum(HydrationLog.amount_ml).label('total_ml')
        ).filter(
            and_(
                HydrationLog.user_id == user.id,
                HydrationLog.timestamp >= week_start,
                HydrationLog.timestamp < week_end
            )
        ).group_by(func.date(HydrationLog.timestamp)).all()
        
        # Calculate totals
        total_intake = sum(day.total_ml for day in daily_totals)
        average_daily = total_intake / 7 if daily_totals else 0
        
        # Get goal for completion rate calculation
        goal_data = await hydration_engine.calculate_dynamic_hydration_goal(user, db)
        daily_goal = goal_data["final_goal_ml"]
        
        # Calculate completion rate
        completion_rate = 0
        if daily_goal > 0:
            total_possible = daily_goal * 7
            completion_rate = (total_intake / total_possible * 100) if total_possible > 0 else 0
        
        # Create daily breakdown
        daily_breakdown = []
        for i in range(7):
            date = (week_start + timedelta(days=i)).date()
            day_total = next((day.total_ml for day in daily_totals if day.date == date), 0)
            day_completion = (day_total / daily_goal * 100) if daily_goal > 0 else 0
            
            daily_breakdown.append({
                "date": date.isoformat(),
                "intake_ml": day_total,
                "goal_ml": daily_goal,
                "completion_percentage": round(day_completion, 1),
                "met_goal": day_total >= daily_goal
            })
        
        return {
            "total_intake": total_intake,
            "average_daily": round(average_daily, 1),
            "completion_rate": round(completion_rate, 1),
            "daily_breakdown": daily_breakdown
        }
    
    async def _get_weekly_weather_data(self, user: User, db: Session, week_start: datetime, week_end: datetime) -> Dict:
        """Get weekly weather data and its impact"""
        weather_records = db.query(WeatherData).filter(
            and_(
                WeatherData.user_id == user.id,
                WeatherData.timestamp >= week_start,
                WeatherData.timestamp < week_end
            )
        ).all()
        
        if not weather_records:
            return {"impact": "no_data", "average_temp": None, "average_humidity": None}
        
        # Calculate averages
        avg_temp = sum(w.temperature for w in weather_records) / len(weather_records)
        avg_humidity = sum(w.humidity for w in weather_records) / len(weather_records)
        
        # Determine impact level
        impact = "moderate"
        if avg_temp > 30 or avg_humidity < 30:
            impact = "high"
        elif avg_temp < 20 and avg_humidity > 70:
            impact = "low"
        
        return {
            "impact": impact,
            "average_temp": round(avg_temp, 1),
            "average_humidity": round(avg_humidity, 1),
            "records_count": len(weather_records)
        }
    
    async def _get_weekly_symptom_data(self, user: User, db: Session, week_start: datetime, week_end: datetime) -> Dict:
        """Get weekly symptom data"""
        symptoms = db.query(SymptomLog).filter(
            and_(
                SymptomLog.user_id == user.id,
                SymptomLog.timestamp >= week_start,
                SymptomLog.timestamp < week_end,
                SymptomLog.symptom_type.in_(["headache", "fatigue", "dizziness", "dry_mouth"])
            )
        ).all()
        
        # Group by symptom type
        symptom_counts = {}
        total_severity = 0
        
        for symptom in symptoms:
            if symptom.symptom_type not in symptom_counts:
                symptom_counts[symptom.symptom_type] = 0
            symptom_counts[symptom.symptom_type] += 1
            total_severity += symptom.severity
        
        avg_severity = total_severity / len(symptoms) if symptoms else 0
        
        return {
            "total_episodes": len(symptoms),
            "symptom_breakdown": symptom_counts,
            "average_severity": round(avg_severity, 1),
            "most_common_symptom": max(symptom_counts.items(), key=lambda x: x[1])[0] if symptom_counts else None
        }
    
    async def _get_weekly_alert_data(self, user: User, db: Session, week_start: datetime, week_end: datetime) -> Dict:
        """Get weekly alert data"""
        alerts = db.query(Alert).filter(
            and_(
                Alert.user_id == user.id,
                Alert.timestamp >= week_start,
                Alert.timestamp < week_end
            )
        ).all()
        
        # Categorize alerts
        alert_types = {}
        risk_events = 0
        
        for alert in alerts:
            if alert.alert_type not in alert_types:
                alert_types[alert.alert_type] = 0
            alert_types[alert.alert_type] += 1
            
            if "risk" in alert.alert_type or alert.severity in ["high", "critical"]:
                risk_events += 1
        
        return {
            "total_alerts": len(alerts),
            "risk_events": risk_events,
            "alert_breakdown": alert_types,
            "critical_alerts": len([a for a in alerts if a.severity == "critical"])
        }
    
    async def _calculate_weekly_metrics(self, user: User, db: Session, week_start: datetime, week_end: datetime) -> Dict:
        """Calculate detailed weekly metrics"""
        # Get hydration trend
        trend_data = hydration_engine.calculate_hydration_trend(user, db, 7)
        
        # Calculate consistency score
        daily_totals = db.query(
            func.date(HydrationLog.timestamp).label('date'),
            func.sum(HydrationLog.amount_ml).label('total_ml')
        ).filter(
            and_(
                HydrationLog.user_id == user.id,
                HydrationLog.timestamp >= week_start,
                HydrationLog.timestamp < week_end
            )
        ).group_by(func.date(HydrationLog.timestamp)).all()
        
        amounts = [day.total_ml for day in daily_totals]
        consistency_score = trend_data["consistency_score"]
        
        # Calculate risk score trend
        current_risk = hydration_engine.calculate_dehydration_risk_score(user, db)
        
        return {
            "hydration_trend": trend_data["trend"],
            "consistency_score": consistency_score,
            "current_risk_score": round(current_risk, 2),
            "days_with_data": len(amounts),
            "variance": round(np.var(amounts), 2) if amounts else 0
        }
    
    async def _generate_clinical_recommendations(
        self, 
        user: User, 
        hydration_data: Dict, 
        symptom_data: Dict, 
        alert_data: Dict, 
        metrics: Dict
    ) -> List[str]:
        """Generate clinical recommendations based on data analysis"""
        recommendations = []
        
        # Hydration compliance recommendations
        if hydration_data["completion_rate"] < 70:
            recommendations.append(
                "Patient shows low hydration compliance. Consider implementing more frequent reminders or adjusting daily goals."
            )
        elif hydration_data["completion_rate"] > 90:
            recommendations.append(
                "Excellent hydration compliance. Patient is maintaining good hydration habits."
            )
        
        # Risk event recommendations
        if alert_data["risk_events"] > 3:
            recommendations.append(
                "Multiple dehydration risk events detected. Consider closer monitoring and patient education on hydration importance."
            )
        
        # Symptom-based recommendations
        if symptom_data["total_episodes"] > 5:
            recommendations.append(
                f"Frequent dehydration-related symptoms ({symptom_data['most_common_symptom']}). "
                "Consider hydration assessment and potential underlying causes."
            )
        
        # Trend-based recommendations
        if metrics["hydration_trend"] == "declining":
            recommendations.append(
                "Declining hydration trend observed. Patient may need additional support or intervention."
            )
        elif metrics["hydration_trend"] == "improving":
            recommendations.append(
                "Improving hydration trend. Current approach appears effective."
            )
        
        # Pregnancy-specific recommendations
        if user.pregnancy_week:
            if user.pregnancy_week > 30:
                recommendations.append(
                    "Third trimester patient - ensure adequate hydration to support fetal growth and reduce swelling."
                )
            elif user.pregnancy_week > 20:
                recommendations.append(
                    "Second trimester - monitor hydration as baby's growth accelerates."
                )
        
        # Consistency recommendations
        if metrics["consistency_score"] < 0.5:
            recommendations.append(
                "Inconsistent hydration patterns. Consider implementing structured hydration schedule."
            )
        
        return recommendations
    
    async def send_weekly_report_to_clinician(self, user: User, report: Dict, clinician_email: str) -> bool:
        """Send weekly report to clinician via email"""
        try:
            # In a real implementation, you would send this via email
            # For now, we'll log it
            logger.info(f"Weekly report generated for user {user.id} - {user.first_name} {user.last_name}")
            logger.info(f"Report summary: {report['summary']}")
            logger.info(f"Recommendations: {report['clinical_recommendations']}")
            
            # You could integrate with email services like SendGrid, AWS SES, etc.
            return True
            
        except Exception as e:
            logger.error(f"Error sending weekly report: {e}")
            return False

# Global instance
report_service = ReportService()

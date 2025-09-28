from typing import Dict, List, Optional
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from sqlalchemy import and_, func
import logging

from app.models import User, Alert, HydrationLog, SymptomLog
from app.services.hydration_engine import hydration_engine
from app.services.notification_service import notification_service

logger = logging.getLogger(__name__)

class AlertService:
    def __init__(self):
        self.alert_thresholds = {
            "low_hydration": 0.3,  # 30% below goal
            "dehydration_risk": 0.6,  # 60% risk score
            "critical_dehydration": 0.8,  # 80% risk score
            "symptom_alert": 7,  # Symptom severity >= 7
        }
    
    async def check_hydration_alerts(self, user: User, db: Session) -> List[Dict]:
        """
        Check for hydration-related alerts and trigger notifications
        """
        alerts_triggered = []
        
        # Get current hydration status
        risk_score = hydration_engine.calculate_dehydration_risk_score(user, db)
        
        # Check for low hydration
        today_summary = await self._get_today_hydration_summary(user, db)
        if today_summary["percentage_complete"] < 30:
            alert = await self._create_alert(
                user, db, "low_hydration", 
                f"Your hydration is at {today_summary['percentage_complete']:.1f}% of your daily goal. Time to drink some water! 💧",
                "high"
            )
            if alert:
                alerts_triggered.append(alert)
        
        # Check for dehydration risk
        if risk_score > self.alert_thresholds["dehydration_risk"]:
            severity = "critical" if risk_score > self.alert_thresholds["critical_dehydration"] else "high"
            message = self._get_dehydration_alert_message(risk_score, severity)
            
            alert = await self._create_alert(
                user, db, "dehydration_risk", message, severity
            )
            if alert:
                alerts_triggered.append(alert)
        
        # Check for symptom-based alerts
        symptom_alerts = await self._check_symptom_alerts(user, db)
        alerts_triggered.extend(symptom_alerts)
        
        # Send notifications for triggered alerts
        for alert in alerts_triggered:
            await self._send_alert_notification(user, alert)
        
        return alerts_triggered
    
    async def _get_today_hydration_summary(self, user: User, db: Session) -> Dict:
        """Get today's hydration summary"""
        today = datetime.utcnow().date()
        
        # Get today's total intake
        total_intake = db.query(func.sum(HydrationLog.amount_ml)).filter(
            and_(
                HydrationLog.user_id == user.id,
                func.date(HydrationLog.timestamp) == today
            )
        ).scalar() or 0
        
        # Get goal
        goal_data = await hydration_engine.calculate_dynamic_hydration_goal(user, db)
        goal_ml = goal_data["final_goal_ml"]
        
        percentage_complete = (total_intake / goal_ml * 100) if goal_ml > 0 else 0
        
        return {
            "total_intake_ml": total_intake,
            "goal_ml": goal_ml,
            "percentage_complete": percentage_complete
        }
    
    async def _check_symptom_alerts(self, user: User, db: Session) -> List[Dict]:
        """Check for symptom-based alerts"""
        alerts = []
        
        # Get recent high-severity symptoms
        cutoff_time = datetime.utcnow() - timedelta(hours=6)
        high_severity_symptoms = db.query(SymptomLog).filter(
            and_(
                SymptomLog.user_id == user.id,
                SymptomLog.timestamp >= cutoff_time,
                SymptomLog.severity >= self.alert_thresholds["symptom_alert"],
                SymptomLog.symptom_type.in_(["headache", "fatigue", "dizziness", "dry_mouth"])
            )
        ).all()
        
        for symptom in high_severity_symptoms:
            message = self._get_symptom_alert_message(symptom)
            alert = await self._create_alert(
                user, db, "symptom_alert", message, "medium",
                alert_metadata={"symptom_type": symptom.symptom_type, "severity": symptom.severity}
            )
            if alert:
                alerts.append(alert)
        
        return alerts
    
    async def _create_alert(
        self, 
        user: User, 
        db: Session, 
        alert_type: str, 
        message: str, 
        severity: str,
        alert_metadata: Optional[Dict] = None
    ) -> Optional[Alert]:
        """Create an alert record"""
        try:
            # Check if similar alert was sent recently (avoid spam)
            recent_cutoff = datetime.utcnow() - timedelta(hours=2)
            recent_alert = db.query(Alert).filter(
                and_(
                    Alert.user_id == user.id,
                    Alert.alert_type == alert_type,
                    Alert.timestamp >= recent_cutoff
                )
            ).first()
            
            if recent_alert:
                logger.info(f"Similar alert already sent recently for user {user.id}")
                return None
            
            # Create new alert
            alert = Alert(
                user_id=user.id,
                alert_type=alert_type,
                message=message,
                severity=severity,
                alert_metadata=alert_metadata or {}
            )
            
            db.add(alert)
            db.commit()
            db.refresh(alert)
            
            return alert
            
        except Exception as e:
            logger.error(f"Error creating alert: {e}")
            return None
    
    async def _send_alert_notification(self, user: User, alert: Alert):
        """Send alert notification via appropriate channels"""
        try:
            # Send push notification
            if user.phone_number:  # Assuming we have FCM token stored
                await notification_service.send_push_notification(
                    user_id=user.id,
                    title="Hydration Alert",
                    body=alert.message,
                    data={"alert_id": alert.id, "alert_type": alert.alert_type}
                )
            
            # Send SMS for critical alerts
            if alert.severity == "critical" and user.phone_number:
                await notification_service.send_sms(
                    phone_number=user.phone_number,
                    message=f"Vital Alert: {alert.message}"
                )
            
            # Update alert with sent status
            alert.sent_via = "push,sms" if alert.severity == "critical" else "push"
            
        except Exception as e:
            logger.error(f"Error sending alert notification: {e}")
    
    def _get_dehydration_alert_message(self, risk_score: float, severity: str) -> str:
        """Generate dehydration alert message based on risk score"""
        if severity == "critical":
            return f"🚨 CRITICAL: High dehydration risk detected ({risk_score:.0%})! Please drink water immediately and consider contacting your healthcare provider."
        else:
            return f"⚠️ Dehydration risk detected ({risk_score:.0%}). Please increase your water intake and monitor for symptoms."
    
    def _get_symptom_alert_message(self, symptom: SymptomLog) -> str:
        """Generate symptom-based alert message"""
        symptom_emojis = {
            "headache": "🤕",
            "fatigue": "😴",
            "dizziness": "😵",
            "dry_mouth": "👄"
        }
        
        emoji = symptom_emojis.get(symptom.symptom_type, "⚠️")
        
        if symptom.severity >= 8:
            return f"{emoji} Severe {symptom.symptom_type.replace('_', ' ')} detected. This may indicate dehydration. Please drink water and consider contacting your healthcare provider."
        else:
            return f"{emoji} {symptom.symptom_type.replace('_', ' ').title()} reported. This may be related to hydration. Try drinking some water."
    
    async def get_user_alerts(
        self, 
        user: User, 
        db: Session, 
        days: int = 7,
        unread_only: bool = False
    ) -> List[Alert]:
        """Get user's alerts"""
        cutoff_time = datetime.utcnow() - timedelta(days=days)
        
        query = db.query(Alert).filter(
            and_(
                Alert.user_id == user.id,
                Alert.timestamp >= cutoff_time
            )
        )
        
        if unread_only:
            query = query.filter(Alert.is_read == False)
        
        return query.order_by(Alert.timestamp.desc()).all()
    
    async def mark_alert_as_read(self, alert_id: int, user: User, db: Session) -> bool:
        """Mark an alert as read"""
        alert = db.query(Alert).filter(
            and_(
                Alert.id == alert_id,
                Alert.user_id == user.id
            )
        ).first()
        
        if alert:
            alert.is_read = True
            db.commit()
            return True
        
        return False

# Global instance
alert_service = AlertService()

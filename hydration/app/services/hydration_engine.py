from typing import Dict, List, Optional, Tuple
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from sqlalchemy import func, and_
import numpy as np
from sklearn.ensemble import IsolationForest
import logging

from app.models import User, HydrationLog, WeatherData, SymptomLog, HydrationGoal
# from app.services.weather_service import weather_service
from app.core.config import settings

logger = logging.getLogger(__name__)

class HydrationEngine:
    def __init__(self):
        self.base_hydration_goal = settings.DEFAULT_HYDRATION_GOAL
        self.pregnancy_boost = settings.PREGNANCY_HYDRATION_BOOST
        self.weather_factor = settings.WEATHER_HYDRATION_FACTOR
    
    def calculate_base_hydration_goal(self, user: User) -> int:
        """
        Calculate base hydration goal based on user characteristics
        """
        base_goal = self.base_hydration_goal
        
        # Pregnancy adjustment
        if user.pregnancy_week and user.pregnancy_week > 0:
            base_goal = int(base_goal * self.pregnancy_boost)
        
        # Weight-based adjustment (if available)
        if user.weight:
            # Standard formula: 35ml per kg of body weight
            weight_based_goal = int(user.weight * 35)
            # Use the higher of base goal or weight-based goal
            base_goal = max(base_goal, weight_based_goal)
        
        return base_goal
    
    async def calculate_dynamic_hydration_goal(self, user: User, db: Session) -> Dict:
        """
        Calculate dynamic hydration goal considering weather, activity, and pregnancy
        """
        base_goal = self.calculate_base_hydration_goal(user)
        
        # Get current weather data
        weather_adjustment = 1.0
        # Note: Weather service integration can be added later
        # For now, using default adjustment
        
        # Pregnancy week adjustment (more water needed in later pregnancy)
        pregnancy_adjustment = 1.0
        if user.pregnancy_week:
            if user.pregnancy_week > 30:
                pregnancy_adjustment = 1.3  # 30% increase in third trimester
            elif user.pregnancy_week > 20:
                pregnancy_adjustment = 1.2  # 20% increase in second trimester
            else:
                pregnancy_adjustment = 1.1  # 10% increase in first trimester
        
        # Activity adjustment (placeholder - would integrate with fitness trackers)
        activity_adjustment = 1.0
        
        # Calculate final goal
        final_goal = int(base_goal * weather_adjustment * pregnancy_adjustment * activity_adjustment)
        
        return {
            "base_goal_ml": base_goal,
            "weather_adjustment": weather_adjustment,
            "pregnancy_adjustment": pregnancy_adjustment,
            "activity_adjustment": activity_adjustment,
            "final_goal_ml": final_goal
        }
    
    def calculate_dehydration_risk_score(self, user: User, db: Session, hours_back: int = 24) -> float:
        """
        Calculate dehydration risk score based on recent intake and symptoms
        """
        # Get recent hydration logs
        cutoff_time = datetime.utcnow() - timedelta(hours=hours_back)
        recent_logs = db.query(HydrationLog).filter(
            and_(
                HydrationLog.user_id == user.id,
                HydrationLog.timestamp >= cutoff_time
            )
        ).all()
        
        # Calculate total intake
        total_intake = sum(log.amount_ml for log in recent_logs)
        
        # Get current goal
        current_goal = self.calculate_base_hydration_goal(user)
        
        # Calculate intake ratio
        intake_ratio = total_intake / current_goal if current_goal > 0 else 0
        
        # Get recent symptoms
        recent_symptoms = db.query(SymptomLog).filter(
            and_(
                SymptomLog.user_id == user.id,
                SymptomLog.timestamp >= cutoff_time,
                SymptomLog.symptom_type.in_(["headache", "fatigue", "dizziness", "dry_mouth"])
            )
        ).all()
        
        # Calculate symptom score
        symptom_score = 0
        if recent_symptoms:
            # Weight symptoms by severity and recency
            for symptom in recent_symptoms:
                hours_ago = (datetime.utcnow() - symptom.timestamp).total_seconds() / 3600
                recency_factor = max(0, 1 - (hours_ago / 24))  # Decay over 24 hours
                symptom_score += symptom.severity * recency_factor
        
        # Calculate risk score (0-1, where 1 is highest risk)
        intake_risk = max(0, 1 - intake_ratio)  # Higher risk if intake is low
        symptom_risk = min(1, symptom_score / 20)  # Normalize symptom score
        
        # Combine risks with weights
        risk_score = (intake_risk * 0.7) + (symptom_risk * 0.3)
        
        return min(1.0, risk_score)
    
    def detect_anomalies(self, user: User, db: Session, days_back: int = 7) -> List[Dict]:
        """
        Detect anomalous hydration patterns using machine learning
        """
        # Get historical data
        cutoff_time = datetime.utcnow() - timedelta(days=days_back)
        logs = db.query(HydrationLog).filter(
            and_(
                HydrationLog.user_id == user.id,
                HydrationLog.timestamp >= cutoff_time
            )
        ).order_by(HydrationLog.timestamp).all()
        
        if len(logs) < 10:  # Need sufficient data for anomaly detection
            return []
        
        # Prepare data for anomaly detection
        # Group by hour and calculate total intake per hour
        hourly_intake = {}
        for log in logs:
            hour_key = log.timestamp.replace(minute=0, second=0, microsecond=0)
            hourly_intake[hour_key] = hourly_intake.get(hour_key, 0) + log.amount_ml
        
        # Convert to feature matrix
        hours = sorted(hourly_intake.keys())
        features = []
        for hour in hours:
            # Features: hour of day, day of week, intake amount
            features.append([
                hour.hour,
                hour.weekday(),
                hourly_intake[hour]
            ])
        
        if len(features) < 5:
            return []
        
        # Detect anomalies using Isolation Forest
        iso_forest = IsolationForest(contamination=0.1, random_state=42)
        anomaly_labels = iso_forest.fit_predict(features)
        
        # Identify anomalies
        anomalies = []
        for i, (hour, is_anomaly) in enumerate(zip(hours, anomaly_labels)):
            if is_anomaly == -1:  # Anomaly detected
                anomalies.append({
                    "timestamp": hour,
                    "intake_ml": hourly_intake[hour],
                    "anomaly_type": "unusual_intake_pattern",
                    "severity": "medium"
                })
        
        return anomalies
    
    def generate_hydration_recommendations(self, user: User, db: Session) -> List[str]:
        """
        Generate personalized hydration recommendations
        """
        recommendations = []
        
        # Get current risk score
        risk_score = self.calculate_dehydration_risk_score(user, db)
        
        # Get recent intake
        cutoff_time = datetime.utcnow() - timedelta(hours=6)
        recent_intake = db.query(func.sum(HydrationLog.amount_ml)).filter(
            and_(
                HydrationLog.user_id == user.id,
                HydrationLog.timestamp >= cutoff_time
            )
        ).scalar() or 0
        
        # Risk-based recommendations
        if risk_score > 0.7:
            recommendations.append("🚨 High dehydration risk detected! Please drink water immediately.")
            recommendations.append("Consider drinking 200-300ml of water every 15-20 minutes.")
        elif risk_score > 0.4:
            recommendations.append("⚠️ Moderate dehydration risk. Increase your water intake.")
            recommendations.append("Try to drink 150-200ml of water in the next hour.")
        
        # Intake-based recommendations
        if recent_intake < 200:
            recommendations.append("💧 You haven't had much water recently. Time for a refreshing drink!")
        elif recent_intake < 500:
            recommendations.append("🥤 Good start! Keep up the hydration throughout the day.")
        
        # Pregnancy-specific recommendations
        if user.pregnancy_week:
            if user.pregnancy_week > 30:
                recommendations.append("🤱 Third trimester tip: Extra hydration helps with swelling and supports your baby's growth.")
            elif user.pregnancy_week > 20:
                recommendations.append("👶 Second trimester: Your baby is growing rapidly - stay well hydrated!")
            else:
                recommendations.append("🌱 First trimester: Even mild dehydration can worsen morning sickness.")
        
        # Weather-based recommendations
        if user.location_lat and user.location_lon:
            # This would be async in real implementation
            pass
        
        return recommendations[:3]  # Return top 3 recommendations
    
    def calculate_hydration_trend(self, user: User, db: Session, days_back: int = 7) -> Dict:
        """
        Calculate hydration trend over time
        """
        cutoff_time = datetime.utcnow() - timedelta(days=days_back)
        
        # Get daily totals
        daily_totals = db.query(
            func.date(HydrationLog.timestamp).label('date'),
            func.sum(HydrationLog.amount_ml).label('total_ml')
        ).filter(
            and_(
                HydrationLog.user_id == user.id,
                HydrationLog.timestamp >= cutoff_time
            )
        ).group_by(func.date(HydrationLog.timestamp)).all()
        
        if not daily_totals:
            return {"trend": "no_data", "average_daily": 0, "consistency_score": 0}
        
        # Calculate trend
        amounts = [day.total_ml for day in daily_totals]
        if len(amounts) > 1:
            # Simple linear trend calculation
            x = list(range(len(amounts)))
            trend_slope = np.polyfit(x, amounts, 1)[0]
            
            if trend_slope > 50:
                trend = "improving"
            elif trend_slope < -50:
                trend = "declining"
            else:
                trend = "stable"
        else:
            trend = "insufficient_data"
        
        # Calculate consistency (lower standard deviation = more consistent)
        avg_daily = np.mean(amounts)
        std_daily = np.std(amounts)
        consistency_score = max(0, 1 - (std_daily / avg_daily)) if avg_daily > 0 else 0
        
        return {
            "trend": trend,
            "average_daily": int(avg_daily),
            "consistency_score": round(consistency_score, 2),
            "daily_amounts": amounts
        }

# Global instance
hydration_engine = HydrationEngine()

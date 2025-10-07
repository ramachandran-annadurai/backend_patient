#!/usr/bin/env python3
"""
Direct test of hydration service functionality
"""

from hydration_service import HydrationService
from hydration_models import HydrationIntakeRequest, HydrationGoalRequest
from datetime import datetime, date

def test_hydration_service():
    """Test hydration service directly"""
    print("💧 Testing Hydration Service Directly")
    print("=" * 50)
    
    try:
        # Initialize service
        print("1. Initializing hydration service...")
        service = HydrationService()
        print("   ✅ Service initialized")
        
        # Test patient ID
        test_patient_id = "test_patient_123"
        
        # Test hydration intake
        print("\n2. Testing hydration intake...")
        intake_data = HydrationIntakeRequest(
            hydration_type="water",
            amount_ml=250,
            notes="Test hydration intake",
            temperature="room",
            additives=["lemon"]
        )
        
        result = service.save_hydration_intake(test_patient_id, intake_data)
        print(f"   ✅ Intake saved: {result.success}")
        if result.message:
            print(f"   📝 Message: {result.message}")
        
        # Test hydration goal
        print("\n3. Testing hydration goal...")
        goal_data = HydrationGoalRequest(
            daily_goal_ml=2000,
            goal_type="daily",
            start_date=date.today(),
            notes="Test daily goal"
        )
        
        goal_result = service.set_hydration_goal(test_patient_id, goal_data)
        print(f"   ✅ Goal set: {goal_result.success}")
        if goal_result.message:
            print(f"   📝 Message: {goal_result.message}")
        
        # Test getting hydration history
        print("\n4. Testing hydration history...")
        history_result = service.get_hydration_history(test_patient_id, days=7)
        print(f"   ✅ History retrieved: {history_result.success}")
        if hasattr(history_result, 'data') and history_result.data:
            print(f"   📊 Records found: {len(history_result.data)}")
        
        # Test getting hydration stats
        print("\n5. Testing hydration stats...")
        stats_result = service.get_daily_hydration_stats(test_patient_id, date.today())
        print(f"   ✅ Stats retrieved: {stats_result.success}")
        if hasattr(stats_result, 'data') and stats_result.data:
            print(f"   📊 Total intake: {stats_result.data.get('total_intake_ml', 0)}ml")
        
        print("\n🎉 Hydration service test completed successfully!")
        return True
        
    except Exception as e:
        print(f"❌ Error testing hydration service: {str(e)}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    test_hydration_service()





